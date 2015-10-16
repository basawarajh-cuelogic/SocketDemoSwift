//
//  ViewController.swift
//  TCPSocketDemoSwift
//
//  Created by cuelogic on 15/10/15.
//  Copyright © 2015 Cuelogic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TCPSocketConnectionDelegate{

    //MARK: Properties
    @IBOutlet weak var lbl_Connecting: UILabel!
    
    @IBOutlet weak var txtfld_Name: UITextField!
    
    @IBOutlet weak var btn_Add: UIButton!
    
    @IBOutlet weak var tblView_Names: UITableView!
    
    var socketConnection : TCPSocketConnection!
    
    var arrNames : NSMutableArray = []
    
    var imagesDict = NSDictionary()
    var btn = UIButton()
    
    
    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set Component Delegate
        txtfld_Name.delegate = self
        tblView_Names.delegate = self
        tblView_Names.dataSource = self
        
        //Customize View
        customizeView()
        
        //Connect Socket
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) { () -> Void in
           self.connectToSocket()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Customize View Method
    func customizeView() {
        lbl_Connecting.textColor = UIColor.redColor()
        lbl_Connecting.text = "Socket Connecting..."
    }
    
    //Connect Socket Method
    func connectToSocket(){
        self.socketConnection = TCPSocketConnection()
        self.socketConnection.delegate = self;
        self.socketConnection.connect();
    }
    
    //Disconnect Socket Method
    func disconnectSocket()
    {
        self.socketConnection.disConnect()
    }
    
    
    //MARK: UITextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        txtfld_Name.resignFirstResponder()
        
        return true
    }
    
    //MARK: UITableView DataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = arrNames[indexPath.row] as? String
        
        return cell
    }
    
    //MARK: IBActions
    @IBAction func addAction(sender: AnyObject) {
        

        let textMessage = txtfld_Name.text
        
        socketConnection.sendMessage(textMessage!)
        
    }
    
    @IBAction func disconnectClicked(sender: AnyObject) {
        
        btn = sender as! UIButton
        setConnectedOrDisconnected()
        
    }
    
    func setConnectedOrDisconnected() {
        
        if btn.selected {
            
            self.connectToSocket()
            
            btn.selected = false
            btn.setTitle("Disconnect", forState: UIControlState.Normal)
            
        }
        else
        {
            disconnectSocket()
            
            btn.selected = true
            btn.setTitle("Connect", forState: UIControlState.Normal)
        }

    }
    
    
    //MARK: Receive Message
    func messageReceived(message : NSString) {
        
        print("message received : \(message)")
        
        arrNames.addObject(message)
        
        txtfld_Name.text = ""
        
        tblView_Names.reloadData()
        
    }
    
    
    
    //MARK: TCPSocketConnection Delegate
    //Stream opened
    func openStream() {
        lbl_Connecting.textColor = UIColor.greenColor()
        lbl_Connecting.text = "Socket Connected"
    }
    
    //Receive data fron stream
    func receiveDataFromStream(data: NSData) {
        let messageStr = NSString(data: data, encoding: NSUTF8StringEncoding)
        messageReceived(messageStr!)
    }
    
    //Error occured when connecting stream
    func errorOccurred() {
        lbl_Connecting.textColor = UIColor.redColor()
        lbl_Connecting.text = "Error In Connection"
    }
    
    //End encountered or stream closed
    func endEncountered() {
        
    }
    
    //Stream disconnected
    func disconnectedStream() {
        lbl_Connecting.textColor = UIColor.redColor()
        lbl_Connecting.text = "Socket Closed..."
        
        messageReceived((lbl_Connecting?.text)!)
    }
    


}

