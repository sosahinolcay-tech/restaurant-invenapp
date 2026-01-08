//
//  AddItemViewController.swift
//  SahinApp
//
//  Created by Sahin on 01/04/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AddItemViewController: UIViewController, UITextFieldDelegate {
    
    let textField = UITextField()
    let textField2 = UITextField()
    let button = UIButton()
    let closeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        view.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField2.delegate = self
        setupTextFields()
        setupButton()
        setupCloseButton()
    }
    
    func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 1.0).cgColor
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
    
    func setupTextFields() {
        self.view.addSubview(textField)
        self.view.addSubview(textField2)
        
        // First text field styling
        textField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        textField.placeholder = "Item number e.g item 1"
        textField.textAlignment = .left
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0).cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        textField.layer.shadowOpacity = 1.0
        textField.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 25).isActive = true
        textField.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -25).isActive = true
        textField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Second text field styling
        textField2.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        textField2.textAlignment = .left
        textField2.placeholder = "Item and quantity e.g eggs 4"
        textField2.translatesAutoresizingMaskIntoConstraints = false
        textField2.isUserInteractionEnabled = true
        textField2.borderStyle = .none
        textField2.backgroundColor = .white
        textField2.layer.cornerRadius = 12
        textField2.layer.borderWidth = 1
        textField2.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0).cgColor
        textField2.font = UIFont.systemFont(ofSize: 16)
        textField2.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField2.leftViewMode = .always
        textField2.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField2.rightViewMode = .always
        textField2.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        textField2.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField2.layer.shadowRadius = 4
        textField2.layer.shadowOpacity = 1.0
        textField2.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 25).isActive = true
        textField2.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -25).isActive = true
        textField2.topAnchor.constraint(equalTo: self.textField.bottomAnchor, constant: 20).isActive = true
        textField2.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
        func setupCloseButton() {
            let image = UIImage(named: "closeIcon")
            closeButton.frame = CGRect(x: 60, y: 60, width: 60, height: 60)
            closeButton.setImage(image, for: .normal)
            closeButton.addTarget(self, action: #selector(buttonSelector), for: .touchUpInside)
            closeButton.backgroundColor = .white
            closeButton.layer.cornerRadius = 30
            closeButton.layer.shadowColor = UIColor.black.cgColor
            closeButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            closeButton.layer.shadowRadius = 8
            closeButton.layer.shadowOpacity = 0.3
            self.view.addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false

            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
            closeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            closeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
    
    func setupButton() {
        let button:UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        button.setTitle("ADD ITEM", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.4).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(addData), for: .touchUpInside)
        button.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 25).isActive = true
        button.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -25).isActive = true
        button.topAnchor.constraint(equalTo: self.textField2.bottomAnchor, constant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
    @objc func addData() {
//        Database.database().reference().child("users").child("items").observe(.value) { snapshot in
//            let snapshot = snapshot.value as? NSDictionary
//            print(snapshot)
//            if let item1 = snapshot?["item 1"] as? String {
//                if let item2 = snapshot?["item 2"] as? String {
//                    print(item1)
//                    print(item2)
//                    if !self.detailViewController.data.contains(item2) && !self.detailViewController.data.contains(item1) {
//                        self.detailViewController.data.append(item1)
//                        self.detailViewController.data.append(item2)
//                    } else {
//                        let alert = UIAlertController(title: "Alert", message: "This item number already exists", preferredStyle: UIAlertController.Style.alert)
//                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
//            }
//        }
        Database.database().reference().child("users").child("items").observe(.value) { snapshot in
            let value = snapshot.value as? [String:AnyObject]
            if (value?.description.contains(self.textField2.text?.lowercased() ?? "N/A") ?? false)  {
                let alert = UIAlertController(title: "Alert", message: "This item already exists", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                Database.database().reference().child("users").child("items").child(self.textField.text?.lowercased() ?? "").child("value").setValue(self.textField2.text?.lowercased())
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func buttonSelector() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonClicked() {
        print("Button Clicked")
    }

}

extension UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
