//
//  SignUpViewController.swift
//  SahinApp
//
//  Created by Sahin on 09/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var signupButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupSignUpButton()
        setupTextFields()
        imageView.image = UIImage(named: "icon")
        imageView.contentMode = .scaleAspectFit
        passwordTextfield.isSecureTextEntry = true
        // Do any additional setup after loading the view.
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
    
    func setupSignUpButton() {
        signupButton.layer.cornerRadius = 16
        signupButton.backgroundColor = .white
        signupButton.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0), for: .normal)
        signupButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signupButton.layer.shadowColor = UIColor.black.cgColor
        signupButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        signupButton.layer.shadowRadius = 8
        signupButton.layer.shadowOpacity = 0.2
    }
    
    func setupTextFields() {
        // Email Text Field
        emailTextfield.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        emailTextfield.layer.cornerRadius = 12
        emailTextfield.layer.borderWidth = 1
        emailTextfield.layer.borderColor = UIColor.white.cgColor
        emailTextfield.font = UIFont.systemFont(ofSize: 16)
        if let placeholder = emailTextfield.placeholder {
            emailTextfield.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
        emailTextfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextfield.leftViewMode = .always
        emailTextfield.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextfield.rightViewMode = .always
        
        // Password Text Field
        passwordTextfield.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        passwordTextfield.layer.cornerRadius = 12
        passwordTextfield.layer.borderWidth = 1
        passwordTextfield.layer.borderColor = UIColor.white.cgColor
        passwordTextfield.font = UIFont.systemFont(ofSize: 16)
        if let placeholder = passwordTextfield.placeholder {
            passwordTextfield.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
        passwordTextfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextfield.leftViewMode = .always
        passwordTextfield.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextfield.rightViewMode = .always
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    

    @IBAction func signUpTapped(_ sender: Any) {

        //same as login, validation and i use the createUser method in firebase auth to add a user to the database and present my home view controller once completed.
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        
    Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!){ (user, error) in
        if error == nil {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            viewController.isModalInPresentation = true
            viewController.modalPresentationStyle = .fullScreen
            userDefaults.setValue(true, forKey: "appFirstTimeOpened")
            self.present(viewController, animated: true, completion: nil)
        } else if emailTest.evaluate(with: self.emailTextfield.text) == false || error != nil {
            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
