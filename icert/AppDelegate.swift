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
    return true
  }

  func boot() {
    let icons: [FontAwesome] = [.calendar, .idCardO, .print, .dollar]
    let images = [icon(icons[0]), icon(icons[1]), icon(icons[2]), icon(icons[3])]
    let selectedImages = [icon(icons[0], selected: true), icon(icons[1], selected: true), icon(icons[2], selected: true), icon(icons[3], selected: true)]
    (window, tabBarViewController) = SwiftEasyKit.enableTabBarController(self, viewControllers:
      [CoursesViewController(),
       CartsSegmentViewController(), //CertsViewController(),
        PapersSegmentViewController(),
        UdollarsViewController()], titles:
      ["修課清單", "我的證書", "申請追蹤", "UDollar"], images: images, selectedImages: selectedImages
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
      case "unpaid":
        let vc = PapersSegmentViewController()
        vc.enableCloseBarButtonItem()
        currentViewController.openViewController(vc, completion: {
//          delayedJob(1) { vc.segment.tappedAtIndex(1) }
        })
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


