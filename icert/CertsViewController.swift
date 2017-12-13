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

  override func styleUI() {
    super.styleUI()
    segmentHeight = 50
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    segment.layoutSubviews() // !!!!
  }

  func loadData() {
    API.get("/certs") { (response) in
      self.collectionDatas = []
      let values = response.result.value as! [String: AnyObject]
      self.actions.forEach({ (action) in
        self.collectionDatas.append((values[action] as! [[String: AnyObject]]).map { Cert(JSON: $0)! })
      })
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
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return collectionDatas.count > 0 ? collectionDatas[tableViews.index(of: tableView)!].count : 0 }

}

class ConfirmedCell: CertBaseCell {
  var footer = DefaultView()
  var toolbar = Toolbar()
  override func layoutUI() {
    super.layoutUI()
    layout([footer.layout([toolbar])])
  }
  override func styleUI() {
    super.styleUI()
    toolbar.priButton.texted("申請正本")
    status.isHidden = true
  }
  override func bindUI() {
    super.bindUI()
    toolbar.priButton.whenTapped {
      API.post("/certs/\(self.data.id!)/papers", run: { (response) in

      })
    }
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    footer.alignUnder(body, centeredFillingWidthWithLeftAndRightPadding: 0, topPadding: 20, height: 50)
    footer.topBordered()
    toolbar.bottomBordered(UIColor.lightGray.lighter(0.1), width: 1, padding: 0)
    toolbar.layoutSubviews()
    footer.shadowed(UIColor.lightGray, offset: CGSize(width: 2, height: 15))
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

class CertBaseCell: BaseStatusCell {

  var data: Cert! { didSet {
    title.texted(data.title!)
    expiredInfo.texted("到期日: \(data.expiredInfo!)")
    status.texted(data.status!)
    }}
  var expiredInfo = UILabel()
  override func layoutUI() {
    super.layoutUI()
    body.layout([expiredInfo])
  }
  override func styleUI() {
    super.styleUI()
    expiredInfo.styled().smaller()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    expiredInfo.alignUnder(title, matchingLeftWithTopPadding: 10, width: expiredInfo.textWidth(), height: expiredInfo.textHeight())
    body.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: expiredInfo.bottomEdge())
  }
}

class BaseStatusCell: BaseCell {
  var status = UILabel()
  override func layoutUI() {
    super.layoutUI()
    body.layout([status])
  }
  override func styleUI() {
    super.styleUI()
    status.styled().smaller().centered()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    status.anchorAndFillEdge(.right, xPad: 10, yPad: 0, otherSize: 60)
    title.anchorInCorner(.topLeft, xPad: 10, yPad: 10, width: status.leftEdge() - 20, height: title.textHeight())
  }
}

class BaseCell: TableViewCell {
  var body = DefaultView()
  var title = UILabel()
  override func layoutUI() {
    super.layoutUI()
    layout([body.layout([title])])
  }
  override func styleUI() {
    super.styleUI()
    title.asTitle()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    title.anchorAndFillEdge(.top, xPad: 10, yPad: 10, otherSize: title.textHeight())
    body.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: bottomView.bottomEdge())
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
