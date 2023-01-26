//
//  AppDelegate.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = createNavigationController()
        window?.makeKeyAndVisible()
        return true
    }
    
    private func createNavigationController() -> UINavigationController {
        let photosVC = PhotosViewController()
        let navigationVC = UINavigationController(rootViewController: photosVC)
        return navigationVC
    }

}

