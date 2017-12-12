//
//  CertsViewController.swift
//  icert
//
//  Created by ctslin on 11/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit
import ObjectMapper


class CartsSegmentViewController: SegmentViewController {
  let titles = ["尚未結業", "審核中", "已核發"]
  let actions = ["draft", "unconfirmed", "confirmed"]
  var collectionDatas = [[Cert]]()
  override func viewDidLoad() {
    super.viewDidLoad()
    (0...titles.count - 1).forEach { (index) in collectionDatas.append([]) }
  }

  override func layoutUI() {
    segment = TextSegment(titles: titles, size: 12.em)
    tableViews.append(tableView(CertCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(CertCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(CertCell.self, identifier: CellIdentifier))
    loadData()
    super.layoutUI()
  }

  func loadData() {
    API.get("/certs") { (response) in
      let values = response.result.value as! [String: AnyObject]
      self.collectionDatas[0] = (values["draft"] as! [[String: AnyObject]]).map { Cert(JSON: $0)! }
      self.collectionDatas[1] = (values["unconfirmed"] as! [[String: AnyObject]]).map { Cert(JSON: $0)! }
      self.collectionDatas[2] = (values["confirmed"] as! [[String: AnyObject]]).map { Cert(JSON: $0)! }
      self.tableViews.forEach({
        let index = self.tableViews.index(of: $0)!
        $0.reloadData()
        self.segment.labels[index].badge.value = self.collectionDatas[index].count.asDecimal()
      })
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let index = tableViews.index(of: tableView)!
    cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! TableViewCell
    (cell as! CertCell).data = collectionDatas[index][indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return collectionDatas[tableViews.index(of: tableView)!].count }

  override func styleUI() {
    super.styleUI()
    segmentHeight = 50
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    segment.layoutSubviews() // !!!!
  }

}


class CertsViewController: ApplicationTableViewController {

  var collectionData = [Cert]() { didSet { tableView.reloadData() }}

  override func layoutUI() {
    super.layoutUI()
    tableView = tableView(CertCell.self, identifier: CellIdentifier)
    view.layout([tableView])
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! TableViewCell
    (cell as! CertCell).data = collectionData[indexPath.row]
    if indexPath.row % 2 == 1 { cell.backgroundColored(UIColor.lightGray.lighter(0.3)) } else { cell.backgroundColored(UIColor.white)}
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionData.count
  }

  override func loadData() {
    API.get("/certs") { (response) in
      self.collectionData = (response.result.value as! [[String: AnyObject]]).map { Cert(JSON: $0)! }
      _logForUIMode(self.collectionData, title: "collectionData")
    }
  }

}

class CertCell: TableViewCell {
  var data: Cert! { didSet {
    title.texted(data.title!)
    expiredInfo.texted("到期日: \(data.expiredInfo!)")
    status.texted(data.status!)
    }}
  var title = UILabel()
  var expiredInfo = UILabel()
  var status = UILabel()

  override func layoutUI() {
    super.layoutUI()
    layout([title, status, expiredInfo])
  }
  override func styleUI() {
    super.styleUI()
    title.asTitle()
    status.styled().smaller().centered()
    expiredInfo.styled().smaller()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    status.anchorAndFillEdge(.right, xPad: 10, yPad: 0, otherSize: 60)
    title.anchorInCorner(.topLeft, xPad: 10, yPad: 10, width: status.leftEdge() - 20, height: title.textHeight())
    expiredInfo.alignUnder(title, matchingLeftWithTopPadding: 10, width: expiredInfo.textWidth(), height: expiredInfo.textHeight())
  }
}

extension UILabel {
  @discardableResult func asTitle() -> UILabel {
    return styled().larger().bold()
  }
}


