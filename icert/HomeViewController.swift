//
//  HomeViewController.swift
//  icert
//
//  Created by ctslin on 26/12/2017.
//  Copyright © 2017 ctslin. All rights reserved.
//

import SwiftEasyKit
import ObjectMapper
//import BeastComponents
import iCarousel


class CertViewerViewController: Scrollable2ViewController {
  
  let backgrouncColor = UIColor.white
  var validationUrl: String!
  var data: Cert? { didSet {
    photo.imaged(data?.photo?.url)
    infoView.data = data
    validationUrl = "/certs/\((data?.id!)!)".hostUrl()
    qrcode.image = validationUrl.toQrcode(watermark: photo.image)
    delayedJob { self.viewDidLayoutSubviews() }
    }}
  var photo = UIImageView()
  var closeButton = UIButton(image: getIcon(.close, options: ["color": UIColor.black.lighter()]))
  var infoView = InfoView()
  var qrcode = UIImageView()
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func layoutUI() {
    super.layoutUI()
    contentView.layout([photo, closeButton, infoView, qrcode])
    closeButton.isHidden = true
  }

  override func styleUI() {
    super.styleUI()
    contentView.backgroundColored(backgrouncColor)
    title = ""
    infoView.backgroundColored(UIColor.white)
    qrcode.bordered(1, color: K.Color.Text.normal.cgColor)
    automaticallyAdjustsScrollViewInsets = true
    contentView.delegate = self
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= 3 { closeTapped() }
  }

  override func bindUI() {
    super.bindUI()
    closeButton.whenTapped {
      self.dismiss(animated: true, completion: nil)
    }
    qrcode.whenTapped(self, action: #selector(qrcodeTapped))
    view.whenDoubleTapped(self, action: #selector(viewDoubleTapped))
  }
  
  @objc func viewDoubleTapped() {
    closeTapped()
  }

  @objc func qrcodeTapped() {
    let vc = WebViewController(title: "認證", url: validationUrl)
    vc.enableCloseBarButtonItem()
    openViewController(vc)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let y: CGFloat = 0
    closeButton.anchorInCorner(.topRight, xPad: 10, yPad: y, width: K.BarButtonItem.size, height: K.BarButtonItem.size)
    self.photo.anchorAndFillEdge(.top, xPad: 0, yPad: y + 30, otherSize: self.photo.scaledHeight(screenWidth()))
    let w = screenWidth()
    infoView.alignUnder(photo, matchingCenterWithTopPadding: 0, width: w, height: infoView.title.getHeightByWidth(w))
    qrcode.alignUnder(infoView, matchingCenterWithTopPadding: 0, width: 150, height: 150)
    contentView.setLastSubiewAs(qrcode)
  }

  class InfoView: DefaultView {
    var title = UITextView()
    var data: Cert? { didSet {
      title.attributedText = data?.info?.toHtmlWithStyle()
      }}
    override func layoutUI() {
      super.layoutUI()
      layout([title])
    }
    override func styleUI() {
      super.styleUI()
//      title.styled
    }
    override func bindUI() {
      super.bindUI()
      title.isEditable = false
    }
    override func layoutSubviews() {
      super.layoutSubviews()
      title.fillSuperview(left: 0, right: 0, top: 0, bottom: 0)
    }
  }
}

class HomeViewController: DefaultViewController, iCarouselDelegate, iCarouselDataSource {
  var datas = [Cert]() { didSet { slider.reloadData() }}
  let Identifier = "CELL"

  func loadData() {
    datas = []
    API.get("/certs") { (response, data) in
      let values = response.result.value as! [String: AnyObject]
      self.datas = Mapper<Cert>().mapArray(JSONObject: values["confirmed"])!
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    loadData()
  }

  func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
    let vc = CertViewerViewController()
    let data = datas[index]
    vc.data = data
    currentViewController.present(vc, animated: true, completion: {
    })
//    openPhotoSlider(imageURLs: [(data.photo?.url)!], infos: [data.info!])
  }

  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    var label: UILabel
    var itemView: UIImageView
    let data = datas[index]
    if let view = view as? UIImageView {
      itemView = view
      label = itemView.viewWithTag(1) as! UILabel
    } else {
      let w = screenWidth()
      itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: w, height: 400))
      itemView.styled().bordered(20, color: UIColor.white.cgColor).backgroundColored(UIColor.lightGray.lighter())
      itemView.imaged(data.photo?.thumb, placeholder: "loading")
      itemView.frame = CGRect(x: 0, y: 0, width: w, height: itemView.scaledHeight(w))
      itemView.contentMode = .center

      label = UILabel()
      label.backgroundColor = .clear
      label.textAlignment = .center
      label.backgroundColored(UIColor.white.withAlphaComponent(0.9))
      label.adjustsFontSizeToFitWidth = true
      label.tag = 1
      itemView.addSubview(label)
      label.anchorAndFillEdge(.top, xPad: 20, yPad: 20, otherSize: 30)
    }
    label.texted(data.title)
    return itemView
  }

  var slider = iCarousel(frame: .zero)
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  override func bindUI() {
    super.bindUI()
    view.layout([slider])
    loadData()
    addRightBarButtonItem(.refresh, action: #selector(refreshTapped))
  }

  @objc func refreshTapped() {
    loadData()
  }

  override func styleUI() {
    super.styleUI()
    slider.type = .coverFlow2
    slider.isVertical = true
    slider.delegate = self
    slider.dataSource = self
    slider.backgroundColored(UIColor.black.lighter(0.3))
  }

  class Slide: DefaultView {
    var data: Cert? { didSet {
      title.texted(data?.title)
      image.imaged(data?.photo?.thumb)
      }}
    var title = UILabel()
    var image = UIImageView()
    override func layoutUI() {
      super.layoutUI()
      layout([title, image])
    }
    override func styleUI() {
      super.styleUI()
      title.styled().larger(5).centered().bold().shadowed()._coloredWithSuperviews()
      image.bordered()
    }
    override func layoutSubviews() {
      super.layoutSubviews()
      title.anchorAndFillEdge(.top, xPad: 10, yPad: 10, otherSize: title.textHeight())
      image.fillSuperview()
    }
  }

  func numberOfItems(in carousel: iCarousel) -> Int {
    return datas.count
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    slider.fillSuperview(left: 0, right: 0, top: 0, bottom: tabBarHeight())
  }

//  func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
//    if (option == .spacing) {
//      return value * 1.1
//    }
//    return value
//  }

}

