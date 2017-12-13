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
  }
}

