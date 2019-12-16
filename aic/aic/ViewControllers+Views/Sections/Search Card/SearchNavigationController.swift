//
//  SearchNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/7/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class SearchNavigationController: CardNavigationController {
	let backButton: UIButton = UIButton()
	let searchBar: UISearchBar = UISearchBar()
	let searchButton: UIButton = UIButton()
	let dividerLine: UIView = UIView()
	let filterMenuView: ResultsFilterMenuView = ResultsFilterMenuView()
	let resultsVC: ResultsTableViewController = ResultsTableViewController()
	var currentTableView: UITableView

	private let slideAnimator: SearchSlideAnimator = SearchSlideAnimator()

	private var searchBarLeadingConstraint: NSLayoutConstraint?
	private var searchBarActiveLeading: CGFloat = 2
	private var searchBarInactiveLeading: CGFloat = 32

	private var resultsTopMarginConstraint: NSLayoutConstraint?
	private let resultsTopMargin: CGFloat = 80
	private let resultsWithFilterMenuTopMargin: CGFloat = 80 + ResultsFilterMenuView.menuHeight

	weak var sectionsVC: SectionsViewController?

	// Analytics
	enum TrackSearchLoadType {
		case none
		case loadWhileTyping
		case searchButton
		case promotedString
		case autocompleteString
	}
	var trackLoadingType: TrackSearchLoadType = .none
	var trackUserTypeSearchText: Bool = false
	var trackUserSelectedContent: Bool = false

	init() {
		currentTableView = resultsVC.tableView
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		SearchDataManager.sharedInstance.delegate = self

		backButton.isEnabled = false
		backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
		backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		backButton.addTarget(self, action: #selector(backButtonPressed(button:)), for: .touchUpInside)

		searchBar.barTintColor = .aicDarkGrayColor
		searchBar.tintColor = .white
		searchBar.showsBookmarkButton = false
		searchBar.showsCancelButton = false
		searchBar.searchBarStyle = .prominent
		searchBar.backgroundColor = .aicDarkGrayColor
		searchBar.isTranslucent = false
		searchBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
		searchBar.setImage(#imageLiteral(resourceName: "searchClear"), for: .clear, state: .normal)
		searchBar.placeholder = "Search Prompt".localized(using: "Search")
		searchBar.keyboardAppearance = .dark
		searchBar.delegate = self

		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.backgroundColor = .aicDarkGrayColor
		searchTextField?.textColor = .white
		searchTextField?.font = .aicSearchBarFont
		searchTextField?.leftViewMode = .never

		searchButton.setImage(#imageLiteral(resourceName: "iconSearch"), for: .normal)
		searchButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		searchButton.addTarget(self, action: #selector(searchButtonPressed(button:)), for: .touchUpInside)

		dividerLine.backgroundColor = .white

		filterMenuView.isHidden = true
		filterMenuView.delegate = self
		filterMenuView.setSelected(filter: .empty)

		resultsVC.searchDelegate = self

		// Add subviews
		self.view.addSubview(searchBar)
		self.view.addSubview(searchButton)
		self.view.addSubview(backButton)
		self.view.addSubview(dividerLine)

		// Add main VC as subview to rootVC
		resultsVC.willMove(toParent: rootVC)
		rootVC.view.addSubview(resultsVC.view)
		resultsVC.didMove(toParent: rootVC)

		// Add filter menu
		rootVC.view.insertSubview(filterMenuView, aboveSubview: resultsVC.view)

		createViewConstraints()

		// NavigationController Delegate
		self.delegate = self

		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)

		// Accessibility
		downArrowButton.accessibilityLabel = "Close Search"
		backButton.accessibilityElementsHidden = true
		backButton.accessibilityLabel = "Back"
		searchButton.accessibilityLabel = "Search"
		self.accessibilityElements = [
			downArrowButton,
			searchBar,
			searchButton,
			resultsVC.tableView
		]
	}

	private func createViewConstraints() {
		searchBar.autoPinEdge(.top, to: .top, of: self.view, withOffset: 32)
		searchBarLeadingConstraint = searchBar.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 2)
		searchBar.autoPinEdge(.trailing, to: .leading, of: searchButton, withOffset: 12)
		searchBar.autoSetDimension(.height, toSize: 36)

		backButton.autoPinEdge(.trailing, to: .leading, of: searchBar, withOffset: 16)
		backButton.autoPinEdge(.bottom, to: .top, of: dividerLine, withOffset: 2)

		searchButton.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -6)
		searchButton.autoPinEdge(.bottom, to: .top, of: dividerLine, withOffset: 2)

		dividerLine.autoPinEdge(.top, to: .top, of: self.view, withOffset: 69)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)

		resultsTopMarginConstraint = resultsVC.view.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: resultsTopMargin)
		resultsVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
		resultsVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
		resultsVC.view.autoPinEdge(.bottom, to: .bottom, of: rootVC.view, withOffset: -Common.Layout.tabBarHeight)

		filterMenuView.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: resultsTopMargin)
		filterMenuView.autoPinEdge(.leading, to: .leading, of: rootVC.view)
		filterMenuView.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
		filterMenuView.autoPinEdge(.bottom, to: .top, of: rootVC.view, withOffset: resultsTopMargin + ResultsFilterMenuView.menuHeight)
	}

	override func setCardPosition(_ positionY: CGFloat) {
		super.setCardPosition(positionY)
		if positionY > Common.Layout.cardFullscreenPositionY + 50 {
			currentTableView.panGestureRecognizer.isEnabled = false
		} else {
			currentTableView.panGestureRecognizer.isEnabled = true
		}
	}

	// MARK: Accessibility

	private func updateAccessibilityElementsForSearch() {
		var accessibilityItems: [Any] = [
			downArrowButton,
			searchBar,
			searchButton
		]
		if filterMenuView.isHidden == false {
			accessibilityItems.append(filterMenuView)
		}
		accessibilityItems.append(resultsVC.view)

		self.accessibilityElements = accessibilityItems
	}

	private func updateAccessibilityElementsForContentPage(contentVC: SearchContentViewController) {
		self.accessibilityElements = [
			downArrowButton,
			backButton,
			contentVC.view
		]
	}

	// MARK: Language

	@objc func updateLanguage() {
		searchBar.placeholder = "Search Prompt".localized(using: "Search")
		resultsVC.tableView.reloadData()
		filterMenuView.suggestedButton.setTitle("Suggested".localized(using: "Search"), for: .normal)
		filterMenuView.artworksButton.setTitle("Artworks".localized(using: "Search"), for: .normal)
		filterMenuView.toursButton.setTitle("Tours".localized(using: "Search"), for: .normal)
		filterMenuView.exhibitionsButton.setTitle("Exhibitions".localized(using: "Search"), for: .normal)
		filterMenuView.updateConstraints()
	}

	// MARK: Show/Hide

	override func cardWillShowFullscreen() {
		if viewControllers.count < 2 && currentState != .fullscreen {
			// show keyboard when the card shows
			DispatchQueue.main.async {
				let searchTextField = self.searchBar.value(forKey: "searchField") as? UITextField
				searchTextField?.becomeFirstResponder()
			}
		}

		resultsVC.view.setNeedsLayout()
		resultsVC.view.layoutIfNeeded()
		updateLanguage()
	}

	override func cardDidShowFullscreen() {
		resultsVC.view.setNeedsLayout()
		resultsVC.view.layoutIfNeeded()

		// Log analytics
		AICAnalytics.trackScreenView("Search", screenClass: "SearchNavigationController")
	}

	override func cardWillHide() {
		// dismiss the keyboard when the user taps to close the card
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()

		if let searchText = searchTextField?.text {
			if trackUserTypeSearchText == true && trackUserSelectedContent == false {
				trackUserTypeSearchText = false // for this text, stop traking analytics until user changes search

				var searchTermSource: AICAnalytics.SearchTermSource = .TextInput
				if trackLoadingType == .autocompleteString {
					searchTermSource = .Autocomplete
				} else if trackLoadingType == .promotedString {
					searchTermSource = .Promoted
				} else {
					searchTermSource = .TextInput
				}
				AICAnalytics.sendSearchAbandonedEvent(searchTerm: searchText, searchTermSource: searchTermSource)
			}
		}
	}

	override func handlePanGesture(recognizer: UIPanGestureRecognizer) {
		// dismiss the keyboard when the user taps to close the card
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()

		super.handlePanGesture(recognizer: recognizer)
	}

	private func showBackButton() {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.clearButtonMode = .never
		searchBar.isUserInteractionEnabled = false
		searchButton.isHidden = true
		backButton.isEnabled = true
		UIView.animate(withDuration: 0.3) {
			self.searchBarLeadingConstraint?.constant = self.searchBarInactiveLeading
			self.view.layoutIfNeeded()
		}
	}

	private func hideBackButton() {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.clearButtonMode = .always
		searchBar.isUserInteractionEnabled = true
		searchButton.isHidden = false
		backButton.isEnabled = false
		UIView.animate(withDuration: 0.3) {
			self.searchBarLeadingConstraint?.constant = self.searchBarActiveLeading
			self.view.layoutIfNeeded()
		}
	}

	private func showSearchContentViewController(tableVC: UITableViewController) {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()

		showBackButton()

		currentTableView = tableVC.tableView

		let contentVC = SearchContentViewController(tableVC: tableVC)
		self.pushViewController(contentVC, animated: true)

		// Accessibility
		updateAccessibilityElementsForContentPage(contentVC: contentVC)
	}

	// MARK: Load Search

	private func loadSearch(searchText: String, showAutocomplete: Bool) {
		resultsVC.resetContentLoaded()

		// Reset perform requests in SearchDataManager
		NSObject.cancelPreviousPerformRequests(withTarget: SearchDataManager.sharedInstance)

		if showAutocomplete == true {
			// Autocomplete request sent almost immediately
			SearchDataManager.sharedInstance.perform(#selector(SearchDataManager.loadAutocompleteStrings(searchText:)), with: searchText, afterDelay: 0.3)
		}

		// Artworks/Tours/Exhibitions requests sent with delay
		// to avoid making too many requests to the api while typing
		SearchDataManager.sharedInstance.perform(#selector(SearchDataManager.loadAllContent(searchText:)), with: searchText, afterDelay: 0.5)

		if resultsVC.filter == .empty {
			resultsTopMarginConstraint?.constant = resultsWithFilterMenuTopMargin
			self.view.setNeedsLayout()
			self.view.layoutIfNeeded()

			filterMenuView.isHidden = false
			filterMenuView.setSelected(filter: .suggested)

			resultsVC.filter = .suggested

			// Accessibility
			updateAccessibilityElementsForSearch()
		} else {
			resultsVC.tableView.reloadData()
		}
	}

	// MARK: Buttons

	@objc private func searchButtonPressed(button: UIButton) {
		if let searchText = searchBar.text {
			if searchText.isEmpty == false {
				// dismiss the keyboard when the user taps to close the card
				let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
				searchTextField?.resignFirstResponder()
				searchTextField?.layoutIfNeeded()

				trackLoadingType = .searchButton
				loadSearch(searchText: searchText, showAutocomplete: false)
			}
		}
	}

	@objc private func backButtonPressed(button: UIButton) {
		currentTableView = resultsVC.tableView
		hideBackButton()
		self.popViewController(animated: true)
		self.view.layoutIfNeeded()

		// Accessibility
		updateAccessibilityElementsForSearch()
	}

	@objc private func trackLoadedSearch() {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		if let searchText = searchTextField?.text {
			if trackLoadingType != .none {
				// Log Search No Results Event
				if resultsVC.isAllContentLoadedWithNoResults() {
					var searchTermSource: AICAnalytics.SearchTermSource = .TextInput
					if trackLoadingType == .autocompleteString {
						searchTermSource = .Autocomplete
					} else if trackLoadingType == .promotedString {
						searchTermSource = .Promoted
					} else {
						searchTermSource = .TextInput
					}
					AICAnalytics.sendSearchNoResultsEvent(searchTerm: searchText, searchTermSource: searchTermSource)
				}
			}
		}
	}
}

// MARK: Search Bar Delegate

extension SearchNavigationController: UISearchBarDelegate, UITextFieldDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count > 0 {
			// Log Analytics
			trackUserTypeSearchText = true
			trackLoadingType = searchText.count >= 3 ? .loadWhileTyping : .none

			// Reset previous perform requests to track loaded search
			NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(trackLoadedSearch), object: nil)

			// Load new search
			loadSearch(searchText: searchText, showAutocomplete: true)
		} else {
			trackUserTypeSearchText = false

			resultsTopMarginConstraint?.constant = resultsTopMargin
			self.view.setNeedsLayout()
			self.view.layoutIfNeeded()

			filterMenuView.isHidden = true

			resultsVC.filter = .empty

			// Accessibility
			updateAccessibilityElementsForSearch()
		}
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let searchText = searchBar.text {
			if searchText.isEmpty == false {
				// dismiss the keyboard when the user taps to close the card
				let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
				searchTextField?.resignFirstResponder()
				searchTextField?.layoutIfNeeded()

				trackLoadingType = .searchButton
				loadSearch(searchText: searchText, showAutocomplete: false)
			}
		}
	}

	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		if let searchText = searchBar.text {
			if trackUserTypeSearchText == true && trackUserSelectedContent == false {
				// Log Analytics
				var searchTermSource: AICAnalytics.SearchTermSource = .TextInput
				if trackLoadingType == .autocompleteString {
					searchTermSource = .Autocomplete
				} else if trackLoadingType == .promotedString {
					searchTermSource = .Promoted
				} else {
					searchTermSource = .TextInput
				}
				AICAnalytics.sendSearchAbandonedEvent(searchTerm: searchText, searchTermSource: searchTermSource)
			}
		}

		return true
	}
}

