//
//  SceneDelegate.swift
//  aic
//
//  Created by David Bireta on 2/5/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var savedShortCutItem: UIApplicationShortcutItem!
    
    private var deepLinkString: String?
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        guard let rootVC = window?.rootViewController as? RootViewController else { return }
        rootVC.resumeLoadingIfNotComplete()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Handle Quick Action for a cold launch
        if let shortcutItem = connectionOptions.shortcutItem {
            savedShortCutItem = shortcutItem
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if savedShortCutItem != nil {
            handleShortcutItem(item: savedShortCutItem)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Handle Quick Action for a resumed app
        let handled = handleShortcutItem(item: shortcutItem)
        completionHandler(handled)
    }
    
    @discardableResult
    private func handleShortcutItem(item: UIApplicationShortcutItem) -> Bool {
        if item.type == "MemberCardAction" {
            (window?.rootViewController as? RootViewController)?.sectionTabBarController.showMemberCard()
        }
        
        savedShortCutItem = nil

        return true
    }
    
    func triggerDeepLinkIfPresent() {
        guard let deepLinkString, let tourNID = Int(deepLinkString) else { return }
        guard let tour = AppDataManager.sharedInstance.getTour(forID: tourNID) else { return }
        
        let rootVC = window?.rootViewController as? RootViewController
        rootVC?.startTour(tour: tour)
    }
    
    
    // URL Deep Linking for Tours
    func launchTour(with url: URL) {
        if url.host == nil {
            return
        }
        
        let urlString = url.absoluteString
        let queryArray = urlString.components(separatedBy: "/")
        let query = queryArray[2]
        
        if Common.DeepLinks.loadedEnoughToLink {
            // Check if it is a tour
            
            if query.range(of: "tour") != nil {
                let data = urlString.components(separatedBy: "/")
                if (data.count) >= 3 {
                    guard let tourNID = Int(data[3]) else {
                        return
                    }
                    
                    guard let tour = AppDataManager.sharedInstance.getTour(forID: tourNID) else { return }
                    
                    let rootVC = window?.rootViewController as! RootViewController
                    rootVC.startTour(tour: tour)
                }
            }
        } else {
            let data = urlString.components(separatedBy: "/")
            deepLinkString = data[2]
        }
    }
}