//class HomeBCCoverFlowViewController: DefaultViewController, BCCoverFlowViewDataSource, BCCoverFlowViewDelegate {
//
//  var datas = [Cert]() { didSet {
//    self.slider.reloadData()
//    }}
//  var slider = BCCoverFlowView(frame: .zero)
//  let Identifier = "CELL"
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    titled("iCert")
//    view.layout([slider])
//    slider.register(class: CertPoster.self, forCoverReuseIdentifier: Identifier)
//    slider.dataSource = self
//    slider.delegate = self
//    loadData()
//  }
//
//  override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    slider.fillSuperview(left: 0, right: 0, top: 0, bottom: 20)
//    slider.coverFlowStyle = .bottom
//    slider.heightOverPassed = 60
////    coverFlowView.heightOfAreaBeyondTopCover = 10
//    slider.gradientColorForStream = .black
//  }
//
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    loadData()
//  }
//
//  class CertPoster: BCCoverContentView {
//    var title = UILabel()
//    var imageView = UIImageView()
//    var data: Cert? {
//      didSet {
//        title.texted(data?.title).styled().centered().larger(3).darker().shadowed()
//        imageView.imaged(data?.photo?.url, placeholder: "loading").bordered(20, color: UIColor.white.cgColor)
//      }
//    }
//
//    override func prepareForReuse() {
//      super.prepareForReuse()
//      title.text = nil
//      imageView.image = UIImage(named: "loading")
//    }
//
//    override func layoutSubviews() {
//      super.layoutSubviews()
//      layout([imageView, title])
//      title.anchorAndFillEdge(.top, xPad: 0, yPad: 20, otherSize: title.textHeight())
////      title._coloredWithSuperviews()
//      imageView.fillSuperview(left: 0, right: 0, top: 0, bottom: 20)
//    }
//  }
//
//  func loadData() {
//    API.get("/certs") { (response, data) in
//      let values = response.result.value as! [String: AnyObject]
//      self.datas = Mapper<Cert>().mapArray(JSONObject: values["confirmed"])!
//    }
//  }
//
//  func numberOfCovers(in coverFlowView: BCCoverFlowView) -> Int {
//    return datas.count
//  }
//
//  func coverFlowView(_ coverFlowView: BCCoverFlowView, contentAt index: Int) -> BCCoverContentView {
//    let coverView = coverFlowView.dequeueReusableCoverContentView(withIdentifier: Identifier, for: index) as! CertPoster
//    coverView.data = datas[index]
//    return coverView
//  }
//
//
//}

