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

class HomeViewController: DefaultViewController, iCarouselDelegate, iCarouselDataSource {
  var datas = [Cert]() { didSet { slider.reloadData() }}
  let Identifier = "CELL"

  func loadData() {
    API.get("/certs") { (response, data) in
      let values = response.result.value as! [String: AnyObject]
      self.datas = Mapper<Cert>().mapArray(JSONObject: values["confirmed"])!
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }

  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    var label: UILabel
    var itemView: UIImageView
    let data = datas[index]
    if let view = view as? UIImageView {
      itemView = view
      label = itemView.viewWithTag(1) as! UILabel
    } else {
      itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth(), height: 400))
      itemView.styledAsFill().bordered(20, color: UIColor.white.cgColor).backgroundColored(UIColor.lightGray.lighter())
      itemView.imaged(data.photo?.thumb, placeholder: "loading")
      itemView.contentMode = .center

      label = UILabel()
      label.backgroundColor = .clear
      label.textAlignment = .center
//      label.font = label.font.withSize(20)
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

