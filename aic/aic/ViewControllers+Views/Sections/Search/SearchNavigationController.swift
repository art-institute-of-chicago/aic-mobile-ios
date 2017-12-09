//
//  SearchNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/7/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SearchNavigationController : CardNavigationController {
	let searchBar: UISearchBar = UISearchBar()
	let searchButton: UIButton = UIButton()
	let dividerLine: UIView = UIView()
	let searchResultsVC: SearchResultsViewController = SearchResultsViewController()
	
	var searchResultsTopConstraint: NSLayoutConstraint? = nil
	let searchResultsTopMargin: CGFloat = 90
	let searchResultsLowerTopMargin: CGFloat = 90
	
	override init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchBar.barTintColor = .aicDarkGrayColor
		searchBar.tintColor = .white
		searchBar.showsBookmarkButton = false
		searchBar.showsCancelButton = false
		searchBar.searchBarStyle = .prominent
		searchBar.backgroundColor = .aicDarkGrayColor
		searchBar.isTranslucent = false
		searchBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
		searchBar.placeholder = Common.Search.searchBarPlaceholder
		
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.backgroundColor = .aicDarkGrayColor
		searchTextField?.textColor = .white
		searchTextField?.font = .aicSearchBarFont
		searchTextField?.leftViewMode = .never
		
		searchButton.setImage(#imageLiteral(resourceName: "iconSearch"), for: .normal)
		searchButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
		
		dividerLine.backgroundColor = .white
		
		// Add subviews
		self.view.addSubview(searchBar)
		self.view.addSubview(searchButton)
		self.view.addSubview(dividerLine)
		self.rootVC.view.addSubview(searchResultsVC.view)
	}
	
	override func updateViewConstraints() {
		searchBar.autoPinEdge(.top, to: .top, of: self.view, withOffset: 32)
		searchBar.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 2)
		searchBar.autoPinEdge(.trailing, to: .leading, of: searchButton, withOffset: 12)
		searchBar.autoSetDimension(.height, toSize: 36)
		
		searchButton.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -6)
		searchButton.autoPinEdge(.bottom, to: .top, of: dividerLine, withOffset: 2)
		
		dividerLine.autoPinEdge(.top, to: .top, of: self.view, withOffset: 69)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
		
		searchResultsTopConstraint = searchResultsVC.view.autoPinEdge(.top, to: .top, of: self.rootVC.view, withOffset: searchResultsTopMargin)
		searchResultsVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
		searchResultsVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
		searchResultsVC.view.autoPinEdge(.bottom, to: .bottom, of: rootVC.view)
		
		super.updateViewConstraints()
	}
	
	override func cardWillShowFullscreen() {
		// show keyboard when the card shows
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.becomeFirstResponder()
	}
	
	override func handlePanGesture(recognizer: UIPanGestureRecognizer) {
		// dismiss the keyboard when the user taps to close the card
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		
		super.handlePanGesture(recognizer: recognizer)
	}
}

// MARK: UISearchBarDelegate
extension SearchNavigationController : UISearchBarDelegate {
	
}
