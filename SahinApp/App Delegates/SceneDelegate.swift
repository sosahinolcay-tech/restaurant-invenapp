//
//  SceneDelegate.swift
//  SahinApp
//
//  Created by Sahin on 09/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit
import Fingertips
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        //use userdefaults at launch to check if i am signed in with a user. if I have already logged in, userdefaults for appfirstimeopened will not be nil and i can load my home viewcontroller.
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        notificationCenter.getNotificationSettings { (settings) in
          if settings.authorizationStatus != .authorized {
            // Notifications not allowed
          }
        }
        
        if let windowScene = scene as? UIWindowScene {
            if userDefaults.value(forKey: "appFirstTimeOpened") == nil {
                do {
                    try Auth.auth().signOut()
                } catch {

                }
                let window = UIWindow(windowScene: windowScene)
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
                window.rootViewController = viewController

                self.window = window
                window.makeKeyAndVisible()
            } else {
                let window = UIWindow(windowScene: windowScene)
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                window.rootViewController = viewController
                
                self.window = window
                window.makeKeyAndVisible()
            }
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        Database.database().reference().child("users").child("listNumber").observe(.value) { (snapshot) in
            let value = snapshot.value as? Int
            if value == 1 {
                let content = UNMutableNotificationContent()
                content.title = "Your shopping list is filling up!"
                content.subtitle = "Check it out"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
                Database.database().reference().child("users").child("listNumber").setValue(0)
            }
        }
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

