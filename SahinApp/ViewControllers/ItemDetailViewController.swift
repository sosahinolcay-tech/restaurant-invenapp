//
//  ItemDetailViewController.swift
//  SahinApp
//
//  View controller for viewing and editing item details
//

import UIKit
import Firebase
import FirebaseDatabase

class ItemDetailViewController: UIViewController {
    
    var item: Item?
    var storageLocation: String = ""
    var onItemUpdated: ((Item) -> Void)?
    var onItemDeleted: (() -> Void)?
    
    // UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let nameTextField = UITextField()
    let quantityTextField = UITextField()
    let unitTextField = UITextField()
    let categoryPicker = UIPickerView()
    let expirationDatePicker = UIDatePicker()
    let notesTextView = UITextView()
    let saveButton = UIButton()
    let deleteButton = UIButton()
    let expirationSwitch = UISwitch()
    let lowStockThresholdTextField = UITextField()
    
    let categories = ItemCategory.categories
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadItemData()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        setupBackgroundGradient()
        setupScrollView()
        setupTextFields()
        setupButtons()
        setupDatePicker()
        setupCategoryPicker()
        
        title = item == nil ? "Add Item" : "Edit Item"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
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
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupTextFields() {
        let fields = [
            ("Item Name", nameTextField),
            ("Quantity", quantityTextField),
            ("Unit (pieces, kg, etc.)", unitTextField),
            ("Low Stock Threshold", lowStockThresholdTextField)
        ]
        
        var topAnchor = contentView.topAnchor
        var spacing: CGFloat = 20
        
        for (placeholder, field) in fields {
            contentView.addSubview(field)
            field.translatesAutoresizingMaskIntoConstraints = false
            field.placeholder = placeholder
            field.backgroundColor = .white
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0).cgColor
            field.font = UIFont.systemFont(ofSize: 16)
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.leftViewMode = .always
            field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.rightViewMode = .always
            
            if field == quantityTextField || field == lowStockThresholdTextField {
                field.keyboardType = .numberPad
            }
            
            NSLayoutConstraint.activate([
                field.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
                field.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                field.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                field.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            topAnchor = field.bottomAnchor
            spacing = 15
        }
        
        // Notes TextView
        contentView.addSubview(notesTextView)
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.backgroundColor = .white
        notesTextView.layer.cornerRadius = 12
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0).cgColor
        notesTextView.font = UIFont.systemFont(ofSize: 16)
        notesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        NSLayoutConstraint.activate([
            notesTextView.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            notesTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupDatePicker() {
        contentView.addSubview(expirationSwitch)
        contentView.addSubview(expirationDatePicker)
        
        expirationSwitch.translatesAutoresizingMaskIntoConstraints = false
        expirationDatePicker.translatesAutoresizingMaskIntoConstraints = false
        expirationDatePicker.datePickerMode = .date
        expirationDatePicker.preferredDatePickerStyle = .compact
        expirationDatePicker.minimumDate = Date()
        expirationDatePicker.isHidden = true
        
        let switchLabel = UILabel()
        switchLabel.text = "Set Expiration Date"
        switchLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(switchLabel)
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        
        expirationSwitch.addTarget(self, action: #selector(expirationSwitchChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            switchLabel.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 20),
            switchLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            expirationSwitch.centerYAnchor.constraint(equalTo: switchLabel.centerYAnchor),
            expirationSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            expirationDatePicker.topAnchor.constraint(equalTo: switchLabel.bottomAnchor, constant: 10),
            expirationDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            expirationDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func setupCategoryPicker() {
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryPicker)
        
        NSLayoutConstraint.activate([
            categoryPicker.topAnchor.constraint(equalTo: expirationDatePicker.bottomAnchor, constant: 20),
            categoryPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryPicker.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func setupButtons() {
        contentView.addSubview(saveButton)
        contentView.addSubview(deleteButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save Item", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.layer.cornerRadius = 16
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        if item != nil {
            deleteButton.setTitle("Delete Item", for: .normal)
            deleteButton.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
            deleteButton.setTitleColor(.white, for: .normal)
            deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            deleteButton.layer.cornerRadius = 16
            deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        } else {
            deleteButton.isHidden = true
        }
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            
            deleteButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 15),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 56),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    func loadItemData() {
        guard let item = item else {
            // New item defaults
            unitTextField.text = "pieces"
            lowStockThresholdTextField.text = "5"
            return
        }
        
        nameTextField.text = item.name
        quantityTextField.text = "\(item.quantity)"
        unitTextField.text = item.unit
        lowStockThresholdTextField.text = "\(item.lowStockThreshold)"
        notesTextView.text = item.notes ?? ""
        
        if let expiration = item.expirationDate {
            expirationSwitch.isOn = true
            expirationDatePicker.isHidden = false
            expirationDatePicker.date = expiration
        }
        
        if let categoryIndex = categories.firstIndex(of: item.category) {
            categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: false)
        }
    }
    
    @objc func expirationSwitchChanged() {
        expirationDatePicker.isHidden = !expirationSwitch.isOn
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter an item name")
            return
        }
        
        let quantity = Int(quantityTextField.text ?? "1") ?? 1
        let unit = unitTextField.text ?? "pieces"
        let category = categories[categoryPicker.selectedRow(inComponent: 0)]
        let lowStockThreshold = Int(lowStockThresholdTextField.text ?? "5") ?? 5
        let notes = notesTextView.text.isEmpty ? nil : notesTextView.text
        
        var expirationDate: Date? = nil
        if expirationSwitch.isOn {
            expirationDate = expirationDatePicker.date
        }
        
        let updatedItem = Item(
            id: item?.id ?? UUID().uuidString,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            storageLocation: storageLocation,
            expirationDate: expirationDate,
            dateAdded: item?.dateAdded ?? Date(),
            dateModified: Date(),
            notes: notes,
            lowStockThreshold: lowStockThreshold
        )
        
        saveItemToFirebase(updatedItem)
    }
    
    @objc func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Item",
            message: "Are you sure you want to delete this item?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteItemFromFirebase()
        })
        
        present(alert, animated: true)
    }
    
    func saveItemToFirebase(_ item: Item) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference()
            .child("users")
            .child(userId)
            .child("items")
            .child(item.id)
        
        ref.setValue(item.toDictionary()) { error, _ in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.onItemUpdated?(item)
                self.dismiss(animated: true)
            }
        }
    }
    
    func deleteItemFromFirebase() {
        guard let item = item, let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference()
            .child("users")
            .child(userId)
            .child("items")
            .child(item.id)
        
        ref.removeValue { error, _ in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.onItemDeleted?()
                self.dismiss(animated: true)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}

extension ItemDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = categories[row]
        let icon = ItemCategory.categoryIcons[category] ?? "📦"
        return "\(icon) \(category)"
    }
}

