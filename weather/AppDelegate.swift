//
//  AppDelegate.swift
//  weather
//
//  Created by Chih-Hao on 2017/8/16.
//  Copyright © 2017年 Chih-Hao. All rights reserved.
//

import Cocoa
import CoreLocation
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,CLLocationManagerDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    let locationManager:CLLocationManager = CLLocationManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem.button?.title = "🌞"
        statusItem.menu = NSMenu()
        addConfigurationMenuItem()
        
        //设置定位服务管理器代理
        locationManager.delegate = self
        //设置定位进度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //最佳定位
        //更新距离
        locationManager.distanceFilter = 100
        
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.startUpdatingLocation()
        }else{
            NSLog("not enabled")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        print("latitude:\(lastLocation.coordinate.latitude)")
        print("longitude:\(lastLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("inside didChangeAuthorization ");
    }
    
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func addConfigurationMenuItem(){
        
        let seperator = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: "")
        
        statusItem.menu?.addItem(seperator)
        
        
    }
    
    func showSettings(_ sender: NSMenuItem){
//        NSApplication.shared().terminate(self)
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController
            else{return}
        
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
        popoverView.behavior = .transient
        
        
        
    }

 
}

