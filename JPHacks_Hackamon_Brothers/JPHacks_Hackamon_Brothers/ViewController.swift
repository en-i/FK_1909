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
    
    var notification_with_tool = NotificationWithTool()
    
    // 判定結果を格納する変数
    var judgeResult = ""
    // 正解数をカウントする変数
    var trueCount = 0
    // 不正解の数をカウントする変数
    var falseCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startCapture()
    }
    
    // カメラキャプチャの開始
    private func startCapture() {
        let captureSession = AVCaptureSession()
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
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
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
            }
        }
        
        // 正解，不正解を判断するメソッド
        func judgeMethod() {
            // コンロを認識しているかを判断する
            if judgeResult.contains("Stove") {
                falseCount = 0
                trueCount += 1
                if trueCount <= 30 {
                    // 画面遷移
                    print("30以上になりました")
                }
                
                // 机の角を認識しているかを判断する
            } else if judgeResult.contains("Corner") {
                falseCount = 0
                trueCount += 1
                if trueCount <= 30 {
                    // 画面遷移
                    print("30以上になりました")
                }
                
                // それら以外を認識しているかを判断する
            } else {
                falseCount += 1
                
                // 10回連続で”Stove”or"Corner"意外だった場合にtrueCountを初期化する
                if falseCount <= 10 {
                    trueCount = 0
                    print("trueCountを初期化しました")
                    
                }
            }
        }
        
        // CVPixelBufferに対し、画像認識リクエストを実行
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
