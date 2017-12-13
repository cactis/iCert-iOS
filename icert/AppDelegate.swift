//
//  AppDelegate.swift
//  icert
//
//  Created by ctslin on 11/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//


import UIKit
import SwiftyUserDefaults
import SwiftEasyKit
import ReSwift
import UserNotifications
import FontAwesome_swift

@UIApplicationMain
class AppDelegate: DefaultAppDelegate {

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
    let _ = Configure()
    let _ = LocalDevelopment()
    super.application(application, didFinishLaunchingWithOptions: launchOptions)
    boot()
    return true
  }

  func boot() {
    let icons: [FontAwesome] = [.calendar, .idCardO, .print, .userO]
    let images = [icon(icons[0]), icon(icons[1]), icon(icons[2]), icon(icons[3])]
    let selectedImages = [icon(icons[0], selected: true), icon(icons[1], selected: true), icon(icons[2], selected: true), icon(icons[3], selected: true)]
    (window, tabBarViewController) = SwiftEasyKit.enableTabBarController(self, viewControllers:
      [CoursesViewController(),
       CartsSegmentViewController(), //CertsViewController(),
        ViewController(),
        UdollarsViewController()], titles:
      ["修課中", "我的證書", "正本申請", "我的帳戶"], images: images, selectedImages: selectedImages
    )
    window?.backgroundColor = UIColor.darkGray.lighter()
    window?.layer.contents = UIImage(named: "background")?.cgImage
  }

  override func didNotificationTapped(userInfo: [AnyHashable : Any]) {
    if let state = userInfo["state"] as? String {
      switch state {
      case "unconfirmed":
        let vc = CartsSegmentViewController()
        vc.enableCloseBarButtonItem()
        currentViewController.openViewController(vc, completion: {
          delayedJob(1) { vc.segment.tappedAtIndex(1) }
        })
      case "confirmed":
        let vc = CartsSegmentViewController()
        vc.enableCloseBarButtonItem()
        currentViewController.openViewController(vc, completion: {
          delayedJob(1) { vc.segment.tappedAtIndex(2) }
        })
      default:break;
      }
    }
  }

  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    _logForAnyMode(userInfo)
    completionHandler([.alert, .badge])
//    if let alert = (userInfo["aps"] as! [String: Any])["alert"] as? String {
//      completionHandler([.alert, .badge])
//    }

  }

  func icon(_ name: FontAwesome, selected: Bool = false) -> UIImage {
    let size = 30
    let color = !selected ? UIColor.darkGray.lighter() : UIColor.black.lighter()
    return getIcon(name, options: ["color": color, "size": size])
  }


}


