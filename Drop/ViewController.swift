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
import SwiftAddressBook
import CoreData

class ViewController: UIViewController {
    
    let manager = CMMotionManager()
    var accel = Double()
    var phone = ""
    var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Contact")
        request.returnsObjectsAsFaults = false
        
        do {
            let results: NSArray = try context.executeFetchRequest(request)
            if(results.count > 0){
                for res in results{
                    self.phone = res.valueForKey("number") as! String
                    self.name.text = res.valueForKey("name") as? String
                    print(self.phone)
                }
            }
        }
        catch {}
        
        
        
        accel = 1
        
        self.manager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                
                self.accel = sqrt(self.accel*pow(data!.acceleration.x, 2) + self.accel*pow(data!.acceleration.y, 2) + self.accel*pow(data!.acceleration.z, 2))

                
                if(self.accel > 9.0 && self.accel < 20.0 && self.phone != ""){
                    
                    let refreshAlert = UIAlertController(title: "Alert", message: "Are you ok? You seem to have fallen down!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
                        
                        refreshAlert.dismissViewControllerAnimated(true, completion: nil)
                        
                        if let url = NSURL(string: "tel://\(self.phone)") {
                            UIApplication.sharedApplication().openURL(url)
                        }
                        
                    }))
                    
                    self.presentViewController(refreshAlert, animated: true, completion: nil)

                    let delay = 15.0 * Double(NSEC_PER_SEC)
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    
                    dispatch_after(time, dispatch_get_main_queue(), {
                        if(self.presentedViewController != nil){
                            
                            refreshAlert.dismissViewControllerAnimated(true, completion: nil)
                            
                            if let url = NSURL(string: "tel://\(self.phone)") {
                                UIApplication.sharedApplication().openURL(url)
                            }
                        }
                    })
                }
            }
        }
    }

    @IBAction func editPressed(sender: AnyObject) {
        
        var nam = ""
        
        let alert = UIAlertController(title: "Emergency Contact", message: "Please enter your desired contact's name. They must be a member of your address book.", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Name"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            nam = textField.text!
            self.name.text = nam
            
            dispatch_async(dispatch_get_main_queue(), {
                swiftAddressBook?.requestAccessWithCompletion({ (success, error) -> Void in
                    if success {

                        if let people : [SwiftAddressBookPerson]? = swiftAddressBook?.peopleWithName(nam) {
                            
                            if(people! == []){
                                let secondAlert = UIAlertController(title: "Emergency Contact", message: "I'm sorry, but the name you entered does not exist in your address book. Please enter their phone number and we can add them!", preferredStyle: .Alert)
                                
                                secondAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                                    textField.placeholder = "Name"
                                })
                                
                                secondAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                                    self.name.text = ""
                                }))
                                
                                secondAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                                    
                                    let person = SwiftAddressBookPerson.create()
                                    
                                    person.firstName = self.name.text
                                    self.phone = secondAlert.textFields![0].text!
                                    
                                    let phoneNumber = MultivalueEntry(value: secondAlert.textFields![0].text!, label: "mobile", id: 0)
                                    person.phoneNumbers = [phoneNumber]
                                    
                                    swiftAddressBook?.addRecord(person)
                                    swiftAddressBook?.save()
                                    
                                    self.saveNewContact()
                                }))
                                
                                self.presentViewController(secondAlert, animated: true, completion: nil)

                            }
                            else{
                                //access variables on any entry of allPeople array just like always
                                for person in people! {
                                    //person.phoneNumbers is a "multivalue" entry
                                    //so you get an array of MultivalueEntrys
                                    //see MultivalueEntry in SwiftAddressBook
                                    let numbers = person.phoneNumbers
                                    //the value entry of the multivalue struct contains the data
                                    
                                    let num = (numbers!.first?.value)!
                                    
                                    self.phone = num.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
                                    self.phone = self.phone.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
                                    self.phone.removeAtIndex(self.phone.startIndex)
                                    
                                    self.saveNewContact()
                                }
                            }
                        }
                    }
                })
            })

        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveNewContact(){
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as NSManagedObject
        newUser.setValue(self.name.text!, forKey: "name")
        newUser.setValue(self.phone, forKey: "number")
        
        do {try context.save()}
        catch {}
        
        print(newUser)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
