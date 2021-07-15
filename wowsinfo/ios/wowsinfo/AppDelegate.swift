//
//  AppDelegate.swift
//  wowsinfo
//
//  Created by Yiheng Quan on 14/7/21.
//

import UIKit
import FlipperKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        setupFlipper()
        #endif

        RNHandler.shared.setup(with: launchOptions)
        return true
    }
    
    private func setupFlipper() {
        #if FB_SONARKIT_ENABLED
        let client = FlipperClient.shared()
        let layoutDescriptorMapper = SKDescriptorMapper(defaults: ())
        client?.add(FlipperKitLayoutPlugin(rootNode: application, with: layoutDescriptorMapper))
        client?.add(FKUserDefaultsPlugin(suiteName: nil))
        client?.add(FlipperKitReactPlugin())
        client?.add(FlipperKitNetworkPlugin(networkAdapter: SKIOSNetworkAdapter()))
        client?.start()
        #endif
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
