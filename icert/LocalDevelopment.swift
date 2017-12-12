//
//  LocalDevelopment.swift
//  icert
//
//  Created by ctslin on 11/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit
import SwiftyUserDefaults

class LocalDevelopment {
  init() {
    if Defaults.object(forKey: "setDeviceAsSimulator") != nil {
      Development.setDeviceAsSimulator = (Defaults.object(forKey: "setDeviceAsSimulator") as? Bool)!
    } else {
      Development.setDeviceAsSimulator = false
    }

    // Development.mode = "API Implement"
    Development.mode = "UI Design"
    Development.developer = "CT"
    Development.delayed = 10000
    Development.autoRun = true
    //        Development.prompt = true
    //        Development.uiTestMode = true
    //    Development.autoRun = false
    Development.Log.API.parameters = false
    Development.Log.API.request = false
    Development.Log.API.response = true
    Development.Log.API.header = true
    Development.Log.API.processInfo = false
  }
}

