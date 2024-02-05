/*
Abstract:
Main View controller
*/

import UIKit

final class RootViewController: UIViewController {
  private let defaults = UserDefaults.standard
  private var state: ContentState = .loadingInProgress {
    didSet {
      switch self.state {
      case .loadingInProgress:
        startLoadingData()

      case .languageSelection:
        showLanguageViewController()

      case .homeTransition:
        showMainViewController()
      }
    }
  }

  private lazy var loadingViewController: LoadingViewController = {
    let shouldShowLanguageSelection = defaults.bool(forKey: Common.UserDefaults.showLanguageSelectionUserDefaultsKey)
    let viewController = LoadingViewController(showFullVideo: !shouldShowLanguageSelection)
    viewController.delegate = self
    return viewController
  }()

  private lazy var languageViewController: LanguageSelectionViewController = {
    let viewController = LanguageSelectionViewController()
    viewController.delegate = self
    return viewController
  }()

  private lazy var sectionTabBarController: SectionsViewController = {
    let viewController = SectionsViewController()
    viewController.sectionTabBarDelegate = self
    return viewController
  }()

	override var prefersStatusBarHidden: Bool { !Common.Layout.showStatusBar }
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

	override func viewDidLoad() {
		super.viewDidLoad()
    setup()
	}

	// If loading got stopped (backgrounding the app?)
	func resumeLoadingIfNotComplete() {
		if state != .homeTransition {
			startLoadingData()
		}
	}

	// Show a tour, called from deep link handling in app delegate
	func startTour(tour: AICTourModel) {
		// If we haven't loaded yet we should save the tour here
    sectionTabBarController.showTourOnMapFromLink(tour: tour, language: Common.currentLanguage)
	}

}

// MARK: AppDataManagerDelegate
extension RootViewController: AppDataManagerDelegate {
	// Animate progress bar, play video when finished animating to 100%
	func downloadProgress(withPctCompleted pct: Float) {
		UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [weak self] in
      guard let self else { return }
			self.loadingViewController.updateProgress(forPercentComplete: pct)
		}, completion: { _ in
			if pct == 1.0 {
				self.loadingViewController.playIntroVideo()
			}
		})
	}

	func downloadFailure(withMessage message: String) {
		let message =  message + "\n\n\(Common.Constants.dataLoadFailureMessage)"

		let alert = UIAlertController(title: Common.Constants.dataLoadFailureTitle, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: Common.Constants.dataLoadFailureButtonTitle, style: .default, handler: { (_) in
			// Try to load the data again
			AppDataManager.sharedInstance.load(forceAppDataDownload: true)
		})

		alert.addAction(action)
		present(alert, animated: true)
	}
}

// MARK: LoadingViewControllerDelegate
extension RootViewController: LoadingViewControllerDelegate {

	func loadingDidFinishPlayingIntroVideoA() {
		if state != .languageSelection {
      state = .languageSelection
		}
	}

	func loadingDidFinish() {
		if state != .homeTransition {
      state = .homeTransition
		}
	}

}

// MARK: LanguageSelectionViewControllerDelegate
extension RootViewController: LanguageSelectionViewControllerDelegate {

	func languageSelected(language: Common.Language) {
		// Record that we've got through the intro
		defaults.set(false, forKey: Common.UserDefaults.showLanguageSelectionUserDefaultsKey)
		defaults.synchronize()

    languageViewController.remove()
		loadingViewController.playIntroVideo()
	}

}

// MARK: SectionsViewControllerDelegate
extension RootViewController: SectionsViewControllerDelegate {

	func sectionsViewControllerDidFinishAnimatingIn() {
		removeChildViewControllers()
	}

}

// MARK: Private - Setup
private extension RootViewController {

  func setup() {
    registerSettingsBundle()
    setupDelegate()
    startLoadingData()
  }

  func startLoadingData() {
    loadData()
    removeChildViewControllers()
    showLoadingViewController()
  }

  func loadData() {
    AppDataManager.sharedInstance.load()
  }

  func setupDelegate() {
    AppDataManager.sharedInstance.delegate = self
  }

}

// MARK: Private - Handle child view controller transition
private extension RootViewController {

  func showMainViewController() {
    self.add(sectionTabBarController)
    sectionTabBarController.animateInInitialView()
  }

  func showLoadingViewController() {
    self.add(loadingViewController)
  }

  func showLanguageViewController() {
    self.add(languageViewController)
    let executeAfterDelay = languageViewController.fadeInOutAnimationDuration + languageViewController.contentViewFadeInOutAnimationDuration
    self.perform(#selector(preloadIntroVideoB), with: nil, afterDelay: executeAfterDelay)
  }

  @objc func preloadIntroVideoB() {
    loadingViewController.loadIntroVideoB()
  }

  func removeChildViewControllers() {
    languageViewController.remove()
    loadingViewController.remove()
  }

}

// MARK: Private - Register the app defaults
private extension RootViewController {

  func registerSettingsBundle() {
    let appDefaults = [Common.UserDefaults.showLanguageSelectionUserDefaultsKey: true,
                       Common.UserDefaults.showHeadphonesUserDefaultsKey: true,
                       Common.UserDefaults.showEnableLocationUserDefaultsKey: true,
                       Common.UserDefaults.showTooltipsDefaultsKey: true]

    defaults.register(defaults: appDefaults)
    defaults.synchronize()

    // Reset defaults if testing instructions
    if Common.Testing.alwaysShowInstructions {
      defaults.set(true, forKey: Common.UserDefaults.showLanguageSelectionUserDefaultsKey)
      defaults.set(true, forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
      defaults.set(true, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
      defaults.set(true, forKey: Common.UserDefaults.showTooltipsDefaultsKey)
      defaults.synchronize()
    }
  }

}
