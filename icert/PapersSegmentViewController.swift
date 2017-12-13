//
//  PapersSegmentViewController.swift
//  iCert
//
//  Created by ctslin on 13/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit

class PapersSegmentViewController: SegmentViewController {
  let titles = ["待付款", "待輸出", "待寄送", "待收件", "待評價", "已結案"]
  let actions = ["unpaid", "printable", "deliverable", "receivable", "rateable", "closed"]
  var collectionDatas = [[Paper]]()
  override func viewDidLoad() {
    super.viewDidLoad()
    _autoRun {
//      self.segment.tappedAtIndex(2)
    }

  }

  override func layoutUI() {
    segment = TextSegment(titles: titles, size: 12.em)
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    loadData()
    super.layoutUI()
  }

  override func styleUI() {
    super.styleUI()
    segmentHeight = 50
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    segment.layoutSubviews() // !!!!
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }

  func loadData() {
    API.get("/papers") { (response) in
      self.collectionDatas = []
      let values = response.result.value as! [String: AnyObject]
      self.actions.forEach({ (action) in
        self.collectionDatas.append((values[action] as! [[String: AnyObject]]).map { Paper(JSON: $0)! })
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
    cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! PaperCell
      (cell as! PaperCell).data = collectionDatas[index][indexPath.row]
    cell.layoutIfNeeded()
    cell.layoutSubviews()
    cell.didDataUpdated = { data in
      if let paper = data as? Paper {
        self.collectionDatas[index][indexPath.row] = paper
//        switch index {
//        case 1:
          self.moveCellTo(currentIndex: index, targetIndex: index + 1, indexPath: indexPath)
//        default: break
//        }
      }
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    let index = tableViews.index(of: tableView)!
    return 120 //[100, 100, 160][index]
  }

  override func removeDataFromCollectionData(tableView: UITableView, indexPath: IndexPath) { collectionDatas[tableViews.index(of: tableView)!].remove(at: indexPath.row) }

  override func insertDataToCollectionData(currentIndex: Int, targetIndex: Int, indexPath: IndexPath) { self.collectionDatas[targetIndex].insert(self.collectionDatas[currentIndex][indexPath.row], at: 0) }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return collectionDatas.count > 0 ? collectionDatas[tableViews.index(of: tableView)!].count : 0 }
}

class PaperCell: BodyFooterCell {
  var data: Paper! {
    didSet {
      title.texted(data.title)
      toolbar.priButton.texted(data.priButton)
      layoutSubviews()
    }
  }
  override func bindUI() {
    super.bindUI()
    toolbar.priButton.whenTapped {
      if let action = self.data.nextEvent {
        API.post("/papers/\(self.data.id!)/\(action)!", run: { (response) in
          self.data = Paper(JSON: response.result.value as! [String: AnyObject])!
          self.didDataUpdated(self.data)
        })
      }
    }
  }
}

class BodyFooterCell: BaseCell {
  var footer = DefaultView()
  var toolbar = Toolbar()
  override func layoutUI() {
    super.layoutUI()
    layout([footer.layout([toolbar])])
  }
  override func styleUI() {
    super.styleUI()
    toolbar.priButton.texted("操作鍵")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    body.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: title.bottomEdge() + 20)
    footer.alignUnder(body, centeredFillingWidthWithLeftAndRightPadding: 0, topPadding: 20, height: 60)
    footer.topBordered()
    toolbar.bottomBordered(UIColor.lightGray.lighter(0.1), width: 1, padding: 0)
    toolbar.layoutSubviews()
    footer.shadowed(UIColor.lightGray, offset: CGSize(width: 2, height: 15))
  }
}

class Toolbar: DefaultView {
  var priButton = UIButton()
  override func layoutUI() {
    super.layoutUI()
    layout([priButton])
  }
  override func styleUI() {
    super.styleUI()
    priButton.styledAsSubmit().colored(UIColor.black)
    backgroundColored(UIColor.white)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    priButton.anchorAndFillEdge(.right, xPad: 10, yPad: 10, otherSize: priButton.textWidth() * 1.5)
    fillSuperview(left: 0, right: 0, top: 0, bottom: 10)
  }
}