// MARK: Search Data Manager Delegate

extension SearchNavigationController: SearchDataManagerDelegate {
	func searchDataDidFinishLoading(autocompleteStrings: [String]) {
		resultsVC.autocompleteStringItems = autocompleteStrings
		resultsVC.tableView.reloadData()
		self.view.layoutIfNeeded()
	}

	func searchDataDidFinishLoading(artworks: [AICSearchedArtworkModel], tours: [AICTourModel], exhibitions: [AICExhibitionModel]) {
		resultsVC.setContentLoadedForFilter(filter: .artworks, loaded: true)
		resultsVC.setContentLoadedForFilter(filter: .tours, loaded: true)
		resultsVC.setContentLoadedForFilter(filter: .exhibitions, loaded: true)
		resultsVC.artworkItems = artworks
		resultsVC.tourItems = tours
		resultsVC.exhibitionItems = exhibitions
		resultsVC.tableView.reloadData()
		self.view.layoutIfNeeded()

		// Log analytics
		trackUserSelectedContent = resultsVC.isAllContentLoadedWithNoResults() // if no results, pretend user selected content so you don't track abandoned
		// Reset previous perform requests to track loaded search
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(trackLoadedSearch), object: nil)
		self.perform(#selector(trackLoadedSearch), with: nil, afterDelay: 1.0) // track loaded search after a few seconds
	}

