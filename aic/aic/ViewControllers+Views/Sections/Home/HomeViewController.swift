//
//  HomeViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate : class {
	func buttonPressed()
}

class HomeViewController : SectionViewController {
	let scrollView: UIScrollView = UIScrollView()
	
	weak var delegate: HomeViewControllerDelegate? = nil
	
	override init(section: AICSectionModel) {
		super.init(section: section)
		
		self.view = UIView(frame: UIScreen.main.bounds)
		
		scrollView.frame.size = CGSize(width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
		scrollView.backgroundColor = .clear
		scrollView.delegate = self
		self.view.addSubview(scrollView)
		
		let num: Int = 14
		for i in 0...num {
			let v = UIButton(frame: CGRect(x: 20, y: CGFloat(i*70) + 240.0 - 44.0, width: 130, height: 50))
			v.backgroundColor = UIColor(red: CGFloat(i) / CGFloat(num), green: CGFloat(i) / CGFloat(num), blue: CGFloat(i) / CGFloat(num), alpha: 1)
			v.addTarget(self, action: #selector(buttonPressed(button:)), for: UIControlEvents.touchUpInside)
			scrollView.addSubview(v)
			scrollView.contentSize.height = CGFloat(i*70) + 240.0 + 50
		}
		
		scrollView.contentSize.height += 20
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.scrollDelegate?.sectionViewControllerWillAppearWithScrollView(scrollView: self.scrollView)
	}
	
	@objc private func buttonPressed(button: UIButton) {
		print("button pressed")
		self.delegate?.buttonPressed()
	}
	
	override func updateViewConstraints() {
		scrollView.snp.makeConstraints({ (make) -> Void in
			make.edges.equalTo(scrollView.superview!).priority(Common.Layout.Priority.required.rawValue)
		})
		super.updateViewConstraints()
	}
}

extension HomeViewController : UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
	}
}
