import SwiftUI
import AVFoundation
import Photos

// MARK: - 语音录制组件
struct VoiceRecorderView: View {
    @Binding var audioURL: URL?
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var recordingTimer: Timer?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var audioPlayerDelegate = AudioPlayerDelegate()
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 录音状态显示
            HStack {
                Image(systemName: audioURL != nil ? "checkmark.circle.fill" : "mic.circle")
                    .font(.title2)
                    .foregroundColor(audioURL != nil ? AppTheme.Colors.success : AppTheme.Colors.textTertiary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(audioURL != nil ? "语音已录制" : "添加语音")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    if isRecording {
                        Text("录音中... \(formatDuration(recordingDuration))")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.error)
                    } else if audioURL != nil {
                        Text("点击播放或重新录制")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    } else {
                        Text("长按录音按钮开始录制")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            // 控制按钮
            HStack(spacing: AppTheme.Spacing.md) {
                // 录音按钮
                Button(action: {}) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(isRecording ? AppTheme.Colors.error : AppTheme.Colors.primary)
                        .clipShape(Circle())
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                }
                .onLongPressGesture(
                    minimumDuration: 0.1,
                    maximumDistance: 50,
                    perform: {},
                    onPressingChanged: { pressing in
                        if pressing {
                            startRecording()
                        } else {
                            stopRecording()
                        }
                    }
                )
                
                // 播放按钮
                if audioURL != nil {
                    Button(action: playRecording) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                            .foregroundColor(AppTheme.Colors.success)
                    }
                    
                    // 删除按钮
                    Button(action: deleteRecording) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title)
                            .foregroundColor(AppTheme.Colors.error)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .stroke(AppTheme.Colors.separator, lineWidth: 1)
        )
        .onAppear {
            setupAudioSession()
        }
        .onDisappear {
            cleanupAudioResources()
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            print("🎤 音频会话设置成功")
        } catch {
            print("❌ 音频会话设置失败: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.alertMessage = "无法初始化音频功能，请重启应用或检查设备音频设置"
                self.showingAlert = true
            }
        }
    }
    
    private func startRecording() {
        guard !isRecording else { return }
        
        // 请求麦克风权限
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.beginRecording()
                } else {
                    self.alertMessage = "需要麦克风权限才能录音"
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func beginRecording() {
        // 重置之前的录音状态
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1, // 单声道，减少文件大小
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        do {
            let recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            
            if recorder.record() {
                audioRecorder = recorder
                isRecording = true
                recordingDuration = 0
                
                // 开始计时
                recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    self.recordingDuration += 0.1
                }
                
                print("🎤 开始录音: \(audioFilename.lastPathComponent)")
            } else {
                print("❌ 录音器启动失败")
                alertMessage = "无法开始录音，请检查麦克风权限"
                showingAlert = true
            }
            
        } catch {
            print("❌ 创建录音器失败: \(error.localizedDescription)")
            alertMessage = "录音功能初始化失败: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func stopRecording() {
        guard isRecording else { 
            print("⚠️ 尝试停止录音，但当前没有在录音")
            return 
        }
        
        // 停止录音器
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        let duration = recordingDuration
        let recordingURL = audioRecorder?.url
        
        // 重置状态
        isRecording = false
        
        // 检查录音时长
        if duration >= 1.0 {
            audioURL = recordingURL
            print("✅ 录音完成: \(formatDuration(duration))，文件：\(recordingURL?.lastPathComponent ?? "未知")")
        } else {
            // 录音时间太短，清理文件
            if let url = recordingURL {
                do {
                    try FileManager.default.removeItem(at: url)
                    print("🗑️ 删除过短录音文件: \(url.lastPathComponent)")
                } catch {
                    print("❌ 删除录音文件失败: \(error.localizedDescription)")
                }
            }
            alertMessage = "录音时间太短（至少需要1秒），请重新录制"
            showingAlert = true
        }
        
        // 清理录音器
        audioRecorder = nil
    }
    
    private func playRecording() {
        guard let url = audioURL else { 
            print("❌ 录音文件不存在")
            return 
        }
        
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
            print("⏸️ 停止播放录音")
        } else {
            // 确保在主线程操作
            DispatchQueue.main.async {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer = player
                    
                    // 设置代理和回调
                    player.delegate = self.audioPlayerDelegate
                    
                    // 设置播放完成回调
                    self.audioPlayerDelegate.onPlaybackFinished = { success in
                        self.isPlaying = false
                    }
                    
                    // 设置播放错误回调
                    self.audioPlayerDelegate.onPlaybackError = { error in
                        self.isPlaying = false
                        if let error = error {
                            self.alertMessage = "音频文件损坏或格式不支持: \(error.localizedDescription)"
                            self.showingAlert = true
                        }
                    }
                    
                    if player.play() {
                        self.isPlaying = true
                        print("▶️ 开始播放录音，时长: \(self.formatDuration(player.duration))")
                    } else {
                        print("❌ 播放启动失败")
                        self.alertMessage = "播放失败，请重试"
                        self.showingAlert = true
                    }
                } catch {
                    print("❌ 播放失败: \(error.localizedDescription)")
                    self.alertMessage = "无法播放录音文件: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func deleteRecording() {
        // 停止播放
        audioPlayer?.stop()
        isPlaying = false
        
        // 清理代理回调
        audioPlayerDelegate.onPlaybackFinished = nil
        audioPlayerDelegate.onPlaybackError = nil
        
        // 删除录音文件
        if let url = audioURL {
            do {
                try FileManager.default.removeItem(at: url)
                print("🗑️ 成功删除录音文件: \(url.lastPathComponent)")
            } catch {
                print("❌ 删除录音文件失败: \(error.localizedDescription)")
                // 即使删除失败，也要清空URL引用
            }
        }
        
        // 清空引用
        audioURL = nil
        audioPlayer = nil
        print("✅ 录音数据已清空")
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func cleanupAudioResources() {
        // 停止录音
        if isRecording {
            audioRecorder?.stop()
            recordingTimer?.invalidate()
            recordingTimer = nil
            isRecording = false
        }
        
        // 停止播放
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
        }
        
        // 清理代理回调
        audioPlayerDelegate.onPlaybackFinished = nil
        audioPlayerDelegate.onPlaybackError = nil
        
        // 清空引用
        audioRecorder = nil
        audioPlayer = nil
        
        print("🧹 清理音频资源")
    }
}

// MARK: - 音频播放代理类
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onPlaybackFinished: ((Bool) -> Void)?
    var onPlaybackError: ((Error?) -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            if flag {
                print("✅ 录音播放完成")
            } else {
                print("❌ 录音播放异常结束")
            }
            self.onPlaybackFinished?(flag)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("❌ 音频解码错误: \(error.localizedDescription)")
            }
            self.onPlaybackError?(error)
        }
    }
}

