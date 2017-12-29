//
//  CertsViewController.swift
//  icert
//
//  Created by ctslin on 11/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit
import ObjectMapper
import EFQRCode

class CartsSegmentViewController: ApplicationSegmentViewController {
  let titles = ["修課中", "審核中", "已核發"]
  let actions = ["draft", "unconfirmed", "confirmed"]
  var collectionDatas = [[Cert]]()
  override func viewDidLoad() {
    super.viewDidLoad()
    _autoRun {
      self.segment.tappedAtIndex(2)
    }
  }

  override func layoutUI() {
    segment = TextSegment(titles: titles)
    tableViews.append(tableView(CertCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(UnconfirmedCell.self, identifier: CellIdentifier))
    tableViews.append(tableView(ConfirmedCell.self, identifier: CellIdentifier))
//    tableViews.forEach({$0.separatorStyle = .singleLine})
    loadData()
    super.layoutUI()
  }

  override func loadData() {
    API.get("/certs") { (response, data) in
      self.collectionDatas = []
      let values = response.result.value as! [String: AnyObject]
      self.actions.forEach({ (action) in
        self.collectionDatas.append(Mapper<Cert>().mapArray(JSONObject: values[action])!)
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
        case 0, 1:
          self.moveCellTo(currentIndex: index, targetIndex: index + 1, indexPath: indexPath)
        default: break
        }
      }
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screenHeight() / 5
//    return [80, 100, 160][tableViews.index(of: tableView)!]
  }

  override func removeDataFromCollectionData(tableView: UITableView, indexPath: IndexPath) { collectionDatas[tableViews.index(of: tableView)!].remove(at: indexPath.row) }

  override func insertDataToCollectionData(currentIndex: Int, targetIndex: Int, indexPath: IndexPath) { self.collectionDatas[targetIndex].insert(self.collectionDatas[currentIndex][indexPath.row], at: 0) }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return collectionDatas.count > 0 ? collectionDatas[tableViews.index(of: tableView)!].count : 0 }
}

class ConfirmedCell: CertBaseCell {
  var photo = UIImageView()
  override var data: Cert! { didSet {
    photo.imaged(data.photo?.url)
    }}

  override func layoutUI() {
    super.layoutUI()
    body.layout([photo])
    let buttons = [UIButton(text: "條碼列印"), UIButton(text: "檢視證書"), UIButton(text: "分享")]
    toolbar.addExtraButtons(buttons: buttons) { buttons in
      buttons[0].whenTapped {
        API.get("/certs/\(self.data.id!)/qrcode", run: { (response, data) in
          if let cert = Cert(JSON: (response.result.value as? [String: AnyObject])!) {
            self.data = cert
            let content = cert.requestCodeURL!.hostUrl()
            let info = "<b>www.icert.pccu.edu.tw</b><br/>Issued by: GlobalSign Extended Validation CA-SHA256-G3<br/>Expires: Sunday, 23 June 2019 at 2:56:03 PM Taipei Standard Time<br/>This certificate is valid"
            content.displayQrcode(self.photo.image, info: info)
            _logForUIMode(content, title: "content")

          }
        })
      }
      buttons[1].whenTapped {
        self.photo.previewTapped()
      }
    }
  }

  override func styleUI() {
    super.styleUI()
    toolbar.priButton.texted("申請正本")
    status.isHidden = true
    photo.styled().radiused()
  }
  override func bindUI() {
    super.bindUI()
    toolbar.priButton.whenTapped {
      API.post("/certs/\(self.data.id!)/papers", run: { (response, data) in
      })
    }
    photo.bindPreview()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    photo.anchorInCorner(.topRight, xPad: 10, yPad: 10, width: 80, height: 60)
    title.anchorInCorner(.topLeft, xPad: 10, yPad: title.topEdge(), width: photo.leftEdge() - 20, height: title.textHeight())
    footer.anchorAndFillEdge(.bottom, xPad: 0, yPad: 0, otherSize: 60)
    toolbar.fillSuperview(left: 0, right: 0, top: 0, bottom: 10)
    toolbar.topBordered()
    toolbar.layoutSubviews()
    body.fillSuperview(left: 0, right: 0, top: 0, bottom: footer.height)
    toolbar.shadowed(UIColor.lightGray, offset: CGSize(width: 0, height: 10))
    toolbar.bottomBordered(UIColor.lightGray.lighter(), width: 1, padding: 1)
  }


}

extension String {
  func displayQrcode(_ image: UIImage?, info: String?) {
    let photo = UIImage(cgImage: EFQRCode.generate(content: self, watermark: image?.cgImage)!)
    openPhotoSlider(images: [photo], info: info)
  }
}

class UnconfirmedCell: CertCell {

  override func bindUI() {
    super.bindUI()
    status.whenTapped(self, action: #selector(statusTapped))
  }
  @objc func statusTapped() {
      API.post("/certs/\(self.data.id!)/confirm!", run: { (response, data) in
        self.data = Cert(JSON: response.result.value as! [String: AnyObject])!
        self.didDataUpdated(self.data)
      })
  }
}
class CertCell: CertBaseCell {
  override var data: Cert! { didSet {
    status.texted(data.status)
//    status.html(data.status?.toHtmlWithStyle())
    }}
  override func bindUI() {
    super.bindUI()
    status.whenTapped {
      API.put("/courses/\((self.data.course?.id!)!)/go") { (response, data) in
        let course = Course(JSON: response.result.value as! [String: AnyObject])!
        self.data = course.certs?.first
        self.data.course = course
        if course.percentage == 100 { delayedJob { self.didDataUpdated(self.data) }
        }
      }
    }
  }
}

class CertBaseCell: BaseStatusCell {

  var data: Cert! { didSet {
    title.texted(data.title!)
    expiredInfo.texted("到期日: \(data.expiredInfo!)")
//    status.texted(data.status!)
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
    body.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: expiredInfo.bottomEdge() + 40)
  }
}

class BaseStatusCell: BaseCell {
  var status = UIButton()
  override func layoutUI() {
    super.layoutUI()
    body.layout([status])
  }
  override func styleUI() {
    super.styleUI()
    status.styledAsSubButton()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    status.anchorCenterRight(withRightPadding: 10, width: status.textWidth() * 2, height: status.textHeight() * 2)
    title.anchorInCorner(.topLeft, xPad: 10, yPad: title.topEdge(), width: status.leftEdge() - 20, height: title.textHeight())
  }
}

class BaseCell: TableViewCell {
  var body = DefaultView()
  var footer = DefaultView()
  var toolbar = Toolbar()
  var title = UILabel()
  override func layoutUI() {
    super.layoutUI()
    layout([body.layout([title])])
    layout([footer.layout([toolbar])])
  }
  override func styleUI() {
    super.styleUI()
    title.asTitle()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    footer.anchorAndFillEdge(.bottom, xPad: 0, yPad: 0, otherSize: 10)
    body.fillSuperview(left: 0, right: 0, top: 0, bottom: footer.height)

    title.anchorAndFillEdge(.top, xPad: 10, yPad: 10, otherSize: title.textHeight())
    toolbar.fillSuperview(left: 0, right: 0, top: 0, bottom: 10)
    toolbar.bottomBordered()
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
    API.get("/certs") { (response, data) in
      self.collectionData = (response.result.value as! [[String: AnyObject]]).map { Cert(JSON: $0)! }
      _logForUIMode(self.collectionData, title: "collectionData")
    }
  }

}
