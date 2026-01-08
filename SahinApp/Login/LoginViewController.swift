//
//  LoginViewController.swift
//  SahinApp
//
//  Created by Sahin on 09/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupLoginButton()
        setupTextFields()
        imageView.image = UIImage(named: "icon")
        imageView.contentMode = .scaleAspectFit
        passwordTextField.isSecureTextEntry = true
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
    
    func setupLoginButton() {
        loginBtn.layer.cornerRadius = 16
        loginBtn.backgroundColor = .white
        loginBtn.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0), for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginBtn.layer.shadowColor = UIColor.black.cgColor
        loginBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        loginBtn.layer.shadowRadius = 8
        loginBtn.layer.shadowOpacity = 0.2
    }
    
    func setupTextFields() {
        // Email Text Field
        emailTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        emailTextField.layer.cornerRadius = 12
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        if let placeholder = emailTextField.placeholder {
            emailTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextField.rightViewMode = .always
        
        // Password Text Field
        passwordTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.font = UIFont.systemFont(ofSize: 16)
        if let placeholder = passwordTextField.placeholder {
            passwordTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextField.rightViewMode = .always
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {

        // i use email validation to only accept valid emails as well as use signIn function within firebase auth library to communiate to database and push my view if no errors occur to the home view controller.
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)

        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error == nil {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                viewController.isModalInPresentation = true
                viewController.modalPresentationStyle = .fullScreen
                userDefaults.setValue(true, forKey: "appFirstTimeOpened")
                self.present(viewController, animated: true, completion: nil)
            } else if emailTest.evaluate(with: self.emailTextField.text) == false || error != nil {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
