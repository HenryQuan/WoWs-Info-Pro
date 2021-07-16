//
//  RNHandler.swift
//  wowsinfo
//
//  Created by Yiheng Quan on 15/7/21.
//

import Foundation
import React

typealias RNDict = [NSObject: Any]

class RNHandler {
    
    // Singleton
    static let shared = RNHandler()
    private init() {}
    
    /// Setup the bridge so only one JSC VM is created to save resources and simplify the communication between RN views in different parts of your native app,
    /// you can have multiple views powered by React Native that are associated with a single JS runtime.
    private var bridge: RCTBridge!
    
    func setup(with delegate: RCTBridgeDelegate, and launchOptions: [AnyHashable: Any]?) {
        bridge = RCTBridge(delegate: delegate, launchOptions: launchOptions)
        
        /// https://stackoverflow.com/a/48903673, RCTBridge required dispatch_sync to load RCTDevLoadingView
        #if RCT_DEV
        bridge?.module(for: RCTDevLoadingView.self)
        #endif
    }
    
    private(set) lazy var jsBundleURL: URL! = {
        #if DEBUG
        if let settings = RCTBundleURLProvider.sharedSettings() {
            return settings.jsBundleURL(forBundleRoot: "index", fallbackResource: nil)
        } else {
            assertionFailure("Run npm start from wowsinfo folder")
            return nil
        }
        #else
        return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif
    }()
    
    /// The wrapper of RCTRootView
    func getRNView(with name: String, and props: RNDict? = nil) -> RCTRootView {
        RCTRootView(bridge: bridge, moduleName: name, initialProperties: props)
    }
    
    /// Get a RCTRootView and wrap it in a view controller
    func getRNViewController(with name: String, and props: RNDict? = nil) -> UIViewController {
        let vc = UIViewController()
        vc.view = getRNView(with: name, and: props)
        return vc
    }
}