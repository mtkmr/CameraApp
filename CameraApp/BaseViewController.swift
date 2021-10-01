//
//  BaseViewController.swift
//  CameraApp
//
//  Created by Masato Takamura on 2021/10/01.
//

import UIKit

final class BaseViewController: UIViewController {

    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.addTarget(
            self,
            action: #selector(onTapCameraButton(_:)),
            for: .touchUpInside
        )
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayoutConstraints()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraButton.layer.cornerRadius = cameraButton.frame.size.width / 2
    }


}

private extension BaseViewController {
    func setupLayoutConstraints() {
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraButton)
        NSLayoutConstraint.activate([
            cameraButton.heightAnchor.constraint(equalToConstant: 50),
            cameraButton.widthAnchor.constraint(equalToConstant: 50),
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }
}

@objc
private extension BaseViewController {
    func onTapCameraButton(_ sender: UIButton) {
        let cameraVC = CameraViewController()
        let nav = UINavigationController(rootViewController: cameraVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}
