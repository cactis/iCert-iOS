//
//  UdollarsViewController.swift
//  icert
//
//  Created by ctslin on 12/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit

class UdollarsViewController: ApplicationTableViewController {

  let head = HeadView()
  var collectionData = [Udollar]() { didSet { tableView.reloadData() } }

  override func loadData() {
    API.get("/udollars") { (response) in
      self.collectionData = (response.result.value as! [[String: AnyObject]]).map { Udollar(JSON: $0)! }
      self.head.data = self.collectionData.first?.balance ?? 0
    }
  }

  override func layoutUI() {
    super.layoutUI()
    tableView = tableView(UdollarCell.self, identifier: CellIdentifier)
    view.layout([tableView])
  }

  class HeadView: DefaultView {
    var b = DefaultView()
    var balance = UILabel()
    var data: Int? { didSet {
      balance.texted("$ \(String(describing: data!))")
      layoutSubviews()
      }}

    override func layoutUI() {
      layout([b.layout([balance])])
    }
    override func styleUI() {
      super.styleUI()
      backgroundColored(UIColor.white)
      let color = K.Color.tabBarBackgroundColor
      b.radiused(3).bordered(2, color: color.cgColor)
      balance.styled().larger(2).colored(color).centered().bold()
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      b.fillSuperview(left: 100, right: 100, top: 30, bottom: 30)
      balance.anchorInCenter(width: balance.textWidth(), height: balance.textHeight())
    }
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return head
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 100
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! UdollarCell
    (cell as! UdollarCell).data = collectionData[indexPath.row]
    if indexPath.row % 2 == 1 { cell.backgroundColored(UIColor.lightGray.lighter(0.3)) } else { cell.backgroundColored(UIColor.white)}
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionData.count
  }

  class UdollarCell: TableViewCell {

    var title = UILabel()
    var message = UILabel()
    var payment = UILabel()
    var balance = UILabel()
    var date = UILabel()

    var data: Udollar! { didSet {
      title.texted(data.title!)
      message.texted(data.message!)
      payment.texted("\(data.payment! > 0 ? "+" : "")\(data.payment!)").larger(2).darker()
      balance.texted("餘額: \(data.balance!)").larger(3)
      date.texted(data.createdAt!.toString())
      }}

    override func layoutUI() {
      super.layoutUI()
      layout([title, message, payment, balance, date])
    }

    override func styleUI() {
      super.styleUI()
      title.asTitle()
      message.styled().multilinized()
      payment.styled().smaller().lighter()
      balance.styled().bold().lighter().aligned(.right)
      date.styled()
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      title.anchorInCorner(.topLeft, xPad: 10, yPad: 20, width: width() - 80, height: title.textHeight())
      message.alignUnder(title, matchingLeftAndRightWithTopPadding: 5, height: message.getHeightBySizeThatFitsWithWidth(title.width))
      payment.anchorInCorner(.topRight, xPad: 10, yPad: 20, width: payment.textWidth(), height: payment.textHeight())

      date.alignUnder(message, matchingLeftWithTopPadding: 10, width: date.textWidth(), height: date.textHeight())
      balance.align(toTheRightOf: date, fillingWidthWithLeftAndRightPadding: 10, topPadding: date.topEdge(), height: balance.textHeight())
    }
  }
}