// MARK: - 照片选择组件
struct PhotoSelectorView: View {
    @Binding var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 照片预览或占位
            if let image = selectedImage {
                VStack(spacing: AppTheme.Spacing.sm) {
                    // 照片预览
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 150)
                        .cornerRadius(AppTheme.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(AppTheme.Colors.separator, lineWidth: 1)
                        )
                    
                    // 操作按钮
                    HStack(spacing: AppTheme.Spacing.md) {
                        Button("重新选择") {
                            showingImagePicker = true
                            sourceType = .photoLibrary
                        }
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.primary)
                        
                        Button("删除照片") {
                            selectedImage = nil
                            print("🗑️ 删除选中照片")
                        }
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.error)
                    }
                }
            } else {
                // 照片选择区域
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    
                    Text("添加照片")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("记录美好瞬间，为心情增添色彩")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // 选择按钮
                    HStack(spacing: AppTheme.Spacing.md) {
                        Button("相机拍摄") {
                            checkCameraPermission()
                        }
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                        
                        Button("相册选择") {
                            checkPhotoLibraryPermission()
                        }
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.Colors.surface)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                .stroke(AppTheme.Colors.primary, lineWidth: 1)
                        )
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.Colors.separator, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                )
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("设置") {
                // 打开设置
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                sourceType = .camera
                showingImagePicker = true
                print("📱 打开相机")
            } else {
                alertMessage = "此设备不支持相机功能"
                showingAlert = true
                print("❌ 设备不支持相机")
            }
        case .notDetermined:
            print("🔐 请求相机权限")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("✅ 相机权限已授权")
                        self.checkCameraPermission()
                    } else {
                        print("❌ 相机权限被拒绝")
                        self.alertMessage = "需要相机权限才能拍照"
                        self.showingAlert = true
                    }
                }
            }
        case .denied, .restricted:
            print("❌ 相机权限被拒绝或受限")
            alertMessage = "相机权限被拒绝，请在设置中开启"
            showingAlert = true
        @unknown default:
            print("❓ 未知相机权限状态")
            break
        }
    }
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            sourceType = .photoLibrary
            showingImagePicker = true
            print("📱 打开照片库")
        case .notDetermined:
            print("🔐 请求照片库权限")
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        print("✅ 照片库权限已授权")
                        self.sourceType = .photoLibrary
                        self.showingImagePicker = true
                    } else {
                        print("❌ 照片库权限被拒绝")
                        self.alertMessage = "需要照片权限才能选择照片"
                        self.showingAlert = true
                    }
                }
            }
        case .denied, .restricted:
            print("❌ 照片库权限被拒绝或受限")
            alertMessage = "照片权限被拒绝，请在设置中开启"
            showingAlert = true
        @unknown default:
            print("❓ 未知照片库权限状态")
            break
        }
    }
}

