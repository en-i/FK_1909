//
//  ViewController.swift
//  JPHacks_Hackamon_Brothers
//
//  Created by 藤山裕輝 on 2019/10/19.
//  Copyright © 2019 藤山裕輝. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

//  画面遷移先を判断するグローバル変数


class ViewController: UIViewController {
    
    // var notification_with_tool = NotificationWithTool()
    
    // 判定結果を格納する変数
    var judgeResult = ""
    // コンロの正解数をカウントする変数
    var trueStoveCount = 0
    // 机の正解数をカウントする変数
    var trueDeskCount = 0
    // 不正解の数をカウントする変数
    var falseCount = 0
    // キャラクターのコメントを入れる配列
    var characterCommentArray = ["ぼくをさがしてね！","はやくみつけてよ〜！", "こっちこっち〜！","まだ〜？"]
    // コメントに合ったキャラクターを管理する配列
    var characterImageArray = ["happy_bear.png","surprise_bear.png","dance_bear2.png","sad_bear.png"]
    
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var visibleCharacterImage: UIImageView!
    
    // AVCaptureSessionをインスタンス化
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visibleCharacterImage.isHidden = true
        nowView = 1
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.timeUpdate), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
        startCapture()
    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "toHomeViewController", sender: nowView = 0)
        captureSession.stopRunning()
    }
    
    // 出現したキャラクターのタッチイベント
    @IBAction func characterTapEvent(_ sender: Any) {
        if trueStoveCount >= 40 {
            performSegue(withIdentifier: "toDetailViewController", sender: currentJudge = "Stove")
        } else if trueDeskCount >= 40 {
            performSegue(withIdentifier: "toDetailViewController", sender: currentJudge = "Desk")
        }
    }
    
    // キャラクターコメントを指定するメソッド
    @objc func timeUpdate() {
        // ランダムでキャラクターのコメントを出すための配列番号を管理する変数
        let commentManager = Int.random(in: 0...3)
        characterImage.image = UIImage(named: characterImageArray[commentManager])
        commentLabel.text = characterCommentArray[commentManager]
    }
    
    // カメラキャプチャの開始
    private func startCapture() {
        captureSession.sessionPreset = .photo
        
        // 入力の指定
        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: captureDevice),
            captureSession.canAddInput(input) else {
                assertionFailure("Error: 入力デバイスを追加できませんでした")
                return
        }
        
        captureSession.addInput(input)
        
        // 出力の指定
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        
        guard captureSession.canAddOutput(output) else {
            assertionFailure("Error: 出力デバイスを追加できませんでした")
            return
        }
        captureSession.addOutput(output)
        
        // プレビューの指定
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        // キャプチャ開始
        
        captureSession.startRunning()
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // CMSampleBufferをCVPixelBufferに変換
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            assertionFailure("Error: バッファの変換に失敗しました")
            return
        }
        
        // CoreMLのモデルクラスの初期化
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else {
            assertionFailure("Error: CoreMLモデルの初期化に失敗しました")
            return
        }
        
        // 画像認識リクエストを作成（引数はモデルとハンドラ）
        let request = VNCoreMLRequest(model: model) { [weak self] (request: VNRequest, error: Error?) in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            // 判別結果とその確信度を上位3件まで表示
            // identifierは類義語がカンマ区切りで複数書かれていることがあるので、最初の単語のみ取得する
            self!.judgeResult = results.prefix(1).compactMap { "\(Int($0.confidence * 100))% \($0.identifier.components(separatedBy: ", ")[0])" }.joined(separator: "\n")
            
            DispatchQueue.main.async() {
                judgeMethod()
                print(self!.judgeResult)
            }
        }
        
        // 正解，不正解を判断するメソッド
        func judgeMethod() {
            // コンロを認識しているかを判断する
            if judgeResult.contains("Stove") {
                //falseCount = 0
                trueDeskCount = 0
                trueStoveCount += 1
                if trueStoveCount >= 40 {
                    // キャラクターを出す
                    visibleCharacterImage.isHidden = false
                    print("コンロが40以上になりました")
                }
                
                // 机の角を認識しているかを判断する
            } else if judgeResult.contains("Corner") {
                //falseCount = 0
                trueStoveCount = 0
                trueDeskCount += 1
                if trueDeskCount >= 40 {
                    // キャラクターを出す
                    visibleCharacterImage.isHidden = false
                    print("机が40以上になりました")
                }
                
                // それら以外を認識しているかを判断する
            } else {
                falseCount += 1
                // 15回連続で”Stove”or"Corner"意外だった場合にtrueCountを初期化する
                if falseCount >= 15 {
                    // キャラクターを隠す
                    visibleCharacterImage.isHidden = true
                    trueStoveCount = 0
                    trueDeskCount = 0
                    print("trueCountを初期化しました")
                    
                }
            }
        }
        
        // CVPixelBufferに対し、画像認識リクエストを実行
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
