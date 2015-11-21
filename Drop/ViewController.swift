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
    var fallCount = 0
    var accel = Double()
    var largestVal = 0.0
    var hasFallen = false
    
    @IBOutlet weak var accelZ: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        accel = 1
        
        self.manager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.accel = sqrt(self.accel*pow(data!.acceleration.x, 2) + self.accel*pow(data!.acceleration.y, 2) + self.accel*pow(data!.acceleration.z, 2))
                
                if(self.accel > 9.0 && self.accel < 20.0 && !self.hasFallen){
                    self.fallCount++
                    self.hasFallen = true
                }
                else{
                    self.hasFallen = false
                }
                
                self.accelZ.text = String(self.fallCount)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
