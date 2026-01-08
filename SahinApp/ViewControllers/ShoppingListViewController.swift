//
//  ShoppingListViewController.swift
//  SahinApp
//
//  Created by Sahin on 31/03/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct List {
    var item: String!
}

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // i create an empty array of strings to hold my values i pass in from my didselectrowat function in homeviewcontroller. it comes from the database. Also creat my ui elements.
    var data = [List]()
    var ref: DatabaseReference!
    var navigationBar: UINavigationBar = UINavigationBar()
    let tableView = UITableView()
    let button = UIButton(type: UIButton.ButtonType.custom)
    let button2 = UIButton(type: UIButton.ButtonType.custom)
    let button3 = UIButton()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 100, right: 0)
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 12
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        self.tableView.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: ShoppingListTableViewCell.customCell)
        setupButton()
        setupClearButton()
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.populateTableView()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @objc func refreshTableView(sender: Any) {
        self.data.removeAll()
        self.populateTableView()
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    func populateTableView() {
        ref = Database.database().reference()
        
        ref.child("users").child("list").queryLimited(toLast: 20).observe(.childAdded, with: { (snapshot) in
            
            if let valueDictionary = snapshot.value as? [AnyHashable:String]
            {
                let item = valueDictionary["value"]
                self.data.insert(List(item: item), at: 0)
                //Reload your tableView
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func setupClearButton() {
        let button3:UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        button3.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        button3.setTitle("CLEAR LIST", for: .normal)
        button3.setTitleColor(.white, for: .normal)
        button3.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button3.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button3)
        button3.layer.cornerRadius = 16
        button3.layer.shadowColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.4).cgColor
        button3.layer.shadowOffset = CGSize(width: 0, height: 4)
        button3.layer.shadowRadius = 8
        button3.layer.shadowOpacity = 0.3
        button3.addTarget(self, action: #selector(removeData), for: .touchUpInside)
        button3.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 25).isActive = true
        button3.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -25).isActive = true
        button3.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 20).isActive = true
        button3.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        button3.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
    @objc func removeData() {
        Database.database().reference().child("users").child("list").removeValue()
        self.dismiss(animated: true, completion: nil)
        self.data.removeAll()
        self.tableView.reloadData()
    }
    
    func setupButton() {
        let image = UIImage(named: "closeIcon")
        button.frame = CGRect(x: 60, y: 60, width: 60, height: 60)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(buttonSelector), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc func buttonSelector() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    @objc func buttonTwoSelector() {
        let viewController = AddItemViewController()
        self.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListTableViewCell.customCell, for: indexPath) as! ShoppingListTableViewCell
        cell.itemLabel.text = data[indexPath.row].item
        if self.data.count > 2 {
            Database.database().reference().child("users").child("listNumber").setValue(1)
        }
        return cell
    }
}
