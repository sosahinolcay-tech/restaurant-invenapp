//
//  AlertService.swift
//  SahinApp
//
//  Service for managing low stock and expiration alerts
//

import UIKit
import UserNotifications
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AlertService {
    static let shared = AlertService()
    
    private init() {
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func checkLowStockItems(userId: String, completion: @escaping ([Item]) -> Void) {
        let ref = Database.database().reference()
            .child("users")
            .child(userId)
            .child("items")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            var lowStockItems: [Item] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let item = Item.fromSnapshot(snapshot) {
                    if item.isLowStock {
                        lowStockItems.append(item)
                    }
                }
            }
            
            completion(lowStockItems)
        }
    }
    
    func checkExpiringItems(userId: String, completion: @escaping ([Item]) -> Void) {
        let ref = Database.database().reference()
            .child("users")
            .child(userId)
            .child("items")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            var expiringItems: [Item] = []
            let calendar = Calendar.current
            let today = Date()
            let threeDaysFromNow = calendar.date(byAdding: .day, value: 3, to: today) ?? today
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let item = Item.fromSnapshot(snapshot),
                   let expirationDate = item.expirationDate {
                    
                    if expirationDate <= threeDaysFromNow && expirationDate >= today {
                        expiringItems.append(item)
                    }
                }
            }
            
            completion(expiringItems)
        }
    }
    
    func scheduleExpirationReminders(for items: [Item]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        for item in items {
            guard let expirationDate = item.expirationDate,
                  let daysUntil = item.daysUntilExpiration,
                  daysUntil >= 0 && daysUntil <= 3 else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Item Expiring Soon"
            content.body = "\(item.name) expires in \(daysUntil) day\(daysUntil == 1 ? "" : "s")"
            content.sound = .default
            content.badge = 1
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: expirationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "expiration_\(item.id)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    func showLowStockAlert(in viewController: UIViewController, items: [Item]) {
        guard !items.isEmpty else { return }
        
        let itemNames = items.prefix(3).map { $0.name }.joined(separator: ", ")
        let remainingCount = max(0, items.count - 3)
        let message = items.count <= 3 
            ? "Low stock items: \(itemNames)"
            : "Low stock items: \(itemNames) and \(remainingCount) more"
        
        let alert = UIAlertController(
            title: "Low Stock Alert",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "View All", style: .default) { _ in
            // Could navigate to filtered low stock view
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    func showExpirationAlert(in viewController: UIViewController, items: [Item]) {
        guard !items.isEmpty else { return }
        
        let itemNames = items.prefix(3).map { $0.name }.joined(separator: ", ")
        let remainingCount = max(0, items.count - 3)
        let message = items.count <= 3 
            ? "Items expiring soon: \(itemNames)"
            : "Items expiring soon: \(itemNames) and \(remainingCount) more"
        
        let alert = UIAlertController(
            title: "Expiration Alert",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "View All", style: .default) { _ in
            // Could navigate to filtered expiring items view
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    func checkAlertsOnAppLaunch(userId: String, in viewController: UIViewController) {
        // Check if user has notifications enabled
        let lowStockEnabled = UserDefaults.standard.bool(forKey: "notification_0")
        let expirationEnabled = UserDefaults.standard.bool(forKey: "notification_1")
        
        if lowStockEnabled {
            checkLowStockItems(userId: userId) { items in
                if !items.isEmpty {
                    DispatchQueue.main.async {
                        self.showLowStockAlert(in: viewController, items: items)
                    }
                }
            }
        }
        
        if expirationEnabled {
            checkExpiringItems(userId: userId) { items in
                if !items.isEmpty {
                    DispatchQueue.main.async {
                        self.showExpirationAlert(in: viewController, items: items)
                    }
                }
                
                // Schedule notifications
                self.scheduleExpirationReminders(for: items)
            }
        }
    }
}

