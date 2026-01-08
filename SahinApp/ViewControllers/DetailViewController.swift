//
//  DetailViewController.swift
//  SahinApp
//
//  Created by Sahin on 13/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct Foods {
    let food: String!
}

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // i create an empty array of strings to hold my values i pass in from my didselectrowat function in homeviewcontroller. it comes from the database. Also creat my ui elements.
    var data = [Foods]()
    var filteredData = [Foods]()
    var ref: DatabaseReference!
    var navigationBar: UINavigationBar = UINavigationBar()
    let tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)
    let button = UIButton(type: UIButton.ButtonType.custom)
    let button2 = UIButton(type: UIButton.ButtonType.custom)
    let filterButton = UIBarButtonItem()
    let refreshControl = UIRefreshControl()
    var value = 1
    var isSearching = false
    var selectedCategory: String? = nil

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
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: DetailTableViewCell.customCell)
        setupSearchController()
        setupFilterButton()
        setupButton()
        addButton()
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search items..."
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setupFilterButton() {
        filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        filterButton.target = self
        filterButton.action = #selector(filterButtonTapped)
        navigationItem.rightBarButtonItem = filterButton
    }
    
    @objc func filterButtonTapped() {
        let filterVC = CategoryFilterViewController()
        filterVC.delegate = self
        filterVC.selectedCategory = selectedCategory
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
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
        self.data.removeAll()
        self.populateTableView()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshTableView(sender: Any) {
        self.data.removeAll()
        DispatchQueue.main.async {
            self.populateTableView()
            self.refreshControl.endRefreshing()
        }
    }
    
    func populateTableView() {
        ref = Database.database().reference()
        
        ref.child("users").child("items").queryLimited(toLast: 10).observe(.childAdded, with: { (snapshot) in

            if let valueDictionary = snapshot.value as? [AnyHashable:String]
            {
                let item = valueDictionary["value"]
                self.data.insert(Foods(food: item), at: 0)
                //Reload your tableView
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
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
    
    func addButton() {
        let image = UIImage(named: "addIcon")
        button2.frame = CGRect(x: 60, y: 60, width: 60, height: 60)
        button2.setImage(image, for: .normal)
        button2.addTarget(self, action: #selector(buttonTwoSelector), for: .touchUpInside)
        button2.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        button2.layer.cornerRadius = 30
        button2.layer.shadowColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.5).cgColor
        button2.layer.shadowOffset = CGSize(width: 0, height: 4)
        button2.layer.shadowRadius = 8
        button2.layer.shadowOpacity = 0.4
        self.view.addSubview(button2)
        button2.translatesAutoresizingMaskIntoConstraints = false

        button2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        button2.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -15).isActive = true
        button2.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button2.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    override func viewWillLayoutSubviews() {
//        self.view.addSubview(navigationBar)
//        let width = self.view.frame.width
//        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 66))
//        let navigationItem = UINavigationItem(title: "Items")
//        let closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: nil, action: #selector(selector))
//        navigationItem.rightBarButtonItem = closeButton
//        navigationBar.setItems([navigationItem], animated: false)
    }

    @objc func buttonSelector() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    @objc func buttonTwoSelector() {
        // Use new ItemDetailViewController for better item management
        let itemDetailVC = ItemDetailViewController()
        itemDetailVC.storageLocation = "Freezer" // TODO: Get from selected storage location
        let navController = UINavigationController(rootViewController: itemDetailVC)
        navController.modalPresentationStyle = .pageSheet
        self.present(navController, animated: true)
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredData.count : data.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.customCell, for: indexPath) as! DetailTableViewCell
        let item = isSearching ? filteredData[indexPath.row] : data[indexPath.row]
        cell.itemLabel.text = item.food
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = isSearching ? filteredData[indexPath.row] : data[indexPath.row]
        
        let alert = UIAlertController(title: item.food, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add to Shopping List", style: .default) { _ in
            Database.database().reference().child("users").child("list").child("item \(self.value)").child("value").setValue(item.food)
            self.value += 1
        })
        
        alert.addAction(UIAlertAction(title: "Edit Item", style: .default) { _ in
            // Open item detail view - would need to convert Foods to Item
            self.showAlert(title: "Coming Soon", message: "Edit functionality will use the new Item model")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: indexPath)
        }
        
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            Database.database().reference().child("users").child("items").child("item \(indexPath.row)").removeValue()
            success(true)
        })
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
     }
}

extension DetailViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty || selectedCategory != nil
        
        if isSearching {
            filteredData = data.filter { item in
                var matches = true
                
                // Category filter
                if let category = selectedCategory {
                    // Note: This would need to check category from Item model
                    // For now, this is a placeholder
                    matches = true // Would check item.category == category
                }
                
                // Search text filter
                if !searchText.isEmpty {
                    matches = matches && (item.food?.lowercased().contains(searchText.lowercased()) ?? false)
                }
                
                return matches
            }
        }
        
        // Update filter button appearance
        if selectedCategory != nil {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
        } else {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        }
        
        tableView.reloadData()
    }
}

extension DetailViewController: CategoryFilterDelegate {
    func didSelectCategory(_ category: String?) {
        selectedCategory = category
        updateSearchResults(for: searchController)
    }
}