	func searchDataFailure(filter: Common.Search.Filter) {
		resultsVC.setContentLoadedForFilter(filter: filter, loaded: true)
		resultsVC.tableView.reloadData()
		self.view.layoutIfNeeded()
	}
}

// MARK: ResultsTableViewControllerDelegate

extension SearchNavigationController: ResultsTableViewControllerDelegate {
	func resultsTableDidSelect(promotedText: String) {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.text = promotedText
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()

		trackLoadingType = .promotedString
		loadSearch(searchText: promotedText, showAutocomplete: false)
	}

	func resultsTableDidSelect(autocompleteText: String) {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.text = autocompleteText
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()

		trackLoadingType = .autocompleteString
		loadSearch(searchText: autocompleteText, showAutocomplete: false)
	}

	func resultsTableDidSelect(artwork: AICSearchedArtworkModel) {
		let artworkVC = ArtworkTableViewController(artwork: artwork)
		artworkVC.artworkTableDelegate = self.sectionsVC // set tourTableDelegate to the parent SectionsViewController
		showSearchContentViewController(tableVC: artworkVC)

		// Log analytics
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		let searchText = (searchTextField!.text ?? "")
		var searchTermSource: AICAnalytics.SearchTermSource = .TextInput
		if trackLoadingType == .autocompleteString {
			searchTermSource = .Autocomplete
		} else if trackLoadingType == .promotedString {
			searchTermSource = .Promoted
		} else {
			searchTermSource = .TextInput
		}
		AICAnalytics.sendSearchTappedArtworkEvent(searchedArtwork: artwork, searchTerm: searchText, searchTermSource: searchTermSource)
	}

