/*
 Abstract:
 Page View controller for introduction (instructional) screens
 Adapted from https://www.raywenderlich.com/122139/uiscrollview-tutorial (part at bottom)
 */
import UIKit

protocol IntroPageViewControllerDelegate : class {
    func introPageGetStartedButtonTapped()
}

class InstructionsPageViewController: UIPageViewController {
    // Can not override delegate from superview, need to have this janky delegate name :/
    weak var instructionsDelegate:IntroPageViewControllerDelegate? = nil
    
    var currentIndex = 0
    var currentPage = 0
    
    let fadeInAnimationDuration = 0.25
    
    let backgroundAlpha:CGFloat = 0.9
    let backgroundAnimationDuration = 0.25
	
	let blurBGView:UIView = getBlurEffectView(frame: UIScreen.main.bounds)
    
    let pageControlMarginBottom:CGFloat = 40
    
    let getStartedSize = CGSize(width: 300.0 * 0.80213904, height: 50)
    let getStartedMarginBottom:CGFloat = 105
    let getStartedButton = InstructionsGetStartedButton()
    
    init() {
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
		
        // Init the first item view controller
        if let viewController = viewInstructionsItemController(currentPage) {
            let viewControllers = [viewController]
            
            // Set them
            setViewControllers(
                viewControllers,
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    
        // Set page control styles
        let pageControl = UIPageControl.appearance()
        pageControl.backgroundColor = .clear
        pageControl.pageIndicatorTintColor = .clear
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.layer.borderColor = UIColor.white.cgColor
        pageControl.layer.borderWidth = 1
        
        self.view.clipsToBounds = false
		
		blurBGView.alpha = 0.8
		self.view.insertSubview(blurBGView, at: 0)
		
        // Create get started dbutton
        getStartedButton.frame.size = getStartedSize
        getStartedButton.frame.origin = CGPoint(x: UIScreen.main.bounds.size.width/2 - getStartedButton.frame.size.width/2,
                                                    y: UIScreen.main.bounds.height - getStartedButton.frame.height - getStartedMarginBottom)
        getStartedButton.isHidden = false
        view.addSubview(getStartedButton)
        
		// Add Gestures
        getStartedButton.addTarget(self, action: #selector(getStartedButtonWasTapped(button:)), for: .touchUpInside)
        
        setBackgroundColor(forScreenIndex: 0)
        
        // Fade in
        view.alpha = 0.0
        UIView.animate(withDuration: fadeInAnimationDuration, animations: { 
            self.view.alpha = 1.0
        }) 
    }
    
    func viewInstructionsItemController(_ index: Int) -> InstructionsItemViewController? {
        let page = InstructionsItemViewController()
        
        page.setContent(forInstructionScreenModel: Common.Instructions.screens[index])
        page.index = index
        
        return page
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Override to put the page view controller on top
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var scrollView: UIScrollView? = nil
        var pageControl: UIPageControl? = nil
        let subViews: NSArray = view.subviews as NSArray
        
        for view in subViews {
            if view is UIScrollView {
                scrollView = view as? UIScrollView
            }
            else if view is UIPageControl {
                pageControl = (view as? UIPageControl)
                pageControl!.frame.origin.y = UIScreen.main.bounds.height - pageControl!.frame.height - pageControlMarginBottom
                
                for view in pageControl!.subviews {
                    view.layer.borderColor = UIColor.white.cgColor
                    view.layer.borderWidth = 1
                }
            }
        }
        
        if (scrollView != nil && pageControl != nil) {
            scrollView?.frame = view.bounds
            view.bringSubview(toFront: pageControl!)
        }
    }
    
    fileprivate func setBackgroundColor(forScreenIndex index:Int) {
//        UIView.animate(withDuration: backgroundAnimationDuration, animations: {
//            self.view.backgroundColor = Common.Instructions.screens[index].color.withAlphaComponent(self.backgroundAlpha)
//        })
    }
}

// Gesture Handlers
extension InstructionsPageViewController {
    @objc func getStartedButtonWasTapped(button: UIButton) {
        instructionsDelegate?.introPageGetStartedButtonTapped()
    }
}

//MARK: implementation of UIPageViewControllerDataSource
extension InstructionsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? InstructionsItemViewController {
            var index = viewController.index
            currentIndex = index
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            return viewInstructionsItemController(index)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? InstructionsItemViewController {
            var index = viewController.index
            currentIndex = index
            guard index != NSNotFound else { return nil }
            index = Common.Instructions.screens.count  //index + 1
			guard index != Common.Instructions.screens.count else {return nil}
            return viewInstructionsItemController(index)
        }
        
        return nil
    }
    
    
    
    // MARK: UIPageControl
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 1 //Common.Instructions.screens.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentPage
    }
}

extension InstructionsPageViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let viewController = pendingViewControllers.first as? InstructionsItemViewController {
            setBackgroundColor(forScreenIndex: viewController.index)
            
            if viewController.index == Common.Instructions.screens.count - 1 {
                getStartedButton.isHidden = false
            } else {
                getStartedButton.isHidden = true
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == false {
            if let viewController = self.viewControllers!.first as? InstructionsItemViewController {
                setBackgroundColor(forScreenIndex: viewController.index)
            }
        }
    }
}
