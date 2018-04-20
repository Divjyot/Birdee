//
//  SecondViewController.swift
//  Birdee
//
//  Created by Divjyot Singh on 6/4/18.
//  Copyright © 2018 Divjyot Singh. All rights reserved.
//

import UIKit
import Eureka
import AWSMobileClient
import AWSCore
import AWSDynamoDB

class SecondViewController: FormViewController  {
    
    //Creating Global Variables
    var name: String = ""
    var phoneNumber: String = ""
    var email: String = ""
    var data: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createForm()
//        createNewlyArrivedClient()
        
    }
    
    
    func createForm(){
        form +++ Section("Peronal Information")
            
            <<< TextRow(){ row in
                row.title = "Full Name"
                row.placeholder = "Enter text here"
                row.add(rule: RuleRequired())
                
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        self.name = (row.value != nil) ? row.value! : ""
                    }
                    
            }
            
            <<< PhoneRow(){
                $0.title = "Mobile Number"
                $0.placeholder = "Enter Number here"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleExactLength.init(exactLength: 10))
                
                }
                
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        self.phoneNumber = (row.value != nil) ? row.value! : ""
                    }
            }
            
            <<< EmailRow(){ row in
                row.title = "Email Address"
                row.placeholder = "micheal@birdee.com"
                row.add(rule: RuleEmail())
                row.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        self.email = (row.value != nil) ? row.value! : ""
                    }
        }
        
        
    
    }
    

    
    // you need to override this function because navigationAction is defined
    // in an extension, Swift doesn't allow overriding those yet
    override func inputAccessoryView(for row: BaseRow) -> UIView? {
        let r = super.inputAccessoryView(for: row)
        
        // you need to replace the #selector defined in FormViewController
        navigationAccessoryView.doneButton.action = #selector(newNavigationAction(_:))
        
        return r
    }
    
    @objc func newNavigationAction(_ sender: UIBarButtonItem) {
        // we have to repeat the stock code because we can't access the navigationAction
        // method, otherwise a Thread exception will be thrown
        let direction: Direction = sender == navigationAccessoryView.previousButton ? .up : .down
        navigateTo(direction: direction)
        
        // you may not want to call navigateTo if Next was tapped, depends on your needs
        if direction == .down {
            tableView?.endEditing(true)
        }
        
        print(name + email + phoneNumber)
        
       createNewClient()
    }

    func createNewClient() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        let notes: Notes = Notes()
        
        notes._userId = AWSIdentityManager.default().identityId
        
        notes._eMail = email
        notes._mobile = Int(phoneNumber)! as NSNumber
        notes._name = name
        notes._creationDate = NSDate().timeIntervalSince1970 as NSNumber
        notes._noteId =  name
        notes._updatedDate =  NSDate().timeIntervalSince1970 as NSNumber
        notes._content = name
        
        print("\n" + "Details:")
        print(notes._userId as! String)
        print(notes._eMail as! String)
        print(notes._mobile as! String)
        print(notes._name as! String)
        print(notes._creationDate as! String)
        print(notes._noteId as! String)
        print(notes._updatedDate as! String)
        print(notes._content as! String)
        
        
        //Save a new item
        dynamoDbObjectMapper.save(notes, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
    }
    
    func createNewlyArrivedClient() {
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        let newClient: TodayClients = TodayClients()
        
        newClient._userId = AWSIdentityManager.default().identityId
        
        newClient._clientPhotoURL = "https://en.wikipedia.org/wiki/HTTPS#/media/File:Internet2.jpg"
        newClient._createdAt =  NSDate().timeIntervalSince1970 as NSNumber
        newClient._clientName =  "Mr. Newly Arrived"
        
        
        //Save a new item
        dynamoDbObjectMapper.save(newClient, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

