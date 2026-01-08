//
//  StartViewController.swift
//  SahinApp
//
//  Created by Sahin on 09/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupButtons()
        imageView.image = UIImage(named: "icon")
        imageView.contentMode = .scaleAspectFit
    }
    
    func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    func setupButtons() {
        // Sign Up Button
        signupBtn.layer.cornerRadius = 16
        signupBtn.backgroundColor = .white
        signupBtn.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0), for: .normal)
        signupBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signupBtn.layer.shadowColor = UIColor.black.cgColor
        signupBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        signupBtn.layer.shadowRadius = 8
        signupBtn.layer.shadowOpacity = 0.2
        
        // Login Button
        loginBtn.layer.cornerRadius = 16
        loginBtn.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginBtn.layer.borderWidth = 2
        loginBtn.layer.borderColor = UIColor.white.cgColor
    }
}
