//
//  CategoryFilterViewController.swift
//  SahinApp
//
//  Category filter view controller
//

import UIKit

protocol CategoryFilterDelegate: AnyObject {
    func didSelectCategory(_ category: String?)
}

class CategoryFilterViewController: UIViewController {
    
    weak var delegate: CategoryFilterDelegate?
    var selectedCategory: String?
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let categories = ["All Categories"] + ItemCategory.categories
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "Filter by Category"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
}

extension CategoryFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = categories[indexPath.row]
        
        if indexPath.row == 0 {
            cell.textLabel?.text = category
            cell.imageView?.image = nil
        } else {
            let icon = ItemCategory.categoryIcons[category] ?? "📦"
            cell.textLabel?.text = "\(icon) \(category)"
        }
        
        if category == selectedCategory || (indexPath.row == 0 && selectedCategory == nil) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            delegate?.didSelectCategory(nil)
        } else {
            delegate?.didSelectCategory(categories[indexPath.row])
        }
        
        dismiss(animated: true)
    }
}

