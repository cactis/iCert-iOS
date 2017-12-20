//
//  File.swift
//  icert
//
//  Created by ctslin on 12/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import ObjectMapper

class Udollar: BaseMappable {
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

class Course: BaseMappable {
  var certs: [Cert]?
  var title: String?
  var hasCert: Bool?
  var startDate: Date?
  var endDate: Date?
  var hours: Int?
  var percentage: Int?
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
  }
}

class Paper: BaseMappable {
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


class Photo: BaseMappable {

  var url: String?
  override func mapping(map: Map) {
    url <- map["file_url"]
  }

}


class Cert: BaseMappable {
  var course: Course?
  var title: String?
  var photo: Photo?
  var photos: [Photo]?
  var expiredDate: Date?
  var expiredInfo: String?
  var requestCodeURL: String?
  override func mapping(map: Map) {
    super.mapping(map: map)
    course <- map["course"]
    title <- map["title"]
    expiredDate <- (map["expired_date"], DateTransform())
    expiredInfo <- map["expired_info"]
    photo <- map["photo"]
    photos <- map["photos"]
    requestCodeURL <- map["request_code_url"]
  }
}

class BaseMappable: Mappable {
  var id: Int?
  var createdAt: Date?
  var updatedAt: Date?
  var state: String?
  var status: String?
  var alert: String?
  var priButton: String?
  var subButton: String?
  var nextEvent: String?
  func mapping(map: Map) {
    id <- map["id"]
    state <- map["state"]
    status <- map["status"]
    createdAt <- (map["created_at"], DateTransform())
    updatedAt <- (map["updated_at"], DateTransform())
    alert <- map["alert"]
    priButton <- map["pri_button"]
    subButton <- map["sub_button"]
    nextEvent <- map["next_event"]
  }

  required init?(map: Map) {}
}

class DateTransform: TransformType {

  public typealias Object = Date
  public typealias JSON = String

  public init() {}

  func transformFromJSON(_ value: Any?) -> Date? {
    if value == nil { return nil }
    return (value as? String)!.toDate()
  }

  func transformToJSON(_ value: Date?) -> String? {
    return value?.toString()
  }
}
