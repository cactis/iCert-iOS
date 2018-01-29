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

    K.App.name = "iCert"

//    K.Api.production = "http://icert.airfont.com"
    K.Api.production = "http://140.137.207.47"
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

    K.Size.Text.normal = 14

    K.Api.pushserverSubscribe = "/subscribe"

    K.Color.table = UIColor.white
    K.Color.navigator = UIColor.fromHex("649C9B").lighter()
    K.Color.tabBarBackgroundColor = UIColor.fromHex("E63D71").darker()
    K.Color.buttonBg = K.Color.tabBarBackgroundColor.lighter(0.05)
    K.Color.button = K.Color.tabBar
    K.CSS.style = "body {font-family: Helvetica,Arial; margin: 1em; font-size: 1.2em; line-height: 1.2; color: \(K.Color.Text.normal.lighter(0).hexString);} a{color: \(K.Color.buttonBg)} img{margin: 2em; height: auto; border: 1px solid #333;} table{padding: 2em 0.5em; width: 100%} th{break-line:no-wrap; text-align: right}"

    K.CSS.style2 = "body, * {font-family: Arial; font-size: 15px; line-height: 1.8; color: \(K.Color.Text.normal.darker().hexString); margin: 0;} a{color: \(K.Color.buttonBg.hexString)} th{padding-right: 1em;} td, th{font-size: 15px;}"
  }
}

