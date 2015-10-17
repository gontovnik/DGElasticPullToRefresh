//
//  AppDelegate.swift
//  DGElasticPullToRefreshExample
//
//  Created by Danil Gontovnik on 10/2/15.
//  Copyright © 2015 Danil Gontovnik. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let viewController = ViewController()
        let navigationController = NavigationController(rootViewController: viewController)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = navigationController
        window!.backgroundColor = .whiteColor()
        window!.makeKeyAndVisible()
        
        return true
    }


}

