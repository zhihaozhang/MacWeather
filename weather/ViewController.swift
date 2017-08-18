//
//  ViewController.swift
//  weather
//
//  Created by Chih-Hao on 2017/8/16.
//  Copyright © 2017年 Chih-Hao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

//    @IBOutlet var mapView: MKMapView!
    
    
    @IBOutlet var area: NSTextField!
    @IBOutlet var statusBarOption: NSPopUpButton!
    @IBOutlet var units: NSSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func showPoweredBy(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://darksky.net/poweredby/")!)
    }
    
    override func viewWillAppear() {
        let userDefault = UserDefaults.standard
        area.stringValue = userDefault.object(forKey: "area") as! String
        let savedStatusBar = userDefault.integer(forKey: "statusBarOption")
        let savedUnits = userDefault.integer(forKey: "units")
        
        units.selectedSegment = savedUnits
        
        for menuItem in statusBarOption.menu!.items{
            
            if menuItem.tag == savedStatusBar{
                statusBarOption.select(menuItem)
            }
        }

    
    }
    
    override func viewWillDisappear() {
        let defaults = UserDefaults.standard
        defaults.set(units.selectedSegment, forKey: "units")
        
        var statusBarValue = -1
        
        for menuItem in statusBarOption.menu!.items {
            
            if menuItem.state == NSOnState {
                statusBarValue = menuItem.tag
                break
            }
        }
        
        defaults.set(statusBarValue, forKey: "statusBarOption")
        
        //3
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("SettingsChanged"), object: nil)
        
        
        
    }
    
  

}

