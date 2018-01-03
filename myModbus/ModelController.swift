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
//class ModelController: NSObject, UIPageViewController, UIPageViewControllerDataSource {

    var pageData: [String] = []
    var mConnect: Bool = false
    var receive: [String] = []
    //var nsReceive: NSArray = []
    //var nsReceive: [AnyObject] = []
    
    var read_tries = 0
    //var mod: NSObject;
    //var client: SwiftLibModbus = nil
    var swiftLibModbus: SwiftLibModbus
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var ipDefault:NSString = "192.168.1.6"
    var portDefault:Int32 = 502
    var registro:Int32 = 1
    var esReiniciar:Bool = false
    var maximo:Float = 2000
    var minimo:Float = 0
    let defaults = UserDefaults.standard
    var bits:Int = 1
    
    override init() {
         //defaults.setValue(maximo, forKey: "maximo")
        //let ip: String = NSUserDefaults.standardUserDefaults().stringForKey("ip")!
        if (defaults.object(forKey: "ip") == nil){
            defaults.setValue(ipDefault, forKey: "ip")
        }else{
             self.ipDefault = defaults.string(forKey: "ip")! as NSString
        }
        if (defaults.object(forKey: "port") == nil){
            defaults.setValue(portDefault, forKey: "port")
        }else{
            self.portDefault = Int32(defaults.integer(forKey: "port"))
        }
        if (defaults.object(forKey: "registro") == nil){
            defaults.setValue(registro, forKey: "registro")
        }else{
            self.registro = Int32(defaults.integer(forKey: "registro"))
        }
        if (defaults.object(forKey: "maximo") == nil){
            defaults.setValue(maximo, forKey: "maximo")
        }else{
             self.maximo = defaults.float(forKey: "maximo")
        }
        if (defaults.object(forKey: "minimo") == nil){
            defaults.setValue(minimo, forKey: "minimo")
        }else{
            self.minimo = defaults.float(forKey: "minimo")
        }
        if (defaults.object(forKey: "esReiniciar") == nil){
            defaults.setValue(minimo, forKey: "esReiniciar")
        }else{
            self.esReiniciar = Bool(defaults.bool(forKey: "esReiniciar"))
        }
        if (defaults.object(forKey: "bits") == nil){
            defaults.setValue(bits, forKey: "bits")
        }else{
            self.bits = defaults.integer(forKey: "bits")
        }
        
        print("Asignacion de configuracion")
    
        
 //       if(defaults.)
        //var ip:String = defaults.stringForKey("ip")!
        //if(ip == ""){
        
        //    ip = "192.168.1.6"
           // defaults.setValue(ip, forKey: "ip")
            
        //}
        //self.swiftLibModbus = SwiftLibModbus(ipAddress: "192.168.1.6", port: 502, device: 1)
        
        //self.swiftLibModbus = SwiftLibModbus(ipAddress: defaults.string(forKey: "ip")! as NSString, port: Int32(defaults.integer(forKey: "port")), device: 1)
        self.swiftLibModbus = SwiftLibModbus(ipAddress: self.ipDefault, port: self.portDefault, device: 1)
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
        
        backgroundThread(delay: 3.0, background: {
            // Your delayed function here to be run in the foreground
            while(1==1){
                if(self.read_tries>2){
                    self.initConnectionProcess()
                }
                if(self.mConnect){
                    //Start address 63
                    //self.swiftLibModbus.readRegistersFrom(startAddress: 63, count: 2,
                    self.swiftLibModbus.readRegistersFrom(startAddress: Int32(self.defaults.integer(forKey: "registro")), count: 2,
                        success: { (array: [AnyObject]) -> Void in
                            //self.nsReceive = array
                            self.appDelegate.result = array
                            //Do something with the returned data (NSArray of NSNumber)..
                            print("success: \(array)")
                            self.read_tries = 0
                            /*print(Bool(self.defaults.bool(forKey: "esReiniciar")))
                            if(self.defaults.bool(forKey: "esReiniciar")){
                                self.defaults.setValue(false, forKey: "esReiniciar")
                                self.initConnectionProcess()
                                
                            }*/
                        },
                        failure:  { (error: NSError) -> Void in
                            //Handle error
                            self.read_tries=self.read_tries+1;
                            self.appDelegate.result = []
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
    
    func initConnectionProcess(){
        self.disconnect()
        sleep(4)
        self.connect()
        sleep(4)
        self.read_tries = 0
    }
    
    func connect(){
        self.swiftLibModbus.disconnect()
        //sleep(1)
        //self.swiftLibModbus = SwiftLibModbus(ipAddress: "192.168.1.6", port: 502, device: 1)
        self.swiftLibModbus = SwiftLibModbus(ipAddress: defaults.string(forKey: "ip")! as NSString, port: Int32(defaults.integer(forKey: "port")), device: 1)
        self.swiftLibModbus.connect(
            success: { () -> Void in
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
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
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
        return pageData.index(of: viewController.dataObject) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController: viewController as! DataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index: index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController: viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index: index, storyboard: viewController.storyboard!)
    }
    
    func backgroundThread(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    /*func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }*/
    
    		

}

