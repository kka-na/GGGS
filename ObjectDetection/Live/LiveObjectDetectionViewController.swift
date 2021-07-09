// Copyright (c) 2020 Facebook, Inc. and its affiliates.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import AVFoundation
import UIKit

class LiveObjectDetectionViewController: UIViewController{
    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet var benchmarkLabel: UILabel!
    @IBOutlet var indicator: UIActivityIndicatorView!

    private let delayMs: Double = 1000
    private var prevTimestampMs: Double = 0.0
    private var cameraController = CameraController()
    private var imageViewLive =  UIImageView()
    private var inferencer = ObjectDetector()
    
    var classIdx: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraController.configPreviewLayer(cameraView)
        imageViewLive.frame = CGRect(x: 0, y: 0, width: cameraView.frame.size.width, height: cameraView.frame.size.height)
        cameraView.addSubview(imageViewLive)
        
        cameraController.videoCaptureCompletionBlock = { [weak self] buffer, error in
            guard let strongSelf = self else { return }
            if error != nil {
                return
            }
            guard var pixelBuffer = buffer else { return }
            
            let currentTimestamp = CACurrentMediaTime()
            if (currentTimestamp - strongSelf.prevTimestampMs) * 1000 <= strongSelf.delayMs { return }
            strongSelf.prevTimestampMs = currentTimestamp
            let startTime = CACurrentMediaTime()
            guard let outputs = self?.inferencer.module.detect(image: &pixelBuffer) else {
                return
            }
            let inferenceTime = CACurrentMediaTime() - startTime
                
            DispatchQueue.main.async {
                let ivScaleX : Double =  Double(strongSelf.imageViewLive.frame.size.width / CGFloat(PrePostProcessor.inputWidth))
                let ivScaleY : Double = Double(strongSelf.imageViewLive.frame.size.height / CGFloat(PrePostProcessor.inputHeight))

                let startX = Double((strongSelf.imageViewLive.frame.size.width - CGFloat(ivScaleX) * CGFloat(PrePostProcessor.inputWidth))/2)
                let startY = Double((strongSelf.imageViewLive.frame.size.height -  CGFloat(ivScaleY) * CGFloat(PrePostProcessor.inputHeight))/2)
                
                let nmsPredictions = PrePostProcessor.outputsToNMSPredictions(outputs: outputs, imgScaleX: 1.0, imgScaleY: 1.0, ivScaleX: ivScaleX, ivScaleY: ivScaleY, startX: startX, startY: startY)

                PrePostProcessor.cleanDetection(imageView: strongSelf.imageViewLive)
                strongSelf.indicator.isHidden = true
                strongSelf.benchmarkLabel.isHidden = false
                strongSelf.benchmarkLabel.text = String(format: "%.2fms", 1000*inferenceTime)
                
                
                for pred in nmsPredictions {
                    let bbox = UIView(frame: pred.rect)
                    bbox.backgroundColor = UIColor.init(white: 1.0, alpha: 0.5)
                    bbox.layer.borderColor = CGColor.init(red: 0.53, green: 0.99, blue: 0.51, alpha: 1.0)
                    bbox.layer.borderWidth = 2
                   
                    let gesture = MyTapGesture(target: strongSelf, action: #selector(strongSelf.handleTap(sender:)))
                    gesture.clss = pred.classIndex
                    bbox.isUserInteractionEnabled = true
                    strongSelf.imageViewLive.isUserInteractionEnabled = true
                    bbox.addGestureRecognizer(gesture)
                    strongSelf.imageViewLive.addSubview(bbox)

                    let textLayer = CATextLayer()
                    textLayer.string = String(format: " %@ %.2f", strongSelf.inferencer.classes[pred.classIndex], pred.score)
                    textLayer.foregroundColor = UIColor.white.cgColor
                    textLayer.backgroundColor = CGColor.init(red: 0.58, green: 0.50, blue: 1.0, alpha: 1.0)
                    textLayer.fontSize = 14
                    textLayer.frame = CGRect(x: pred.rect.origin.x, y: pred.rect.origin.y, width:100, height:20)
                    strongSelf.imageViewLive.layer.addSublayer(textLayer)
                }
                
                
                //PrePostProcessor.showDetection(imageView: strongSelf.imageViewLive, nmsPredictions: nmsPredictions, classes: strongSelf.inferencer.classes)
                
            }
            
        }
        
    }
    @IBAction func handleTap(sender: MyTapGesture){
        let class_idx:Int = sender.clss
        let vc = SecondaryViewController(nibName: "SecondaryViewController", bundle: nil)
        vc.idx = class_idx
        navigationController?.pushViewController(vc, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        cameraController.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraController.stopSession()
    }

    @IBAction func onBackClicked(_: Any) {
        navigationController?.popViewController(animated: true)
    }
}

class MyTapGesture: UITapGestureRecognizer{
    var clss = Int()
}
