//
//  ModelController.swift
//  myModbus
//
//  Created by Jeannette Yungan on 28/11/17.
//  Copyright © 2017 Mario Torres. All rights reserved.
//

import UIKit
import Dispatch
//import Foundation

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData: [String] = []
    var mConnect: Bool = false
    var receive: [String] = []
    //var nsReceive: NSArray = []
    var nsReceive: [AnyObject] = []
    
    var read_tries = 0
    //var mod: NSObject;
    //var client: SwiftLibModbus = nil
    private var swiftLibModbus: SwiftLibModbus
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var ipDefault:String = "192.168.1.6"
    var portDefault:Int = 502

    override init() {
        //let ip: String = NSUserDefaults.standardUserDefaults().stringForKey("ip")!
        let defaults = NSUserDefaults.standardUserDefaults()
        //var ip:String = ""
        if (defaults.objectForKey("ip") == nil) {
            defaults.setValue(ipDefault, forKey: "ip")
            defaults.setValue(portDefault, forKey: "port")
            print("Primera asignacion de configuracion")
        }
        
        
 //       if(defaults.)
        //var ip:String = defaults.stringForKey("ip")!
        //if(ip == ""){
        
        //    ip = "192.168.1.6"
           // defaults.setValue(ip, forKey: "ip")
            
        //}
        //self.swiftLibModbus = SwiftLibModbus(ipAddress: "192.168.1.6", port: 502, device: 1)
        
        self.swiftLibModbus = SwiftLibModbus(ipAddress: defaults.stringForKey("ip")!, port: Int32(defaults.integerForKey("port")), device: 1)
        super.init()
        // Create the data model.
        //let dateFormatter = NSDateFormatter()
        //pageData = dateFormatter.monthSymbols
        pageData =  ["Inicio", "Ajustes"]
        
        //connect();
        // Create a new view controller and pass suitable data.
        /*
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
        dataViewController.dataObject = self.pageData[index]
        */
        
        /*let controller = .destinationViewController as! DetailViewViewController
        let _ = controller.view
        controller.detailViewLabel.text = "Hello!"*/
        
        backgroundThread(3.0, background: {
            // Your delayed function here to be run in the foreground
            while(1==1){
                if(self.read_tries>2){
                    self.disconnect()
                    sleep(4)
                    self.connect()
                    sleep(4)
                    self.read_tries = 0
                }
                
                
                if(self.mConnect){
                self.swiftLibModbus.readRegistersFrom(1, count: 2,
                    success: { (array: [AnyObject]) -> Void in
                        self.nsReceive = array
                        self.appDelegate.result = array
                        //Do something with the returned data (NSArray of NSNumber)..
                        print("success: \(array)")
                        self.read_tries = 0
                    },
                    failure:  { (error: NSError) -> Void in
                        //Handle error
                        self.read_tries=self.read_tries+1;
                        //sleep(4000)
                        print("error")
                })
                    //print("aka")
                    //print(self.nsReceive)
                    sleep(1)
                }else{
                    print("Not connected. Wait 4 seconds")
                    self.connect()
                    sleep(4)
                    
                }
            }
            //print("Entramos")
        })
        
    }
    func connect(){
        self.swiftLibModbus.disconnect()
        //sleep(1)
        self.swiftLibModbus = SwiftLibModbus(ipAddress: "192.168.1.6", port: 502, device: 1)
        self.swiftLibModbus.connect(
            { () -> Void in
                print("exito")
                self.mConnect = true
                //connected and ready to do modbus calls
            },
            failure: { (error: NSError) -> Void in
                //Handle error
                self.mConnect = false
                print("error")
        })
    }
    func disconnect(){
        self.mConnect = false
        self.swiftLibModbus.disconnect()
    }

    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        //if (self.pageData.count == 0) || (index >= self.pageData.count) {
        if (self.pageData.count == 0) || (index >= 2) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
        dataViewController.dataObject = self.pageData[index]
        
        /*if(self.nsReceive.count>0){
            let data = self.nsReceive[0]
            print(self.nsReceive    )
            dataViewController.dataReceive = String(data)
            //dataViewController.txtPrueba.text = self.nsReceive[0] as? String
        }*/
        //print("aqui")
        return dataViewController
    }

    func indexOfViewController(viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return pageData.indexOf(viewController.dataObject) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    		

}

