//
//  CoursesViewController.swift
//  icert
//
//  Created by ctslin on 11/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit

class ApplicationTableViewController: TableViewController {
  func loadData() {

  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }
}

class CoursesViewController: ApplicationTableViewController {

  var collectionData = [Course]() { didSet { tableView.reloadData() }}
  override func viewDidLoad() {
    super.viewDidLoad()
    _autoRun {
      self.tabBarController?.selectedIndex = 2
    }
  }

  override func layoutUI() {
    super.layoutUI()
    tableView = tableView(CourseCell.self, identifier: CellIdentifier)
    view.layout([tableView])
    addRightBarButtonItem(getIcon(.plus), action: #selector(plusTapped))
    addLeftBarButtonItem(getIcon(.recycle), action: #selector(resetTapped))
  }
  @objc func resetTapped() {
    API.post("/courses/reset") { (response) in
      self.viewWillAppear(true)
    }
  }
  @objc func plusTapped() {
    API.post("/courses") { (response) in
      self.collectionData.insert(Course(JSON: response.result.value as! [String: AnyObject])!, at: 0)
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! CourseCell
    (cell as! CourseCell).data = collectionData[indexPath.row]
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionData.count
  }

  override func loadData() {
    API.get("/courses") { (response) in
      self.collectionData = (response.result.value as! [[String: AnyObject]]).map { Course(JSON: $0)! }
    }
  }

  class CourseCell: TableViewCell {
    var title = UILabel()
    var cert = UILabel("結業證書")
    var hasCert = IconLabel(iconImage: nil, text: "")
    var percentage = UILabel()
    var hours = UILabel()

    var data: Course! { didSet {
      title.texted(data.title!)
      hasCert.isHidden = !data.hasCert!
      cert.isHidden = !data.hasCert!
      percentage.texted(data.percentageDesc)
      hours.texted("總時數: \(data.hours!)")
      }}

    override func layoutUI() {
      super.layoutUI()
      layout([title, cert, hasCert, hours, percentage])
    }
    override func styleUI() {
      super.styleUI()
      title.asTitle().multilinized()
      cert.styled().smaller(2).lighter().multilinized(2).centered()
      percentage.styled()
      hours.styled()
      hasCert.image = getIcon(.check, options: ["color": K.Color.tabBarBackgroundColor])
    }
    override func bindUI() {
      super.bindUI()
      percentage.whenTapped(self, action: #selector(percentageTapped))
    }
    @objc func percentageTapped() {
      API.put("/courses/\(data.id!)/go") { (response) in
        self.data = Course(JSON: response.result.value as! [String: AnyObject])!
      }
    }
    override func layoutSubviews() {
      super.layoutSubviews()
      cert.anchorInCorner(.topRight, xPad: 10, yPad: 20, width: cert.textWidth() / 2, height: cert.getHeightBySizeThatFitsWithWidth(cert.width))
      let w = cert.leftEdge() - 10
      title.anchorInCorner(.topLeft, xPad: 10, yPad: 10, width: w, height: title.getHeightBySizeThatFitsWithWidth(w))
      hasCert.alignUnder(cert, matchingCenterWithTopPadding: -5, width: cert.width, height: cert.width)
      hours.alignUnder(title, matchingLeftWithTopPadding: 10, width: 90, height: hours.textHeight())
      percentage.align(toTheRightOf: hours, matchingTopWithLeftPadding: 10, width: 200, height: percentage.textHeight())
    }
  }
}


