//
//  HomeViewController.swift
//  SahinApp
//
//  Created by Sahin on 09/02/2020.
//  Copyright © 2020 Sahin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct CustomData {
    var title: String
    var backgroundImage: UIImage
}

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // my outlets from my items in the storyboard, used to reference in code.
    @IBOutlet weak var storageBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!

    // my data array which has a title and backgroundimage as i set in the struct above which holds these variables. Use it to load images in my collectionviewcells below.
    fileprivate var data = [
        CustomData(title: "Freezer", backgroundImage: UIImage(named: "freezer")!),
        CustomData(title: "fridge", backgroundImage: UIImage(named: "fridge")!),
        CustomData(title: "countertop", backgroundImage: UIImage(named: "countertop")!),
        CustomData(title: "drinks fridge", backgroundImage: UIImage(named: "drinks fridge")!)
    ]

    //i create ab instance of the ui elements as well as the childviewcontroller which is the items screen for each storage.
    let childViewController = DetailViewController()
    let shoppingListViewController = ShoppingListViewController()
    var navigationBar = UINavigationBar()
    let addedImage = UIImageView()
    let userDefaults = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    let settingsButton = UIButton()

    //this is a unique customisation of my collectionview, only accessible in this class
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
      }()

    /* in here i set my imagepicker, which is the add storage camera delegate to equal self so that i can access its methods for use. I set up my ui elements as well as check user defaults to see if i had an image taken from before and added to the collection view after the app was restarted.
*/
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        viewWillLayoutSubviews()
        imagePicker.delegate = self

        setupBackgroundGradient()
        setupNavigationBar()
        setupCollectionView()
        setupButtons()
        setupSettingsButton()
        checkAlertsOnLaunch()

         if userDefaults.value(forKey: "imageDefaults") == nil {
             addedImage.image = UIImage(named: "defaultProfile")
         } else {
             self.addedImage.image = userDefaults.imageForKey(key: "imageDefaults")!
            //add into array the image stored in user defaults
             data.append(CustomData(title: "", backgroundImage: self.addedImage.image!))
             let indexPath = IndexPath(row: data.count - 1, section: 0)
             collectionView.insertItems(at: [indexPath])
         }
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
    
    func checkAlertsOnLaunch() {
        if let userId = Auth.auth().currentUser?.uid {
            AlertService.shared.checkAlertsOnAppLaunch(userId: userId, in: self)
        }
    }
    
    func setupButtons() {
        // Storage Button
        storageBtn.layer.cornerRadius = 16
        storageBtn.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        storageBtn.setTitleColor(.white, for: .normal)
        storageBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        storageBtn.layer.shadowColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.4).cgColor
        storageBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        storageBtn.layer.shadowRadius = 8
        storageBtn.layer.shadowOpacity = 0.3
        
        // More Button
        moreBtn.layer.cornerRadius = 16
        moreBtn.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)
        moreBtn.setTitleColor(.white, for: .normal)
        moreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        moreBtn.layer.shadowColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 0.4).cgColor
        moreBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        moreBtn.layer.shadowRadius = 8
        moreBtn.layer.shadowOpacity = 0.3
        
        // Sign Out Button
        signOutBtn.layer.cornerRadius = 16
        signOutBtn.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        signOutBtn.setTitleColor(.white, for: .normal)
        signOutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signOutBtn.layer.shadowColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.4).cgColor
        signOutBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        signOutBtn.layer.shadowRadius = 8
        signOutBtn.layer.shadowOpacity = 0.3
    }

    override func viewDidDisappear(_ animated: Bool) {
        navigationBar.removeFromSuperview()
    }

    func setupNavigationBar() {
        let width = self.view.frame.width
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 60, width: width, height: 66))
        navigationBar.backgroundColor = .clear
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Item Organiser")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        // Customize title appearance
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        navigationBar.titleTextAttributes = titleAttributes
        
        navigationBar.setItems([navigationItem], animated: false)
    }

    func setupSettingsButton() {
        let image = UIImage(named: "settingsIcon1")
        settingsButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        settingsButton.setBackgroundImage(image, for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }
    
    @objc func settingsTapped() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    
    @IBAction func shoppingListTapped(_ sender: Any) {
        self.showShoppingListViewController()
    }
    
    

    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        collectionView.heightAnchor.constraint(equalTo:
        collectionView.widthAnchor, multiplier: 0.5).isActive = true
    }

    //delegate emthod for image picker, does logic to add taken image from storagebutton action below to the collectionview.
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        let name = "new storage"
        self.addedImage.image = selectedImage
        userDefaults.setImage(image: self.addedImage.image, forKey: "imageDefaults")

        picker.dismiss(animated: true, completion: nil)
        //dismiss the phones camera asnd use the photo to append to the array and save it in user defaults
        data.append(CustomData(title: name, backgroundImage: addedImage.image!))
        let indexPath = IndexPath(row: data.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
    }

    @IBAction func storageButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

            // Device has a camera, now create the image picker controller
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            NSLog("No Camera")
        }
    }

    //usinf firebase built in function, i sign out if i press on the button and present the start screen.
    @IBAction func signOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
        viewController.isModalInPresentation = true
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    //MARK:- CollectionView

    //these are my collectionview delegate methods. i set the number of rows to the amount of data in my array and set a size to each cell which is of tyoe collectionviewcell in my custom cell types folder.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.layoutIfNeeded()
        //i do this to set the data in each individual cell with the background image i stored in data at the custom collection view cell
        cell.data = self.data[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /* In this section we do this:
         1. we say we want to select the first item in the collection view
         2. we get a reference to our database which has two childs
         3. as they are strings we say as? string (its an optional, can be nil)
         4. we set item1 and item2 as the value of both children which is part of the dictionary snapshot. snapshot.value gives you the values within the snapshot dictionary which is eggs and tomato in the database.
         5. then we append into the data array in the the child view so we can show it in the tableview
        */
        if indexPath.row == 0 {
            self.showChildViewController()
        } else {
            print("need logic to show other views just like the one above")
        }

//            Database.database().reference().child("users").child("items").observe(.value) { snapshot in
//                let snapshot = snapshot.value as? NSDictionary
//                print(snapshot)
//                if let item1 = snapshot?["item 1"] as? String {
//                    if let item2 = snapshot?["item 2"] as? String {
//                        print(item1)
//                        print(item2)
//                        if !self.childViewController.data.contains(item2) && !self.childViewController.data.contains(item1) {
//                            self.childViewController.data.append(item1)
//                            self.childViewController.data.append(item2)
//                        } else {
//                            let alert = UIAlertController(title: "Alert", message: "This item number already exists", preferredStyle: UIAlertController.Style.alert)
//                            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                    }
//                }
//            }
    }
}

//extension to add extra functionalilty like adding child view controllers, using user defaults to store my images
extension HomeViewController {
    func showChildViewController() {
        self.addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }
    
    func showShoppingListViewController() {
        self.addChild(shoppingListViewController)
        view.addSubview(shoppingListViewController.view)
        shoppingListViewController.didMove(toParent: self)
    }
}

extension UserDefaults {

    func imageForKey(key: String) -> UIImage? {
        var image: UIImage?
        if let imageData = data(forKey: key) {
            image = NSKeyedUnarchiver.unarchiveObject(with: imageData) as? UIImage
        }
        return image
    }

    func setImage(image: UIImage?, forKey key: String) {
        var imageData: NSData?
        if let image = image {
            imageData = NSKeyedArchiver.archivedData(withRootObject: image) as NSData?
        }
        set(imageData, forKey: key)
    }
}
