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
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: DefaultAppDelegate {

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
    let _ = Configure()
    let _ = LocalDevelopment()
    super.application(application, didFinishLaunchingWithOptions: launchOptions)
    boot()
    Fabric.with([Crashlytics.self])
    self.logUser()
    return true
  }

  func logUser() {
    Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
    Crashlytics.sharedInstance().setUserIdentifier("12345")
    Crashlytics.sharedInstance().setUserName("Test User")
  }


  func boot() {
    let icons: [FontAwesome] = [.creditCard, .calendar, .idCardO, .print, .dollar]
    let images = icons.map({icon($0)})
    let selectedImages = icons.map({icon($0, selected: true)})
    (window, tabBarViewController) = enableTabBarController(self, viewControllers:
      [HomeViewController(),
       CoursesViewController(),
       CartsSegmentViewController(), //CertsViewController(),
        PapersSegmentViewController(),
        UdollarsViewController()], titles:
      ["首頁", "修課中", "我的證書", "申請追蹤", "udallor"], images: images, selectedImages: selectedImages
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
        currentViewController.openViewController(vc, completion: { delayedJob(1) { vc.segment.tappedAtIndex(2) } })
      case "unpaid":
        let vc = PapersSegmentViewController()
        vc.enableCloseBarButtonItem()
        currentViewController.openViewController(vc, completion: {
//          delayedJob(1) { vc.segment.tappedAtIndex(1) }
        })
      case "rateable":
        let vc = PapersSegmentViewController()
        vc.enableCloseBarButtonItem()
        currentViewController.openViewController(vc, completion: { delayedJob(1) { vc.segment.tappedAtIndex(4) } })
      case "udollar":
        let vc = UdollarsViewController()
        vc.enableCloseBarButtonItem()
        currentViewController.openViewController(vc)
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
    let color = selected ? K.Color.tabBar : K.Color.tabBarUnselected
    return getIcon(name, options: ["color": color, "size": size])
  }


}


