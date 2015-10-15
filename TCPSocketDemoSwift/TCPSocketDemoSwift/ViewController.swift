//
//  ViewController.swift
//  TCPSocketDemoSwift
//
//  Created by cuelogic on 15/10/15.
//  Copyright © 2015 Cuelogic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSStreamDelegate{

    //MARK: Properties
    @IBOutlet weak var lbl_Connecting: UILabel!
    
    @IBOutlet weak var txtfld_Name: UITextField!
    
    @IBOutlet weak var btn_Add: UIButton!
    
    @IBOutlet weak var tblView_Names: UITableView!
    
    var arrNames : NSMutableArray = []
    
    var imagesDict = NSDictionary()
    
    var inputStream : NSInputStream?
    var outputStream : NSOutputStream?
    
    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        txtfld_Name.delegate = self
        
        tblView_Names.delegate = self
        tblView_Names.dataSource = self
        
        // let socketConnection : TCPSocketConnection = TCPSocketConnection()
        //  socketConnection.connect();
        
        lbl_Connecting.textColor = UIColor.redColor()
        lbl_Connecting.text = "Socket Connecting..."
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) { () -> Void in
            self.connectSocket()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    /* Header Methods
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return imagesDict.allKeys[section] as? String
    }
    */
    
    //MARK: IBActions
    @IBAction func addAction(sender: AnyObject) {
        
        /*txtfld_Name.resignFirstResponder()
        
        arrNames.addObject(txtfld_Name.text!)
        
        txtfld_Name.text = ""
        
        tblView_Names.reloadData()*/
        
        let textMessage = txtfld_Name.text
        
        let data : NSData = NSData(data:(textMessage?.dataUsingEncoding(NSASCIIStringEncoding))!)
        
        outputStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        
    }
    
    
    //MARK: Socket Connection
    func connectSocket() {
        
        var readStream : Unmanaged<CFReadStream>?
        var writeStream : Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "localhost", 1337, &readStream, &writeStream)
        
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        inputStream!.delegate = self
        outputStream!.delegate = self
        
        inputStream!.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream!.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inputStream!.open()
        outputStream!.open()
        
    }
    
    //MARK: NSStream Delegate
    func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        print("stream event")
        
        switch eventCode {
        case NSStreamEvent.None:
            break
        case NSStreamEvent.OpenCompleted:
            print("Stream opened");
            lbl_Connecting.textColor = UIColor.greenColor()
            lbl_Connecting.text = "Socket Connected"
            break
        case NSStreamEvent.HasBytesAvailable:
            if stream == inputStream{
                
                let bufferSize = 1024
                var buffer = Array<UInt8>(count: bufferSize, repeatedValue: 0)
                
                var bytesRead : Int = 0
                
                if self.inputStream!.hasBytesAvailable{
                    bytesRead = inputStream!.read(&buffer, maxLength: bufferSize)
                }
                
                if bytesRead >= 0 {
                    let output = NSString(bytes: &buffer, length: bytesRead, encoding: NSUTF8StringEncoding)
                    messageReceived(output!);
                    
                } else {
                    // Handle error
                }
                
            }
            break
        case NSStreamEvent.HasSpaceAvailable:
            break
        case NSStreamEvent.ErrorOccurred:
            print("Can not connect to the host!");
            break
        case NSStreamEvent.EndEncountered:
            stream.close()
            stream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
            break
        default:
            break
            
        }
        
    }
    
    //MARK: Receive Message
    func messageReceived(message : NSString)
    {
        print("message received : \(message)")
        
        arrNames.addObject(message)
        
        txtfld_Name.text = ""
        
        tblView_Names.reloadData()
        
    }


}

