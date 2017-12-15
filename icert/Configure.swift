//
//  Configure.swift
//
//  Created by ctslin on 11/12/2017.
//

import SwiftEasyKit

class Configure {
  init() {
    K.App.mode = "production"
    K.App.mode = "stage"
//    K.App.mode = "local"

    K.App.name = "圈集"

    K.Api.production = "http://icert.airfont.com"
    K.Api.stage = K.Api.production

    K.Api.local = K.Api.stage

    if _isSimulator() {
      K.Api.host = K.Api.local + K.Api.prefix
    } else {
      switch K.App.mode {
      case "stage":
        K.Api.host = K.Api.stage + K.Api.prefix
      default:
        K.Api.host = K.Api.production + K.Api.prefix
      }
    }

    K.Api.pushserverSubscribe = "/subscribe"

    K.Color.table = UIColor.white
    K.Color.navigator = UIColor.fromRGB(119, green: 203, blue: 215)
    K.Color.tabBarBackgroundColor = UIColor.fromHex("FFCC00")
    K.Color.buttonBg = K.Color.tabBarBackgroundColor
    K.CSS.style = "body{font-family: Helvetica,Arial; margin: 1em; font-size: 0.8em; line-height: 1.5; color: \(K.Color.Text.normal.lighter().hexString);} a{color: \(K.Color.buttonBg)}"

    K.CSS.style2 = "body, * {font-family: Arial; font-size: 15px; line-height: 1.8; color: \(K.Color.Text.normal.darker().hexString); margin: 0;} a{color: \(K.Color.buttonBg.hexString)} th{padding-right: 1em;} td, th{font-size: 15px;}"
  }
}

