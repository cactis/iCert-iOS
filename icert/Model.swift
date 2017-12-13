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
  var title: String?
  var hasCert: Bool?
  var startDate: Date?
  var endDate: Date?
  var hours: Int?
  var percentage: Int?

  override func mapping(map: Map) {
    super.mapping(map: map)
    title <- map["title"]
    hasCert <- map["has_cert"]
    startDate <- map["begin_date"]
    endDate <- map["end_date"]
    hours <- map["hours"]
    percentage <- map["percentage"]
  }
}




class Cert: BaseMappable {
  var title: String?
  var expiredDate: Date?
  var expiredInfo: String?
  override func mapping(map: Map) {
    super.mapping(map: map)
    title <- map["title"]
    expiredDate <- (map["expired_date"], DateTransform())
    expiredInfo <- map["expired_info"]
  }
}

class BaseMappable: Mappable {
  var id: Int?
  var createdAt: Date?
  var updatedAt: Date?
  var state: String?
  var status: String?
  var alert: String?
  func mapping(map: Map) {
    id <- map["id"]
    state <- map["state"]
    status <- map["status"]
    createdAt <- (map["created_at"], DateTransform())
    updatedAt <- (map["updated_at"], DateTransform())
    alert <- map["alert"]
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
