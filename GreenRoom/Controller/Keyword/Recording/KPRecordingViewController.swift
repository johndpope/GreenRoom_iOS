//
//  PracticeInterviewViewController.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/08/28.
//

import UIKit
import AVFoundation
import Speech

class KPRecordingViewController: BaseViewController{
    //MARK: - Properties
    let viewmodel: KeywordViewModel!
    var questions: [String]!
    var urls = [URL]()
    
    var player: AVAudioPlayer?
    
    private let fileManager = FileManager.default
    
    // 녹화를 위한 객체
    private var captureSession: AVCaptureSession?
    private var captureDevice: AVCaptureDevice?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var moviFileOutput: AVCaptureMovieFileOutput!
    
    // 녹음을 위한 객체
    private var audioRecorder: AVAudioRecorder?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "ko-KR")) // 한국말 Recognizer 생성
    //음성인식요청을 처리하는 객체
    private var recognizerRequest: SFSpeechURLRecognitionRequest?
    
    private let preView = UIView()
    
    private let darkView = CustomDarkView()
    
    private let questionLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .sfPro(size: 22, family: .Semibold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let keywordLabel = UILabel().then {
        $0.textColor = .mainColor
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .sfPro(size: 22, family: .Semibold)
        $0.text = "천진난만   현실적   적극적    성실함    긍정적"
    }
    
    private let recordingButton = CustomRecordingButton(type: .system).then {
        $0.setTitle("촬영", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    //MARK: - Init
    init(viewmodel: KeywordViewModel){
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        switch self.viewmodel.recordingType {
        case .camera: setupCaptureSession()
        case .mike: setupAVAudio()
        }
        
        self.keywordLabel.isHidden = true
        self.questionLabel.isHidden = true
        self.recordingButton.isHidden = true
        self.darkView.keywordLabel.isHidden = self.viewmodel.keywordOnOff == true ? false : true
    }
    
    override func setupBinding() {
        viewmodel.selectedQuestionObservable
            .take(1)
            .subscribe(onNext: { questions in
                self.darkView.questionLabel.text = "Q1\n\n\(questions[0])"
                self.questionLabel.text = "Q1\n\n\(questions[0])"
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc func didClickRecordingButton(_ sender: UIButton) {
        switch viewmodel.recordingType {
        case .camera : self.videoRecording()
        case .mike: self.audioRecording()
        }
    }
    
    // 비디오 녹화시
    func videoRecording() {
        if moviFileOutput.isRecording {
            moviFileOutput.stopRecording() //녹화 중단
            self.darkView.isHidden = false
            self.keywordLabel.isHidden = true
            self.questionLabel.isHidden = true
            self.recordingButton.isHidden = true
        } else {
            self.darkView.isHidden = true
            self.keywordLabel.isHidden = self.viewmodel.keywordOnOff == true ? false : true
            self.questionLabel.isHidden = false
            self.recordingButton.isHidden = false
            startRecording() //녹화 녹음시작
        }
    }
    
    func audioRecording() {
        if let recorder: AVAudioRecorder = self.audioRecorder {
            if recorder.isRecording { // 현재 녹음 중이므로, 녹음 정지
                recorder.stop()
                self.darkView.isHidden = false
                self.keywordLabel.isHidden = true
                self.questionLabel.isHidden = true
                self.recordingButton.isHidden = true
            } else { // 녹음 시작
                recorder.record()
                self.darkView.isHidden = true
                self.keywordLabel.isHidden = self.viewmodel.keywordOnOff == true ? false : true
                self.questionLabel.isHidden = false
                self.recordingButton.isHidden = false
            }
        }
    }
    
    private func saveURL(_ url: URL) {
        urls.append(url)
        // 길게 녹화할경우 음성이 녹음 안되는 현상이 있음 (이유 찾아 고쳐야함) 2번의 오류도 1번이 해결되면 해결될 가능성 있음
        // 녹화일 경우 mp4 -> m4a로 변환이 필요함 ( 영상이 십몇초를 넘을경우 변환이 안되는 오류 )
        
//        self.recognizerRequest = SFSpeechURLRecognitionRequest(url: url)
//        self.speechRecognizer?.recognitionTask(with: recognizerRequest!) { (result,error) in
//            guard let result = result else { return }
//            // 번역본
//            if result.isFinal {
//                print("Speech in the file is \(result.bestTranscription.formattedString)")
//            }
//        }
        
        if urls.count >= viewmodel.selectedQuestionObservable.value.count {
            if viewmodel.keywordOnOff{
                viewmodel.videoURLs = urls
                self.navigationController?.pushViewController(KPFinishViewController(viewmodel: viewmodel), animated: true)
            }else {
                viewmodel.videoURLs = urls
                self.navigationController?.pushViewController(KPDetailViewController(viewmodel: viewmodel), animated: true)
            }
        } else {
            viewmodel.selectedQuestionObservable
                .take(1)
                .subscribe(onNext: { questions in
                    self.darkView.questionLabel.text = "Q1\n\n\(questions[self.urls.count])"
                    self.questionLabel.text = "Q1\n\n\(questions[self.urls.count])"
                }).disposed(by: disposeBag)
        }
    }
    
    //MARK: - ConfigureUI
    override func configureUI() {
        self.view.addSubview(preView)
        preView.snp.makeConstraints{ make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.preView.addSubview(self.darkView)
        self.darkView.startButton.addTarget(self, action: #selector(didClickRecordingButton(_:)), for: .touchUpInside)
        self.darkView.snp.makeConstraints{ make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.preView.addSubview(recordingButton)
        recordingButton.addTarget(self, action: #selector(didClickRecordingButton(_:)), for: .touchUpInside)
        recordingButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-47)
            make.width.height.equalTo(84)
        }
        
        self.preView.addSubview(self.questionLabel)
        self.questionLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(77)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
        }

        self.preView.addSubview(self.keywordLabel)
        self.keywordLabel.snp.makeConstraints{ make in
            make.bottom.equalTo(self.recordingButton.snp.top).offset(-46)
            make.leading.equalToSuperview().offset(56)
            make.trailing.equalToSuperview().offset(-56)
        }
    }
}

//MARK: - AVFoundation (녹화)관련
extension KPRecordingViewController: AVCaptureFileOutputRecordingDelegate {
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo // set resoultion
        
        let cameras = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera , .builtInDualCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        
        let camera = cameras.devices.filter{ $0.position == .front }.first! // 전방 카메라
        
        captureDevice = camera
        
        do {
            //오디오 장치
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession!.canAddInput(audioInput){
                captureSession?.addInput(audioInput)
            }
            
            //비디오 장치
            let videoInput = try AVCaptureDeviceInput(device: camera)
            moviFileOutput = AVCaptureMovieFileOutput()
            if captureSession!.canAddInput(videoInput) && captureSession!.canAddOutput(moviFileOutput) {
                captureSession?.addInput(videoInput)
                captureSession?.addOutput(moviFileOutput)
                // 여기에서 preview 세팅하는 함수 호출
                setupLivePreview()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupLivePreview() {
        // previewLayer 세팅
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = .portrait
        
        // UIView객체인 preView 위 객체 입힘
        preView.layer.insertSublayer(videoPreviewLayer!, at: 0)  // 맨 앞(0번쨰로)으로 가져와서 보이게끔 설정
        DispatchQueue.main.async {
            self.videoPreviewLayer?.frame = self.preView.bounds
        }
        
        // preview까지 준비되었으니 captureSession을 시작하도록 설정
        startCaptureSession()
    }
    
    private func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    // Recording Methods
    private func startRecording() {
        moviFileOutput.startRecording(to: tempURL(extn: "mp4"), recordingDelegate: self)
    }
    
    private func tempURL(extn: String)-> URL{
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let directoryURL = tempDirectoryURL.appendingPathComponent("NewDirectory")
        
        // 폴더 없으면 폴더 생성
        if !fileManager.fileExists(atPath: directoryURL.path){
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false)
            }catch let error {
                print(error.localizedDescription)
            }
        }
        
        return directoryURL.appendingPathComponent("test\(urls.count+1).\(extn)")    // 파일이 저장될 경로
    }
    
    //레코딩 시작시 호출
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("녹화시작")
    }
    
    //레코딩 끝날시 호출 시작할때 파라미터로 입력한 url 기반으로 저장 작업 수행
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.saveURL(outputFileURL)
    }
}

//MARK: - AVFoundation (녹음)관련
extension KPRecordingViewController: AVAudioRecorderDelegate {
    private func setupAVAudio(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record)
            try audioSession.setMode(.measurement)
            try audioSession.setActive(true)
                                         
        } catch let error{
            print("Failed to set audio session category")
            print(error.localizedDescription)
        }
        
        let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                AVEncoderBitRateKey: 320_000,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44_100.0,
            ]

        self.audioRecorder = try? AVAudioRecorder(url: tempURL(extn: "m4a"), settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.prepareToRecord()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.saveURL(recorder.url)
    }
}
