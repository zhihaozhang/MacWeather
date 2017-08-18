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
    
    var feed : JSON?
    
    var displayMode = 1

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    let locationManager:CLLocationManager = CLLocationManager()
    
    var updateDisplayTimer: Timer?
    var fetchFeedTimer: Timer?
    
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
        
        let defaultSettings = ["statusBarOption":"-1","units":"0"]
        UserDefaults.standard.register(defaults:defaultSettings)
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.startUpdatingLocation()
        }else{
            NSLog("not enabled")
        }
        
        
        loadSettings()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(loadSettings), name: Notification.Name("SettingsChanged"), object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        let userDefault = UserDefaults.standard
        if((userDefault.object(forKey: "latitude")) != nil){
            userDefault.removeObject(forKey: "latitude")
        }
        if((userDefault.object(forKey: "longitude")) != nil){
            userDefault.removeObject(forKey: "longitude")
        }
        userDefault.set(lastLocation.coordinate.latitude, forKey: "latitude")
        userDefault.set(lastLocation.coordinate.longitude, forKey: "longitude")
        userDefault.synchronize()
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
        updateDisplayTimer?.invalidate()
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController
            else{return}
        
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
        popoverView.behavior = .transient
        
    }
    
    func fetchFeed(){
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            let userDefault = UserDefaults.standard
            //1
            let latitude = userDefault.object(forKey: "latitude")
            let longitude = userDefault.object(forKey: "longitude")
            
            
             var dataSource = "https://api.darksky.net/forecast/151fc0037e7e1c3f1bcf497ffbb16724/\(latitude!),\(longitude!)"
            print(dataSource)
            
            if userDefault.integer(forKey: "units") == 0 {
                
                dataSource += "?units=si"
            }
            
            //2
            guard let url = URL(string: dataSource) else { return }
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async { [unowned self] in
                    
                    self.statusItem.button?.title = "Bad API call"
                    
                }
                return
            }
            
            //3
            let newFeed = JSON(data: data)
            
            DispatchQueue.main.async {
                
                self.feed = newFeed
                
                if((userDefault.object(forKey: "area")) != nil){
                    userDefault.removeObject(forKey: "area")
                }
                
                var areaStr =  self.feed?["timezone"].string as! String
//                print(areaStr)
                
                userDefault.set(areaStr, forKey: "area")
                self.updateDisplay()
                self.refreshSubmenuItems()
            }
            
        }
        
    }
    
    func changeDisplayMode() {
        
        displayMode += 1
        
        if displayMode > 3 {
            displayMode = 0
        }
        
        updateDisplay()
    }
    
    func configureUpdateDisplayTimer() {
        
        guard let statusBarMode = UserDefaults.standard.string(forKey: "statusBarOption") else
        { return }
        
        if statusBarMode == "-1" {
            displayMode = 0
            updateDisplayTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeDisplayMode), userInfo: nil, repeats: true)
            
        } else {
            updateDisplayTimer?.invalidate()
        }
    }
    
    func loadSettings(){
        displayMode = UserDefaults.standard.integer(forKey: "statusBarOption")
        configureUpdateDisplayTimer()
        
        fetchFeedTimer = Timer.scheduledTimer(timeInterval: 60 * 5, target: self, selector: #selector(fetchFeed), userInfo: nil, repeats: true)
        
        fetchFeedTimer?.tolerance = 60
        fetchFeed()
    }
    
    func updateDisplay() {
        
        guard let feed = feed else { return }
        var text = "Error"
        
        switch displayMode {
        case 0:
            //summary text
            if let summary = feed["currently"]["summary"].string {
                text = summary
            }
            
        case 1:
            //show current temperature
            if let temperature = feed["currently"]["temperature"].int {
                text = "\(temperature)°"
            }
            
        case 2:
            //show chance of rain
            if let rain = feed["currently"]["precipProbability"].double {
                text = "Rain: \(rain * 100)%"
            }
            
        case 3:
            //show cloud cover
            if let cloud = feed["currently"]["cloudCover"].double {
                text = "Cloud: \(cloud * 100)%"
            }
            
        default:
            //this should not be reached
            break
        }
        
        statusItem.button?.title = text
    }
    
    func refreshSubmenuItems() {
        
        guard let feed = feed else { return }
        
        statusItem.menu?.removeAllItems()
        
        for forecast in feed["hourly"]["data"].arrayValue.prefix(10) {
            
            let date = Date(timeIntervalSince1970: forecast["time"].doubleValue)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            let formattedDate = formatter.string(from: date)
            
            let summary = forecast["summary"].stringValue
            let temperature = forecast["temperature"].intValue
            let title = "\(formattedDate): \(summary) (\(temperature)°)"
            
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            
            statusItem.menu?.addItem(menuItem)
        }
        
        statusItem.menu?.addItem(NSMenuItem.separator())
        addConfigurationMenuItem()
    }
    

    
    
}

