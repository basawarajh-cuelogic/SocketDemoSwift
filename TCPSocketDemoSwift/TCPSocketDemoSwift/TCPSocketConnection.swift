//
//  TCPSocketConnection.swift
//  SwiftFirstSample
//
//  Created by cuelogic on 14/10/15.
//  Copyright © 2015 Cuelogic. All rights reserved.
//

import UIKit

class TCPSocketConnection: NSObject, NSStreamDelegate {
    
    var inputStream : NSInputStream?
    var outputStream : NSOutputStream?
    var host : CFString
    var port : UInt32 = 0
    
    override init() {
        self.host = "localhost"
        self.port = 1337
    }
    
    func connect() {
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
    
    
    func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        print("stream event")
        
        switch eventCode {
         case NSStreamEvent.None:
            break
        case NSStreamEvent.OpenCompleted:
            print("Stream opened");
            break
        case NSStreamEvent.HasBytesAvailable:
            if stream == inputStream{
                
                let bufferSize = 1024
                var buffer = Array<UInt8>(count: bufferSize, repeatedValue: 0)
                
                var bytesRead : Int = 0
                
                while (inputStream?.hasBytesAvailable != nil){
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
    
    func messageReceived(message : NSString)
    {
        print("message received : \(message)")
    }
    
    
}
