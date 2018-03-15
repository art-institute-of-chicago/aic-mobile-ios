/*
 Abstract:
 Main View controller
*/

import UIKit

class RootViewController: UIViewController {
    enum Mode {
        case loading
        case language
        case mainApp
    }
    
    var mode:Mode = .loading {
        didSet {
            modeDidChange()
        }
    }
    
    var loadingVC: LoadingViewController? = nil
//    var instructionsVC:InstructionsPageViewController? = nil
	var languageVC: LanguageSelectionViewController? = nil
	var sectionsVC: SectionsViewController? = nil
    
    var shouldShowLanguageSelection: Bool = false
	var loadingFadeOutAnimationStarted: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return !Common.Layout.showStatusBar
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = UIScreen.main.bounds
        
        registerSettingsBundle()
        
        // Check for first launch
        let defaults = UserDefaults.standard
        shouldShowLanguageSelection = defaults.bool(forKey: Common.UserDefaults.showLanguageSelectionUserDefaultsKey)
        
        // Set delegates
        AppDataManager.sharedInstance.delegate = self
        
        startLoading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.frame.origin.y = 0
        view.frame.size.height = UIScreen.main.bounds.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Register the app defaults
    private func registerSettingsBundle(){
        let defaults = UserDefaults.standard
        let appDefaults = [Common.UserDefaults.showLanguageSelectionUserDefaultsKey: true,
                           Common.UserDefaults.showHeadphonesUserDefaultsKey:true,
						   Common.UserDefaults.showEnableLocationUserDefaultsKey:true,
						   Common.UserDefaults.showMapTooltipsDefaultsKey:true]
        
        defaults.register(defaults: appDefaults)
        defaults.synchronize()
        
        // Reset defaults if testing instructions
        if Common.Testing.alwaysShowInstructions {
            defaults.set(true, forKey: Common.UserDefaults.showLanguageSelectionUserDefaultsKey)
            defaults.set(true, forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
            defaults.set(true, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
			defaults.set(true, forKey: Common.UserDefaults.showMapTooltipsDefaultsKey)
            defaults.synchronize()
        }
    }
    
    private func startLoading() {
        cleanUpViews()
        showLoadingVC()
    }
    
    
    // If loading got stopped (backgrounding the app?)
    // finish it up
    func resumeLoadingIfNotComplete() {
        if mode != .mainApp {
            startLoading()
        }
    }
    
    // Show a tour, called from deep link handling in app delegate
    func startTour(tour:AICTourModel) {
        // If we haven't loaded yet we should save the tour here
		sectionsVC?.showTourOnMap(tour: tour, language: tour.language, stopIndex: nil)
    }
    
    private func modeDidChange() {
        switch mode {
        case .loading:
            showLoadingVC()
        case .language:
            showLanguageVC()
        case .mainApp:
            showMainApp()
        }
    }
    
    private func showLoadingVC() {
        loadingVC = LoadingViewController()
        loadingVC?.delegate = self
        view.addSubview(loadingVC!.view)
		
		loadingVC?.playIntroVideoA()
    }
    
    private func showLanguageVC() {
        languageVC = LanguageSelectionViewController()
//        languageVC?.instructionsDelegate = self
		languageVC?.delegate = self
        self.view.addSubview(languageVC!.view)
		
		self.perform(#selector(preloadIntroVideoB), with: nil, afterDelay: languageVC!.fadeInOutAnimationDuration + languageVC!.contentViewFadeInOutAnimationDuration)
    }
	
	@objc func preloadIntroVideoB() {
		loadingVC?.loadIntroVideoB()
	}
    
    // Remove the intro and show the main app
    private func showMainApp() {
		if sectionsVC == nil {
			sectionsVC = SectionsViewController()
			sectionsVC?.delegate = self
		}
        view.insertSubview(sectionsVC!.view, belowSubview: loadingVC!.view)
		
//        sectionsVC!.setSelectedSection(sectionVC: sectionsVC!.toursVC)
        //sectionsVC!.animateInInitialView()
    }
    
    fileprivate func cleanUpViews() {
        // Remove and clean up language + loading
        languageVC?.view.removeFromSuperview()
        languageVC = nil
        
        loadingVC?.view.removeFromSuperview()
        loadingVC = nil
    }
}

// App Data Delegate
extension RootViewController : AppDataManagerDelegate{
    // Animate progress bar, play video when finished animating to 100%
    func downloadProgress(withPctCompleted pct: Float) {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.loadingVC?.updateProgress(forPercentComplete: pct)
            }, completion:  { (value:Bool) in
                if pct == 1.0 {
                    self.loadingVC?.hideProgressBar()
                    
                    if self.shouldShowLanguageSelection {
                        self.mode = .language
                    } else {
                        self.loadingVC?.loadIntroVideoB()
                        self.loadingVC?.playIntroVideoB()
                    }
                }
            }
        )
    }
    
    func downloadFailure(withMessage message: String) {
        let message =  message + "\n\n\(Common.DataConstants.dataLoadFailureMessage)"
        
        let alert = UIAlertController(title: Common.DataConstants.dataLoadFailureTitle, message: message, preferredStyle:UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: Common.DataConstants.dataLoadFailureButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
            // Try to load the data again
            AppDataManager.sharedInstance.load()
        })
        
        alert.addAction(action)
        
        present(alert, animated:true)
    }
}


// Loading VC delegate
extension RootViewController : LoadingViewControllerDelegate {
    func loadingDidFinishPlayingIntroVideoA() {
		AppDataManager.sharedInstance.load()
		loadingVC?.showProgressBar()
    }
	
	func loadingDidFinishPlayingIntroVideoB() {
		self.mode = .mainApp
	}
	
	func loadingDidFinishBuildingAnimation() {
		if loadingFadeOutAnimationStarted == true {
			return
		}
		loadingFadeOutAnimationStarted = true
		
		UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveLinear, animations: {
			self.loadingVC!.view.alpha = 0.0
		}, completion: { (completed3) in
			if completed3 == true {
				self.cleanUpViews()
			}
		})
	}
}

// Language Selection Delegate
extension RootViewController : LanguageSelectionViewControllerDelegate {
	func languageSelected(language: Common.Language) {
		// Record that we've got through the intro
		let defaults = UserDefaults.standard
		defaults.set(false, forKey: Common.UserDefaults.showLanguageSelectionUserDefaultsKey)
		defaults.synchronize()
		
		// Start the app
		//self.mode = .mainApp
		languageVC?.view.removeFromSuperview()
		languageVC = nil
		
		loadingVC?.playIntroVideoB()
	}
}

// Sections view controller Delegate
extension RootViewController : SectionsViewControllerDelegate {
    func sectionsViewControllerDidFinishAnimatingIn() {
		
    }
}
