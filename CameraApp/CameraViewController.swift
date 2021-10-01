//
//  CameraViewController.swift
//  CameraApp
//
//  Created by Masato Takamura on 2021/10/01.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {

    //デバイスからのI/Oを管理する
    private var captureSession: AVCaptureSession = .init()
    //メインカメラの管理オブジェクト
    private var mainCamera: AVCaptureDevice?
    //インカメラの管理オブジェクト
    private var innerCamera: AVCaptureDevice?
    //現在使用しているカメラの管理オブジェクト
    private var currentDevice: AVCaptureDevice?
    //出力データを取得するオブジェクト
    private var output: AVCapturePhotoOutput = .init()
    //プレビュー表示用のレイヤー
    private var previewLayer: AVCaptureVideoPreviewLayer = .init()
    //シャッター時の設定
    let settings: AVCapturePhotoSettings = .init()

    private lazy var captureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .white
        button.addTarget(
            self,
            action: #selector(capture(_:)),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var xButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onTapXButton(_:))
        )
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayoutConstraints()
        navigationItem.rightBarButtonItem = xButton

        //インプットを行うデバイスを取得し、AVCaptureSessionに追加する
        guard
            let captureDevice = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: captureDevice),
            captureSession.canAddInput(input) && captureSession.canAddOutput(output)
        else { return }
        //AVCaptureSessionにインプットとアウトプットを追加して走らせる
        captureSession.addInput(input)
        captureSession.addOutput(output)
        captureSession.startRunning()

        //出力の品質を示す デフォルトは.high
        captureSession.sessionPreset = .photo

        //アウトプット前のプレビュー表示の設定
        previewLayer = .init(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(previewLayer, at: 0)

        //キャプチャを行う際の設定
        settings.flashMode = .auto



    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //sessionの停止
        captureSession.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.layer.cornerRadius = captureButton.frame.size.width / 2
    }

}

//MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    ///撮影された画像データが生成されたときに呼ばれる
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard
            let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData)
        else { return }
        //imageの処理
        //videoGravityで指定したように、画像のサイズが変更されているので、調整する
        var originalSize: CGSize
        //画像が左向きもしくは右向きの時を考慮する(つまり横向き)
        if image.imageOrientation == .left || image.imageOrientation == .right {
            originalSize = CGSize(width: image.size.height, height: image.size.width)
        } else {
            originalSize = image.size
        }
        //切り抜きたい範囲を設定
        let metaRect = previewLayer.metadataOutputRectConverted(fromLayerRect: view.frame)
        let cropRect: CGRect = CGRect(
            x: metaRect.origin.x * originalSize.width,
            y: metaRect.origin.y * originalSize.height,
            width: metaRect.size.width * originalSize.width,
            height: metaRect.size.height * originalSize.height
        ).integral

        //このRectでクロップする
        guard
            let cgImage = image.cgImage?.cropping(to: cropRect)
        else { return }
        let croppedImage = UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )

        //写真ライブラリに画像を保存する
        UIImageWriteToSavedPhotosAlbum(
            croppedImage,
            nil,
            nil,
            nil
        )

    }
}

private extension CameraViewController {
    func setupLayoutConstraints() {
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.heightAnchor.constraint(equalToConstant: 60),
            captureButton.widthAnchor.constraint(equalToConstant: 60),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

@objc
private extension CameraViewController {
    func capture(_ sender: UIButton) {
        output.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }

    func onTapXButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

