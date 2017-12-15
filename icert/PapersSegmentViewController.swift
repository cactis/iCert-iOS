//
//  PapersSegmentViewController.swift
//  iCert
//
//  Created by ctslin on 13/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit

class ApplicationSegmentViewController: SegmentViewController {

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }

  func loadData() {}

  override func styleUI() {
    super.styleUI()
    segmentHeight = 50
//    tableViews.first?.bordered()
  }

//  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    return 100
//  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    segment.layoutSubviews() // !!!!
  }
}

class PapersSegmentViewController: ApplicationSegmentViewController {
  let titles = ["待付款", "輸出中", "集件中", "待取件", "待評價", "已結案"]
  let actions = ["unpaid", "printable", "deliverable", "receivable", "rateable", "closed"]
  var collectionDatas = [[Paper]]()
  override func viewDidLoad() {
    super.viewDidLoad()
    _autoRun {
      self.segment.tappedAtIndex(5)
    }

  }

  override func layoutUI() {
    segment = TextSegment(titles: titles, size: 12.em)
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(PaperClosedCell.self, identifier: CellIdentifier))
    loadData()
    super.layoutUI()
  }

  override func loadData() {
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
    switch index {
    case 5:
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! PaperClosedCell
      (cell as! PaperClosedCell).data = collectionDatas[index][indexPath.row]
    default:
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! PaperCell
      (cell as! PaperCell).data = collectionDatas[index][indexPath.row]
    }
    cell.layoutIfNeeded()
    cell.layoutSubviews()
    cell.didDataUpdated = { data in
      if let paper = data as? Paper {
        self.collectionDatas[index][indexPath.row] = paper
        self.moveCellTo(currentIndex: index, targetIndex: index + 1, indexPath: indexPath)
      }
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return [cell.bottomView.bottomEdge(), 100].max()!
  }

  override func removeDataFromCollectionData(tableView: UITableView, indexPath: IndexPath) { collectionDatas[tableViews.index(of: tableView)!].remove(at: indexPath.row) }

  override func insertDataToCollectionData(currentIndex: Int, targetIndex: Int, indexPath: IndexPath) { self.collectionDatas[targetIndex].insert(self.collectionDatas[currentIndex][indexPath.row], at: 0) }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return collectionDatas.count > 0 ? collectionDatas[tableViews.index(of: tableView)!].count : 0 }
}

class PaperClosedCell: PaperCell {
  var date = UILabel()
  override var data: Paper! { didSet {
    date.texted("已於 \((data.receiveAt?.toString())!) 領取")
    //    layoutSubviews()
    }}
  override func layoutUI() {
    super.layoutUI()
    body.layout([date])
  }
  override func styleUI() {
    super.styleUI()
    date.styled()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    date.alignUnder(title, matchingLeftWithTopPadding: 10, width: date.textWidth(), height: date.textHeight())
  }
}

class PaperCell: BodyFooterCell {
  var data: Paper! {
    didSet {
      title.texted(data.title)
      toolbar.priButton.texted(data.priButton)
      toolbar.subButton.texted(data.subButton)
      toolbar.layoutIfNeeded()
      layoutSubviews()
    }
  }
  override func bindUI() {
    super.bindUI()
    [toolbar.priButton, toolbar.subButton].forEach { $0.whenTapped {
      if let action = self.data.nextEvent {
        API.post("/papers/\(self.data.id!)/\(action)!", run: { (response) in
          delayedJob (1) {
            if let paper = Paper(JSON: response.result.value as! [String: AnyObject]) {
              self.didDataUpdated(paper)
            }
          }
        })
      }
      }
    }
  }
}

class BodyFooterCell: BaseCell {
//  var footer = DefaultView()
//  var toolbar = Toolbar()
  override func layoutUI() {
    super.layoutUI()
    layout([footer.layout([toolbar])])
  }
  override func styleUI() {
    super.styleUI()
    toolbar.priButton.texted("操作鍵")
    toolbar.subButton.texted("次操作鍵")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    body.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: (body.bottomView?.bottomEdge())! + 20)
  }
}

class Toolbar: DefaultView {
  var priButton = UIButton()
  var subButton = UIButton()
  var extraButtons = UIView()
  var buttons = [UIButton]() { didSet {
    extraButtons.removeSubviews()
    extraButtons.layout(buttons)
    layoutSubviews()
    buttons.forEach({$0.styledAsSubButton()})
    }}

  func addExtraButtons(buttons: [UIButton], bindEvent: (_ buttons: [UIButton]) -> ()) {
    self.buttons = buttons
    bindEvent(self.buttons)
  }
  override func layoutUI() {
    super.layoutUI()
    layout([priButton, subButton, extraButtons])
  }
  override func styleUI() {
    super.styleUI()
    priButton.styledAsSubmit()
    subButton.styledAsSubButton()
    backgroundColored(UIColor.white)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    priButton.anchorAndFillEdge(.right, xPad: 10, yPad: 10, otherSize: priButton.textWidth() * 2)
    subButton.align(toTheLeftOf: priButton, matchingTopWithRightPadding: [priButton.width, 10].min()!, width: subButton.textWidth() * 2, height: priButton.height)
    extraButtons.align(toTheLeftOf: subButton, matchingTopAndFillingWidthWithLeftAndRightPadding: 10, height: subButton.height)
    buttons.forEach { (button) in
      if buttons.index(of: button)! == 0 {
        button.anchorAndFillEdge(.right, xPad: 0, yPad: 0, otherSize: button.autoWidth())
      } else {
        button.align(toTheLeftOf: buttons[0], matchingTopWithRightPadding: 10, width: button.autoWidth(), height: subButton.height)
      }
    }
//    fillSuperview(left: 0, right: 0, top: 0, bottom: 10)
  }
}