	func resultsTableDidSelect(tour: AICTourModel) {
		let tourVC = TourTableViewController(tour: tour)
		tourVC.tourTableDelegate = self.sectionsVC // set tourTableDelegate to the parent SectionsViewController
		showSearchContentViewController(tableVC: tourVC)

		// Log analytics
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		let searchText = (searchTextField!.text ?? "")
		var searchTermSource: AICAnalytics.SearchTermSource = .TextInput
		if trackLoadingType == .autocompleteString {
			searchTermSource = .Autocomplete
		} else if trackLoadingType == .promotedString {
			searchTermSource = .Promoted
		} else {
			searchTermSource = .TextInput
		}
		AICAnalytics.sendSearchTappedTourEvent(tour: tour, searchTerm: searchText, searchTermSource: searchTermSource)
	}

	func resultsTableDidSelect(exhibition: AICExhibitionModel) {
		let exhibitionVC = ExhibitionTableViewController(exhibition: exhibition)
		exhibitionVC.exhibitionTableDelegate = self.sectionsVC // set tourTableDelegate to the parent SectionsViewController
		showSearchContentViewController(tableVC: exhibitionVC)

		// Log analytics
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		let searchText = (searchTextField!.text ?? "")
		var searchTermSource: AICAnalytics.SearchTermSource = .TextInput
		if trackLoadingType == .autocompleteString {
			searchTermSource = .Autocomplete
		} else if trackLoadingType == .promotedString {
			searchTermSource = .Promoted
		} else {
			searchTermSource = .TextInput
		}
		AICAnalytics.sendSearchTappedExhibitionEvent(exhibition: exhibition, searchTerm: searchText, searchTermSource: searchTermSource)
	}

	func resultsTableDidSelect(filter: Common.Search.Filter) {
		filterMenuView.setSelected(filter: filter)
		resultsVC.filter = filter
	}

	func resultsTableViewWillScroll() {
		// dismiss the keyboard when the user scrolls results
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()
	}
}

// MARK: Filter Menu Delegate

extension SearchNavigationController: FilterMenuDelegate {
	func filterMenuSelected(filter: Common.Search.Filter) {
		filterMenuView.setSelected(filter: filter)
		resultsVC.filter = filter

		// Remove autocomplete, since the user has shown intention to look for results on this search string
		resultsVC.autocompleteStringItems.removeAll()
	}
}

// MARK: UINavigationControllerDelegate

extension SearchNavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController,
							  animationControllerFor operation: UINavigationController.Operation,
							  from fromVC: UIViewController,
							  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		slideAnimator.isAnimatingIn = (operation == .push)
		return slideAnimator
	}
}

// MARK: Pan Gesture

extension SearchNavigationController {
	override internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer == cardPanGesture {
			if currentTableView != resultsVC.tableView && currentTableView.contentOffset.y <= 0 {
				return true
			}
		}
		return false
	}
}
