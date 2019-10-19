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

class ViewController: UIViewController {

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
            let displayText = results.prefix(1).compactMap { "\(Int($0.confidence * 100))% \($0.identifier.components(separatedBy: ", ")[0])" }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                print(displayText)
            }
        }
        
        // CVPixelBufferに対し、画像認識リクエストを実行
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
