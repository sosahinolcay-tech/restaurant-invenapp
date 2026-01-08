//
//  SettingsViewController.swift
//  SahinApp
//
//  Settings and preferences view controller
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let sections = ["Appearance", "Notifications", "Data", "About"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
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
    
    @objc func closeTapped() {
        dismiss(animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 // Appearance: Dark Mode, Theme
        case 1: return 3 // Notifications: Low Stock, Expiration, Shopping Reminders
        case 2: return 3 // Data: Export, Backup, Clear Data
        case 3: return 2 // About: Version, Privacy Policy
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.section {
        case 0: // Appearance
            if indexPath.row == 0 {
                cell.textLabel?.text = "Dark Mode"
                let switchView = UISwitch()
                switchView.isOn = UserDefaults.standard.bool(forKey: "darkModeEnabled")
                switchView.addTarget(self, action: #selector(darkModeToggled(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.accessoryType = .none
            } else {
                cell.textLabel?.text = "Theme Colors"
            }
            
        case 1: // Notifications
            let notifications = ["Low Stock Alerts", "Expiration Reminders", "Shopping List Reminders"]
            cell.textLabel?.text = notifications[indexPath.row]
            let switchView = UISwitch()
            switchView.isOn = UserDefaults.standard.bool(forKey: "notification_\(indexPath.row)")
            switchView.addTarget(self, action: #selector(notificationToggled(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.accessoryType = .none
            
        case 2: // Data
            let dataOptions = ["Export Data", "Backup to Cloud", "Clear All Data"]
            cell.textLabel?.text = dataOptions[indexPath.row]
            if indexPath.row == 2 {
                cell.textLabel?.textColor = .red
            }
            
        case 3: // About
            if indexPath.row == 0 {
                cell.textLabel?.text = "Version"
                cell.detailTextLabel?.text = "1.0.0"
                cell.accessoryType = .none
            } else {
                cell.textLabel?.text = "Privacy Policy"
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 {
                // Theme Colors - could open color picker
                showAlert(title: "Coming Soon", message: "Theme customization will be available in a future update")
            }
            
        case 2:
            if indexPath.row == 0 {
                exportData()
            } else if indexPath.row == 1 {
                backupToCloud()
            } else if indexPath.row == 2 {
                showClearDataAlert()
            }
            
        case 3:
            if indexPath.row == 1 {
                // Open privacy policy
                if let url = URL(string: "https://github.com/sosahinolcay-tech/restaurant-invenapp") {
                    UIApplication.shared.open(url)
                }
            }
            
        default:
            break
        }
    }
    
    @objc func darkModeToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")
        // Apply dark mode - would need to update all view controllers
        showAlert(title: "Restart Required", message: "Please restart the app for dark mode changes to take effect")
    }
    
    @objc func notificationToggled(_ sender: UISwitch) {
        // Get the cell to determine which notification
        if let cell = sender.superview as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            UserDefaults.standard.set(sender.isOn, forKey: "notification_\(indexPath.row)")
        }
    }
    
    func exportData() {
        showAlert(title: "Coming Soon", message: "Data export feature will be available in a future update")
    }
    
    func backupToCloud() {
        showAlert(title: "Backup Complete", message: "Your data is automatically backed up to the cloud")
    }
    
    func showClearDataAlert() {
        let alert = UIAlertController(
            title: "Clear All Data",
            message: "This will permanently delete all your items and shopping lists. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.clearAllData()
        })
        
        present(alert, animated: true)
    }
    
    func clearAllData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference()
            .child("users")
            .child(userId)
        
        ref.removeValue { error, _ in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.showAlert(title: "Success", message: "All data has been cleared")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

