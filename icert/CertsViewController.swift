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
    _autoRun {
      self.segment.tappedAtIndex(1)
    }
    (0...titles.count - 1).forEach { (index) in collectionDatas.append([]) }
  }

  override func layoutUI() {
    segment = TextSegment(titles: titles, size: 12.em)
    tableViews.append(tableView(CertCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(UnconfirmedCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(ConfirmedCell.self, identifier: CellIdentifier))
    loadData()
    super.layoutUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
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
    switch index {
    case 0:
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! CertCell
      (cell as! CertCell).data = collectionDatas[index][indexPath.row]
    case 1:
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! UnconfirmedCell
      (cell as! CertCell).data = collectionDatas[index][indexPath.row]
    case 2:
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! ConfirmedCell
      (cell as! ConfirmedCell).data = collectionDatas[index][indexPath.row]
    default:
      break
    }
    
//    cell.needsUpdateConstraints()
    cell.layoutIfNeeded()
    cell.layoutSubviews()
    cell.didDataUpdated = { data in
      if let cert = data as? Cert {
        self.collectionDatas[index][indexPath.row] = cert
        switch index {
        case 1:
          self.moveCellTo(currentIndex: index, targetIndex: 2, indexPath: indexPath)
        default: break
        }
      }
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let index = tableViews.index(of: tableView)!
    return [100, 100, 160][index]
  }

  override func removeDataFromCollectionData(tableView: UITableView, indexPath: IndexPath) { collectionDatas[tableViews.index(of: tableView)!].remove(at: indexPath.row) }

  override func insertDataToCollectionData(currentIndex: Int, targetIndex: Int, indexPath: IndexPath) { self.collectionDatas[targetIndex].insert(self.collectionDatas[currentIndex][indexPath.row], at: 0) }
  
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

class ConfirmedCell: CertBaseCell {
  var footer = DefaultView()
  var toolbar = Toolbar()
  override func layoutUI() {
    super.layoutUI()
    layout([footer.layout([toolbar])])
    bottomView = footer
  }
  override func styleUI() {
    super.styleUI()
    toolbar.priButton.texted("申請正本")
    //    footer.backgroundColored(UIColor.lightGray)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    footer.alignUnder(body, centeredFillingWidthWithLeftAndRightPadding: 0, topPadding: 20, height: 50)
    footer.topBordered()
    toolbar.bottomBordered(UIColor.lightGray.lighter(0.1), width: 1, padding: 0)
    toolbar.layoutSubviews()
    footer.shadowed(UIColor.lightGray, offset: CGSize(width: 2, height: 15))
  }

  class Toolbar: DefaultView {
    var priButton = UIButton()
    override func layoutUI() {
      super.layoutUI()
      layout([priButton])
    }
    override func styleUI() {
      super.styleUI()
      priButton.styledAsSubmit()
      backgroundColored(UIColor.white)
    }
    override func layoutSubviews() {
      super.layoutSubviews()
      priButton.anchorAndFillEdge(.right, xPad: 10, yPad: 10, otherSize: priButton.textWidth() * 1.5)
      fillSuperview(left: 0, right: 0, top: 0, bottom: 10)
    }
  }
}

class UnconfirmedCell: CertCell {
  override func bindUI() {
    super.bindUI()
    status.whenTapped(self, action: #selector(statusTapped))
  }
  @objc func statusTapped() {
    alert(self, title: "審核通過", message: "確定發佈本證書？", okHandler: { (action) in
      API.post("/certs/\(self.data.id!)/confirm!", run: { (response) in
        self.data = Cert(JSON: response.result.value as! [String: AnyObject])!
        self.didDataUpdated(self.data)
      })
    }) { (action) in

    }
  }
}
class CertCell: CertBaseCell { }

class CertBaseCell: TableViewCell {

  var data: Cert! { didSet {
    title.texted(data.title!)
    expiredInfo.texted("到期日: \(data.expiredInfo!)")
    status.texted(data.status!)
//    layoutSubviews()
//    layoutIfNeeded()
    updateConstraintsIfNeeded()
    }}
  var body = DefaultView()
  var title = UILabel()
  var expiredInfo = UILabel()
  var status = UILabel()

  override func layoutUI() {
    super.layoutUI()
    layout([body.layout([title, status, expiredInfo])])
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
    body.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: expiredInfo.bottomEdge())
  }
}

extension UILabel {
  @discardableResult func asTitle() -> UILabel {
    return styled().larger().bold()
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