// MARK: - UIImagePickerController 包装器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image"] // 只允许图片
        
        // 设置相机特定选项
        if sourceType == .camera {
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
        }
        
        print("📱 创建ImagePicker，源类型: \(sourceType == .camera ? "相机" : "相册")")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            defer {
                parent.presentationMode.wrappedValue.dismiss()
            }
            
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
                print("📸 选择照片成功（已编辑），尺寸: \(editedImage.size)")
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
                print("📸 选择照片成功（原图），尺寸: \(originalImage.size)")
            } else {
                print("❌ 无法获取选择的图片")
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
            print("❌ 用户取消选择照片")
        }
    }
} 

// MARK: - 媒体展示组件（用于详情页面）
struct MediaDisplayView: View {
    let audioURL: URL?
    let imageURL: URL?
    
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerDelegate = AudioPlayerDelegate()
    @State private var showingImageDetail = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("媒体")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            // 语音播放区域
            if let audioURL = audioURL {
                audioDisplaySection(audioURL: audioURL)
            }
            
            // 图片展示区域
            if let imageURL = imageURL {
                imageDisplaySection(imageURL: imageURL)
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
        .onDisappear {
            cleanupAudioResources()
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingImageDetail) {
            if let imageURL = imageURL,
               let image = UIImage(contentsOfFile: imageURL.path) {
                ImageDetailView(image: image)
            }
        }
        .onAppear {
            print("📺 展示媒体组件")
            if let audioURL = audioURL {
                print("   - 语音文件: \(audioURL.lastPathComponent)")
            }
            if let imageURL = imageURL {
                print("   - 图片文件: \(imageURL.lastPathComponent)")
            }
        }
    }
    
    private func audioDisplaySection(audioURL: URL) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 语音图标
            Image(systemName: "waveform.path.ecg")
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("语音备忘")
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(isPlaying ? "播放中..." : "点击播放")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            // 播放按钮
            Button(action: { playAudio(url: audioURL) }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.Colors.success)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.primaryLight.opacity(0.3))
        .cornerRadius(AppTheme.CornerRadius.sm)
    }
    
    private func imageDisplaySection(imageURL: URL) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("照片")
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text("点击查看大图")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // 缩略图
            if let image = UIImage(contentsOfFile: imageURL.path) {
                Button(action: { showingImageDetail = true }) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(AppTheme.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(AppTheme.Colors.separator, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // 图片加载失败的占位符
                HStack {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundColor(AppTheme.Colors.error)
                    Text("图片无法显示")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.error)
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.md)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.primaryLight.opacity(0.3))
        .cornerRadius(AppTheme.CornerRadius.sm)
    }
    
    private func playAudio(url: URL) {
        if isPlaying {
            // 停止播放
            audioPlayer?.stop()
            isPlaying = false
            print("⏸️ 停止播放语音")
        } else {
            // 开始播放
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                audioPlayer = player
                audioPlayerDelegate.onPlaybackFinished = { success in
                    DispatchQueue.main.async {
                        self.isPlaying = false
                        if success {
                            print("✅ 语音播放完成")
                        } else {
                            print("❌ 语音播放异常结束")
                        }
                    }
                }
                
                audioPlayerDelegate.onPlaybackError = { error in
                    DispatchQueue.main.async {
                        self.isPlaying = false
                        if let error = error {
                            self.alertMessage = "语音播放错误: \(error.localizedDescription)"
                            self.showingAlert = true
                            print("❌ 语音播放错误: \(error.localizedDescription)")
                        }
                    }
                }
                
                player.delegate = audioPlayerDelegate
                
                if player.play() {
                    isPlaying = true
                    print("▶️ 开始播放语音: \(url.lastPathComponent)")
                } else {
                    alertMessage = "语音播放失败"
                    showingAlert = true
                    print("❌ 语音播放失败")
                }
            } catch {
                alertMessage = "无法播放语音文件: \(error.localizedDescription)"
                showingAlert = true
                print("❌ 创建音频播放器失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func cleanupAudioResources() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        print("🧹 清理媒体展示组件音频资源")
    }
}

// MARK: - 图片详情查看视图
struct ImageDetailView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZoomableImageView(image: image)
                .background(Color.black)
                .navigationTitle("照片详情")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.white)
                    }
                }
        }
    }
}

// MARK: - 可缩放图片视图
struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let imageView = UIImageView(image: image)
        
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        // 设置约束使图片居中
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
    }
} 