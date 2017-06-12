/*
 Abstract:
 Main app delegate
*/

import UIKit

import CoreData
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deepLinkString: String? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AICAnalytics.configure()
        
        //Check for member and log open
        let defaults = UserDefaults.standard
        let storedID = (defaults.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) as? NSNumber)?.int64Value
        AICAnalytics.appOpenEvent(isMember: (storedID != nil))
        
        // Turn off caching
        let sharedCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.shared = sharedCache
        
        setStatusBar()
        
        // Register for rental app restart
        #if RENTAL
            registerForAppRestartTomorrowMorning()
        #endif
        
        return true
    }
    
    func registerForAppRestartTomorrowMorning() {
        guard let configDictionary = UserDefaults.standard.object(forKey: Common.UserDefaults.configurationDictionaryUserDefaultKey) as? NSDictionary else {
            print("Could not retrieve dictionary for key \("Common.UserDefaults.configurationDictionaryUserDefaultKey") while trying to register for app restart.")
            return
        }
        
        guard let days = configDictionary[Common.UserDefaults.rentalRestartDaysFromNowUserDefaultKey] as? Int else {
            print("Could not retrieve days from UserDefaults configDictionary")
            return
        }
        
        guard let hours = configDictionary[Common.UserDefaults.rentalRestartHourUserDefaultKey] as? Int else {
            print("Could not retrieve hours from UserDefaults configDictionary")
            return
        }
        
        guard let minutes = configDictionary[Common.UserDefaults.rentalRestartMinuteUserDefaultKey] as? Int else {
            print("Could not retrieve minutes from UserDefaults configDictionary")
            return
        }
        
        var tomorrowComponents = DateComponents()
        tomorrowComponents.day = days
        
        let calendar = Calendar.current
        let tomorrowDate = (calendar as NSCalendar).date(byAdding: tomorrowComponents, to:Date(), options: NSCalendar.Options(rawValue: 0))
        
        guard let tomorrow = tomorrowDate else {
            print("Could not get tomorrow date from calendar components")
            return
        }
        
        let unitFlags: NSCalendar.Unit = [.hour, .day, .month, .year, .era]
        var tomorrowMorningComponents = (calendar as NSCalendar).components(unitFlags, from: tomorrow)
        tomorrowMorningComponents.hour = hours
        tomorrowMorningComponents.minute = minutes
        
        let tomorrowMorning = calendar.date(from: tomorrowMorningComponents)
        
        let timer = Timer(fireAt: tomorrowMorning!, interval: 0, target: self, selector: #selector(AppDelegate.resetEnterpriseApp), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

    }

    func resetEnterpriseApp() {
        exit(0)
    }
    
    // Determine if we should hide/show the status bar
    // Hide when in-call or wifi hotspot are present
    func setStatusBar() {
        DispatchQueue.main.async {
            // Temporarily enable status bar to get the height
            UIApplication.shared.isStatusBarHidden = false
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            
            // Set show/hide var
            Common.Layout.showStatusBar = (statusBarHeight <= 20)
            
            // Hide or show
            UIApplication.shared.isStatusBarHidden = !Common.Layout.showStatusBar
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        AICAnalytics.appBackgroundEvent()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Resume data loading if necessary
        let rootVC = window?.rootViewController as! RootViewController
        rootVC.resumeLoadingIfNotComplete()
        
        // Log analytics
        AICAnalytics.appForegroundEvent()
        setStatusBar()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {}
    
    // URL Deep Linking
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == nil {
            return true;
        }
        
        let urlString = url.absoluteString
        let queryArray = urlString.components(separatedBy: "/")
        let query = queryArray[2]
        
        if Common.DeepLinks.loadedEnoughToLink {
            
        // Check if it is a tour
        
        if query.range(of: "tour") != nil
        {
            let data = urlString.components(separatedBy: "/")
            if (data.count) >= 3
            {
                guard let tourNID = Int(data[3]) else {
                    return true
                }
                
                guard let tour = AppDataManager.sharedInstance.getTour(forID: tourNID) else {
                    return true
                }
                
                    let rootVC = window?.rootViewController as! RootViewController
                    rootVC.startTour(tour: tour)
                }
            }
        } else {
            
            let data = urlString.components(separatedBy: "/")
            deepLinkString = data[3]
        }
        
        return true
    }
    
    
    func triggerDeepLinkIfPresent()
    {
        if deepLinkString != nil {
          
            guard let tourNID = Int(deepLinkString!) else {
                return
            }
            
            guard let tour = AppDataManager.sharedInstance.getTour(forID: tourNID) else {
                return
            }
            
            let rootVC = window?.rootViewController as! RootViewController
            rootVC.startTour(tour: tour)
        }
    }
}

