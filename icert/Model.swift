//
//  File.swift
//  icert
//
//  Created by ctslin on 12/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit
import ObjectMapper

class Udollar: AppMappable {
  var payment: Int?
  var balance: Int?
  var title: String?
  var message: String?

  override func mapping(map: Map) {
    super.mapping(map: map)
    payment <- map["payment"]
    balance <- map["balance"]
    title <- map["title"]
    message <- map["message"]
  }
}

class Course: AppMappable {
  var certs: [Cert]?
  var title: String?
  var hasCert: Bool? = true
  var startDate: Date?
  var endDate: Date?
  var hours: Int? = 200
  var percentage: Int? = 0
  var percentageDesc: String?

  override func mapping(map: Map) {
    super.mapping(map: map)
    certs <- map["certs"]
    title <- map["title"]
    hasCert <- map["has_cert"]
    startDate <- map["begin_date"]
    endDate <- map["end_date"]
    hours <- map["hours"]
    percentage <- map["percentage"]
    percentageDesc <- map["percentage_desc"]
    
    title <- map["clas_name"]
  }
}

class Paper: AppMappable {
  var title: String?
  var receiveAt: Date?
  var requestByCode: Bool?
  var paidCodeURL: String?
  override func mapping(map: Map) {
    super.mapping(map: map)
    title <- map["cert.title"]
    receiveAt <- (map["receive_at"], DateTransform())
    requestByCode <- map["request_by_code"]
    paidCodeURL <- map["paid_code_url"]
  }
}

class Photo: AppMappable {

  var url: String?
  var thumb: String?
  override func mapping(map: Map) {
    url <- map["file_url"]
    thumb <- map["thumb_url"]
  }
}

class Cert: AppMappable {
  var course: Course?
  var title: String?
  var photo: Photo?
  var photos: [Photo]?
  var expiredDate: Date?
  var expiredInfo: String?
  var requestCodeURL: String?
  var info: String?

  override func mapping(map: Map) {
    super.mapping(map: map)
    course <- map["course"]
    title <- map["title"]
    expiredDate <- (map["expired_date"], DateTransform())
    expiredInfo <- map["expired_info"]
    photo <- map["photo"]
    photos <- map["photos"]
    requestCodeURL <- map["request_code_url"]
    info <- map["info"]
  }
}


