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
        
    }
    
  

}

