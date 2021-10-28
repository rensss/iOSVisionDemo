//
//  ViewController.swift
//  VisionDemo
//
//  Created by Rzk on 2021/9/27.
//

import UIKit
import PhotosUI
import AVFoundation
import Vision
import TZImagePickerController
import PureLayout

class ViewController: UIViewController {
    
    var selectImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let b = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        view.addSubview(b)
        b.setTitle("select", for: .normal)
        b.backgroundColor = .purple
        b.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        
        let c = UIButton(frame: CGRect(x: 220, y: 100, width: 100, height: 50))
        view.addSubview(c)
        c.setTitle("vision", for: .normal)
        c.backgroundColor = .red
        c.addTarget(self, action: #selector(startVision), for: .touchUpInside)
        
        view.addSubview(imageView)
        imageView.autoPinEdge(.top, to: .bottom, of: b, withOffset: 20)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
    }
    
    // MARK:- func
    func detectImage(image: UIImage?) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let image = image, let convertImage = CIImage.init(image: image) else { return }
        // 处理与单个图像有关的一个或多个图像分析请求的对象
        let detectRequestHandler = VNImageRequestHandler.init(ciImage: convertImage)
        // 在图像中查找可见文本区域的图像分析请求
        let detectRequest = VNDetectTextRectanglesRequest { request, error in
            if let observations = request.results {
                self.textRectangles(observations: observations, image: image, true) { values in
                    self.cleanImage()
                    debugPrint(observations.count)
                    // 要执行的代码
                    let endTime = CFAbsoluteTimeGetCurrent()
                    debugPrint("---- 识别时长：\((endTime - startTime)*1000) 毫秒")
                    for value in values {
                        self.imageView.addSubview(self.drawRectangle(rect: value.cgRectValue, color: .red))
                    }
                }
            }
        }
        detectRequest.reportCharacterBoxes = true
        
        let recognizeRequest = VNRecognizeTextRequest { request, error in
            if let observations = request.results {
                self.textRectangles(observations: observations, image: image, true) { values in
                    self.cleanImage()
                    debugPrint(observations.count)
                    // 要执行的代码
                    let endTime = CFAbsoluteTimeGetCurrent()
                    debugPrint("---- 识别时长：\((endTime - startTime)*1000) 毫秒")
                    for value in values {
                        self.imageView.addSubview(self.drawRectangle(rect: value.cgRectValue, color: .red))
                    }
                }
            }
        }
        recognizeRequest.usesLanguageCorrection = true
        recognizeRequest.recognitionLevel = .accurate
        recognizeRequest.recognitionLanguages = ["zh-Hans", "en-US"]
        
        
        do {
            try detectRequestHandler.perform([recognizeRequest])
//            try detectRequestHandler.perform([detectRequest])
            let array = try recognizeRequest.supportedRecognitionLanguages()
            debugPrint("---- supportLanguageArray : \(String(describing: array))")
        } catch {
            debugPrint(#file, #line, #function, error)
        }
    }
    
    func textRectangles(observations: [VNObservation], image: UIImage, _ needCharacter: Bool = false, complete:(([NSValue]) -> Void)? = nil) {
        var tempArray: [NSValue] = []
        for observation in observations {
            // 文字内容识别
            if let recognizeObservations = observation as? VNRecognizedTextObservation {
                guard let candidate = recognizeObservations.topCandidates(1).first else { continue }
                debugPrint(candidate.string)
            }
            
            if let textObservation = observation as? VNRecognizedTextObservation {
                let box = textObservation.boundingBox
                let imageRect = self.frame(for: self.imageView.image!, inImageViewAspectFit: self.imageView)
                let imageSize = imageRect.size
                var borderRect = self.getRect(coverRect: box, imageSize: imageSize)
                borderRect.origin.x += imageRect.origin.x
                borderRect.origin.y += imageRect.origin.y
                tempArray.append(NSValue(cgRect: borderRect))
            }
            
            // character 文字检测
            if let textObservation = observation as? VNTextObservation {
                if needCharacter {
                    for box in textObservation.characterBoxes ?? [] {
                        let imageSize = self.frame(for: self.imageView.image!, inImageViewAspectFit: self.imageView).size
                        let rect = self.getRect(coverRect: box.boundingBox, imageSize: imageSize)
                        tempArray.append(NSValue(cgRect: rect))
                    }
                } else {
                    let box = textObservation.boundingBox
                    let imageSize = self.frame(for: self.imageView.image!, inImageViewAspectFit: self.imageView).size
                    let rect = self.getRect(coverRect: box, imageSize: imageSize)
                    tempArray.append(NSValue(cgRect: rect))
                }
            }
        }
        complete?(tempArray)
    }
    
