//
//  AppDelegate.swift
//  MYWALLET
//
//  Created by Ariel Ramírez on 15/10/17.
//  Copyright © 2017 Ariel Ramírez. All rights reserved.
//

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver  {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // For debugging
        //OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            print("launchURL = \(String(describing: notification?.payload.launchURL))")
            print("content_available = \(String(describing: notification?.payload.contentAvailable))")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            if let bodyNotification = payload!.body {
                debugPrint("Body Notification: \(bodyNotification)")
            }
            if let badgeNotification = payload?.badge {
                debugPrint("Badge Notification: \(badgeNotification)")
            }
            if let soundNotification = payload?.sound{
                debugPrint("Sound Notification: \(soundNotification)")
            }
            
            var dataDict: [String:Any] = [String:Any]()
            
            if let additionalDataDictionary = result!.notification.payload.additionalData as NSDictionary? {
                debugPrint("ADITIONAL DATA AS NSDICTIONARY: \(additionalDataDictionary)")
                if let data1 = additionalDataDictionary["tarjeta"] as? String {
                    debugPrint("TARJETA: \(data1)")
                    dataDict["tarjeta"] = data1
                    //dataDict.setValue(data1, forKey: "tarjeta")
                }
                if let data2 = additionalDataDictionary["monto"] as? String {
                    debugPrint("MONTO: \(data2)")
                    dataDict["monto"] = data2
                    //dataDict.setValue(data2, forKey: "monto")
                }
                if DataPersistence.checkIfUserIsLoged().isLoged {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let destinationViewController = storyboard.instantiateViewController(withIdentifier: "AutorizeCViewController") as! AutorizeCViewController
                    destinationViewController.received = dataDict
                    let root = getTopViewController()
                    root.present(destinationViewController, animated: true, completion: nil)
                } else {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let destinationViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    destinationViewController.loginAndAutorize = dataDict
                    let root = self.window?.rootViewController as! UIViewController
                    root.present(destinationViewController, animated: false, completion: nil)
                }
                
            }
        }
        
        func getTopViewController() -> UIViewController
        {
            var topViewController = UIApplication.shared.delegate!.window!!.rootViewController!
            while (topViewController.presentedViewController != nil) {
                topViewController = topViewController.presentedViewController!
            }
            return topViewController
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true, ]
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "76c0663a-2c6b-4923-adfc-3fe02f283148", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        
        return true
    }
    
    // Add this new method
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(stateChanges)")
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

