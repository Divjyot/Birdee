//
//  FirstViewController.swift
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

class FirstViewController: FormViewController {
    var names: NSMutableArray = []
    var pictures: NSMutableArray = []
    var clients: NSMutableDictionary = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        queryNewlyClients()
      
    
        
        
    }
    
    func updateTable(){
        print("Update Table")
        for aClient in clients {
            
            createRows(clientName: aClient.key as! String, picURL: URL(string:aClient.value as! String)!)
        }
    }
   
    
    func createRows(clientName : String, picURL: URL){
        
        form  +++ Section()
            <<< UserInfoRow { row in
                row.value = User(name: clientName,
                                 email: "mathias@xmartlabs.com",
                                 dateOfBirth: Date(timeIntervalSince1970: 712119600),
                                 pictureUrl: picURL)
        }
        
    }

    open func rowsHaveBeenAdded(_ rows: [BaseRow], at: IndexSet) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readAllRegisteredClients() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        let notesItem: Notes = Notes();
        notesItem._userId = AWSIdentityManager.default().identityId
        
        dynamoDbObjectMapper.load(
            Notes.self,
            hashKey: notesItem._userId!,
            rangeKey: "Test",
            completionHandler: {
                (objectModel: AWSDynamoDBObjectModel?, error: Error?) -> Void in
                if let error = error {
                    print("Amazon DynamoDB Read Error: \(error)")
                    return
                }
                print("An item was read.")
        })
    }
    
    func  queryNewlyClients()  {
        // 1) Configure the query
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId AND #createdAt <= :createdAt"
        
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#createdAt":"createdAt"
        
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": AWSIdentityManager.default().identityId as Any,
            ":createdAt": NSDate().timeIntervalSince1970 as NSNumber
        ]
        
        
        // 2) Make the query
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.query(TodayClients.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            if error != nil {
                print("The request failed. Error:\(String(describing: error))")
            }
            if output != nil {
                print("Query : Clients")
                for newClients in output!.items {
                    let clientsItems = newClients as? TodayClients
                    self.clients.setValue(clientsItems!._clientPhotoURL, forKey: clientsItems!._clientName!)
                    print("\(clientsItems!._clientName!)")
                    print("\(clientsItems!._clientPhotoURL!)")
                    DispatchQueue.main.async {
                        //Code here to which needs to update the UI in the UI thread goes here
                        self.updateTable()
                    }
                }
            }
        }
        //....
    }


}

