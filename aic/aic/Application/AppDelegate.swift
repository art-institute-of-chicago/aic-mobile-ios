/*
 Abstract:
 Main app delegate
 */

import CoreData
import CoreLocation
import Kingfisher
import MapKit
import MediaPlayer
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var statusBarHeight: CGFloat = 0
    private let configuration = ConfigurationResources(plistFile: PlistFile(name: "Config"))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if !DEBUG
        setupAnalytics()
#endif
        setupKingfisher()

        // Set initial state for location tracking
        let locationManager = CLLocationManager()
        Common.Location.hasLoggedOnsite = false
        Common.Location.previousOnSiteState = nil
        Common.Location.previousAuthorizationStatus = locationManager.authorizationStatus
        
        if Common.Location.previousAuthorizationStatus == .denied {
            AICAnalytics.sendLocationDetectedEvent(location: AICAnalytics.LocationState.Disabled)
            Common.Location.hasLoggedOnsite = true
        }
        
        // Turn off caching
        let sharedCache = URLCache(
            memoryCapacity: 0,
            diskCapacity: 0,
            diskPath: nil
        )
        URLCache.shared = sharedCache
        
        determineStatusBarVisibility()
        // Register for rental app restart
#if RENTAL
        registerForAppRestartTomorrowMorning()
#endif
        return true
    }
    
    private func setupAnalytics() {
        AICAnalytics.configure(properties: [
            AnalyticsProperty.make(by: .appLanguage),
            AnalyticsProperty.make(by: .deviceLanguage),
            AnalyticsProperty.make(by: .membership)
        ])
    }

    private func setupKingfisher() {
        let iiifUserAgentHeaderValue = configuration.iiifUserAgentHeaderValue()
        let iiifUserAgentModifier = AnyModifier { request in
            var request = request

            if let iiifUserAgentHeaderValue, request.url?.path.contains("/iiif/") == true {
                request.setValue(iiifUserAgentHeaderValue, forHTTPHeaderField: "aic-user-agent")
            }

            return request
        }

        KingfisherManager.shared.defaultOptions = [.requestModifier(iiifUserAgentModifier)]
    }
    
    func registerForAppRestartTomorrowMorning() {
        guard let configDictionary = UserDefaults.standard.object(forKey: Common.UserDefaults.configurationDictionaryUserDefaultKey) as? NSDictionary else {
            debugPrint("Could not retrieve dictionary for key \("Common.UserDefaults.configurationDictionaryUserDefaultKey") while trying to register for app restart.")
            return
        }
        
        guard let days = configDictionary[Common.UserDefaults.rentalRestartDaysFromNowUserDefaultKey] as? Int else {
            debugPrint("Could not retrieve days from UserDefaults configDictionary")
            return
        }
        
        guard let hours = configDictionary[Common.UserDefaults.rentalRestartHourUserDefaultKey] as? Int else {
            debugPrint("Could not retrieve hours from UserDefaults configDictionary")
            return
        }
        
        guard let minutes = configDictionary[Common.UserDefaults.rentalRestartMinuteUserDefaultKey] as? Int else {
            debugPrint("Could not retrieve minutes from UserDefaults configDictionary")
            return
        }
        
        var tomorrowComponents = DateComponents()
        tomorrowComponents.day = days
        
        let calendar = Calendar.current
        let tomorrowDate = (calendar as NSCalendar).date(byAdding: tomorrowComponents, to: Date(), options: NSCalendar.Options(rawValue: 0))
        
        guard let tomorrow = tomorrowDate else {
            debugPrint("Could not get tomorrow date from calendar components")
            return
        }
        
        let unitFlags: NSCalendar.Unit = [.hour, .day, .month, .year, .era]
        var tomorrowMorningComponents = (calendar as NSCalendar).components(unitFlags, from: tomorrow)
        tomorrowMorningComponents.hour = hours
        tomorrowMorningComponents.minute = minutes
        
        let tomorrowMorning = calendar.date(from: tomorrowMorningComponents)
        let timer = Timer(fireAt: tomorrowMorning!,
                          interval: 0,
                          target: self,
                          selector: #selector(AppDelegate.resetEnterpriseApp),
                          userInfo: nil,
                          repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc
    func resetEnterpriseApp() {
        exit(0)
    }
    
    func determineStatusBarVisibility() {
        setupStatusBarHeight()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Hide when in-call or wifi hotspot are present
            Common.Layout.showStatusBar = (self.statusBarHeight <= 20)
        }
    }
    
    func setupStatusBarHeight() {
        DispatchQueue.main.async { [weak self] in
            let keyWindow = UIApplication.keyWindow
            let statusBarManager = keyWindow?.windowScene?.statusBarManager
            self?.statusBarHeight = statusBarManager?.statusBarFrame.height ?? 0
        }
    }
}
