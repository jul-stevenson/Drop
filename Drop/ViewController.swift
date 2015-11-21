//
//  ViewController.swift
//  Drop
//
//  Created by Julianna Stevenson on 11/21/15.
//  Copyright © 2015 Julianna Stevenson. All rights reserved.
//

import UIKit
import CoreMotion
import Foundation

class ViewController: UIViewController {
    
    let manager = CMMotionManager()
    var accel = Double()
    var phone = "5743399220"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        accel = 1
        
        self.manager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.accel = sqrt(self.accel*pow(data!.acceleration.x, 2) + self.accel*pow(data!.acceleration.y, 2) + self.accel*pow(data!.acceleration.z, 2))
                
                if(self.accel > 9.0 && self.accel < 20.0){
                    var refreshAlert = UIAlertController(title: "Alert", message: "Are you ok? You seem to have fallen down!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
                        
                        if let url = NSURL(string: "tel://\(self.phone)") {
                            UIApplication.sharedApplication().openURL(url)
                        }
                        
                        
                    }))
                    
                    self.presentViewController(refreshAlert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        performSegueWithIdentifier("toPage2", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
