//
//  ModelController.swift
//  myModbus
//
//  Created by Mario Torres on 28/11/17.
//  Copyright © 2017 Mario Torres. All rights reserved.
//

import UIKit
import Dispatch
//import Foundation

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 */


class ModelController: NSObject{
    var mConnect: Bool = false
    var receive: [String] = []
    //var nsReceive: NSArray = []
    //var nsReceive: [AnyObject] = []
    
    var read_tries = 0
    var swiftLibModbus: SwiftLibModbus!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var ipDefault:NSString = "192.168.1.6"
    var portDefault:Int32 = 502
    var registro:Int32 = 1
    var operacion:Int32 = 1
    var esReiniciar:Bool = false
    var maximo:Float = 2000
    var maxGen:Float = 2000
    var minimo:Float = 0
    let defaults = UserDefaults.standard
    var bits:Int = 1
    var tipoGen:Bool = false
    
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
        if (defaults.object(forKey: "maxGen") == nil){
            defaults.setValue(maxGen, forKey: "maxGen")
        }else{
            self.maxGen = defaults.float(forKey: "maxGen")
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
        if (defaults.object(forKey: "tipoGen") == nil){
            defaults.setValue(tipoGen, forKey: "tipoGen")
        }else{
            self.tipoGen = Bool(defaults.bool(forKey: "tipoGen"))
        }
        if (defaults.object(forKey: "operacion") == nil){
            defaults.setValue(operacion, forKey: "operacion")
        }else{
            self.operacion = Int32(defaults.integer(forKey: "operacion"))
        }
        print("Asignacion de configuracion")
        //self.swiftLibModbus = SwiftLibModbus(ipAddress: self.ipDefault, port: self.portDefault, device: 1)
        super.init()
        //self.connect()
        //sleep(5)
        backgroundThread(delay: 3.0, background: {
            // Your delayed function here to be run in the foreground
            while(1==1){
                if(self.read_tries>2){
                    self.initConnectionProcess()
                }
                if(self.mConnect){
                    self.swiftLibModbus.readRegistersFrom(startAddress: Int32(self.defaults.integer(forKey: "registro")), count: 2,
                        success: { (array: [AnyObject]) -> Void in
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
        if(self.swiftLibModbus != nil){
            //self.swiftLibModbus.disconnect()
            self.disconnect()
            self.swiftLibModbus = nil
        }
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
        if self.swiftLibModbus.isConnect! {
            self.swiftLibModbus.disconnect()
        }
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