    func getRect(coverRect: CGRect, imageSize: CGSize) -> CGRect {
        let w = coverRect.size.width * imageSize.width
        let h = coverRect.size.height * imageSize.height
        let x = coverRect.origin.x * imageSize.width
        let y = imageSize.height - (coverRect.origin.y * imageSize.height) - h
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func drawRectangle(rect: CGRect, color: UIColor) -> UIView {
        let v = UIView(frame: rect)
        v.layer.borderColor = color.cgColor
        v.layer.borderWidth = 1.0
        return v
    }
    
    func cleanImage() {
        _ = imageView.subviews.map { sub in
            sub.removeFromSuperview()
        }
    }
    
    func findOriginalImageData(_ asset: PHAsset) {
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .opportunistic
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOption) { imageData, uti, orientation, dictionary in
            
            if let imageData = imageData {
                self.cleanImage()
                self.imageView.image = UIImage(data: imageData)
            }
            print("uti \n \(uti as Any)")
            print("orientation \n \(orientation.rawValue)")
        }
    }
    
    func frame(for image: UIImage, inImageViewAspectFit imageView: UIImageView) -> CGRect {
      let imageRatio = (image.size.width / image.size.height)
      let viewRatio = imageView.frame.size.width / imageView.frame.size.height
      if imageRatio < viewRatio {
        let scale = imageView.frame.size.height / image.size.height
        let width = scale * image.size.width
        let topLeftX = (imageView.frame.size.width - width) * 0.5
        return CGRect(x: topLeftX, y: 0, width: width, height: imageView.frame.size.height)
      } else {
        let scale = imageView.frame.size.width / image.size.width
        let height = scale * image.size.height
        let topLeftY = (imageView.frame.size.height - height) * 0.5
        return CGRect(x: 0.0, y: topLeftY, width: imageView.frame.size.width, height: height)
      }
    }
    
    // MARK:- event
    @objc func btnClick() {
//        pickerVc.delegate = self
//        self.present(pickerVc, animated: true, completion: nil)
        
        if let imagePickerVc = TZImagePickerController(maxImagesCount: 1, delegate: self) {
            imagePickerVc.didFinishPickingPhotosHandle = { [weak self] photos, assets, isOriginal in
                if let asset = assets?.first as? PHAsset {
                    self?.findOriginalImageData(asset)
                }
            }
            self.present(imagePickerVc, animated: true, completion: nil)
        }
    }
    
    @objc func startVision() {
        detectImage(image: self.imageView.image)
    }
    
    // MARK:- lazy
    lazy var pickerVc: UIImagePickerController = {
        let p = UIImagePickerController()
        p.allowsEditing = false
        return p
    }()
    
    lazy var imageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        return i
    }()
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            picker.delegate = nil
            picker.dismiss(animated: true, completion: nil)
            
            self.cleanImage()
            
            selectImage = image
            imageView.image = image
            imageView.sizeToFit()
            let point = CGPoint(x: 0, y: 180)
            let size = image.size
            imageView.frame = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
        }
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.editedImage.rawValue)] as? UIImage {
            picker.delegate = nil
            picker.dismiss(animated: true, completion: nil)
            
            self.cleanImage()
            
            selectImage = image
            imageView.image = image
            imageView.sizeToFit()
            let point = CGPoint(x: 0, y: 180)
            let size = image.size
            imageView.frame = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.delegate = nil
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: TZImagePickerControllerDelegate {
    
}
