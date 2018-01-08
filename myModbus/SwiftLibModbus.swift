//
//  SwiftLibModbus.swift
//  SwiftLibModbus
//
//  Ported to Swift by Kei Sakaguchi on 2/22/16. It's a bit weird that the project was started on the same date 4 years ago...
//  Created by Lars-Jørgen Kristiansen on 22.02.12.
//  Copyright © 2012 __MyCompanyName__. All rights reserved.
//

import Foundation


enum FunctionType {
    case kInputBits
    case kBits
    case kInputRegisters
    case kRegisters
}

class SwiftLibModbus: NSObject {
    var mb: OpaquePointer?
    //var modbusQueue: dispatch_queue_t?
    var modbusQueue: DispatchQueue?
    var ipAddress: NSString?
    var isConnect: Bool?
    var error: NSError?
    
    init(ipAddress: NSString, port: Int32, device: Int32) {
        super.init()
        //modbusQueue = DispatchQueue("com.iModbus.modbusQueue", nil);
        modbusQueue = DispatchQueue(label: "com.iModbus.modbusQueue");
        isConnect = self.setupTCP(ipAddress: ipAddress, port: port, device: device)
        //self.setupTCP(
        
    }
    
    func setupTCP(ipAddress: NSString, port: Int32, device: Int32) -> Bool {
        self.ipAddress = ipAddress
        //mb = modbus_new_tcp(ipAddress.cStringUsingEncoding(NSASCIIStringEncoding) , port)
        let ip : NSString = getHost(url: ipAddress as String) as NSString
        if (ip==""){
            return false
        }
        //print(getHost(url: "186.4.176.169"))
        //mb = modbus_new_tcp(ipAddress.cString(using: String.Encoding.ascii.rawValue) , port)
        mb = modbus_new_tcp(ip.cString(using: String.Encoding.ascii.rawValue) , port)
        var modbusErrorRecoveryMode = modbus_error_recovery_mode(0)
        modbusErrorRecoveryMode.rawValue = MODBUS_ERROR_RECOVERY_LINK.rawValue | MODBUS_ERROR_RECOVERY_PROTOCOL.rawValue
        modbus_set_error_recovery(mb!, modbusErrorRecoveryMode)
        modbus_set_slave(mb!, device)
        return true
    }
    
    func getHost(url: String) -> String{
        let host = CFHostCreateWithName(nil,url as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? NSData {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString: hostname)
                return numAddress
            }
        }
        print("error get ip")
        return ""
    }
    
    func connectWithError( error: NSError) -> Bool {
        //var error = error
        let ret = modbus_connect(mb!)
        if ret == -1 {
            self.error = self.buildNSError(errno: errno)
            return false
        }
        return true
    }

    func connect(success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            let ret = modbus_connect(self.mb!)
            if ret == -1 {
                let error = self.buildNSError(errno: errno)
                
                //dispatch_get_main_queue().async() {
                DispatchQueue.main.async {
                    failure(error)
                }
            }
            else {
                DispatchQueue.main.async {
                    success()
                }
            }
        }
    }
    
    func disconnect() {
        modbus_close(mb!)
    }

    func writeType(type: FunctionType, address: Int32, value: Int32, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        if type == .kBits {
            let status = value != 0
            self.writeBit(address: address, status: status,
                success: { () -> Void in
                    success()
                },
                failure: { (error: NSError) -> Void in
                    failure(error)
            })
        }
        else if type == .kRegisters {
            self.writeRegister(address: address, value: value,
                success: { () -> Void in
                    success()
                },
                failure: { (error: NSError) -> Void in
                    failure(error)
            })
        }
        else {
            let error = self.buildNSError(errno: errno, errorString: "Could not write. Function type is read only")
            failure(error)
        }
    }
    
    func readType(type: FunctionType, startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        if type == .kInputBits {
            self.readInputBitsFrom(startAddress: startAddress, count: count,
                success: { (array: [AnyObject]) -> Void in
                    success(array)
                },
                failure: { (error: NSError) -> Void in
                    failure(error)
            })
        }
        else if type == .kBits {
            self.readBitsFrom(startAddress: startAddress, count: count,
                success: { (array: [AnyObject]) -> Void in
                    success(array)
                },
                failure: { (error: NSError) -> Void in
                    failure(error)
            })
        }
        else if type == .kInputRegisters {
            self.readInputRegistersFrom(startAddress: startAddress, count: count,
                success: { (array: [AnyObject]) -> Void in
                    success(array)
                },
                failure: { (error: NSError) -> Void in
                    failure(error)
            })
        }
        else if type == .kRegisters {
            self.readRegistersFrom(startAddress: startAddress, count: count,
                success: { (array: [AnyObject]) -> Void in
                    success(array)
                },
                failure: { (error: NSError) -> Void in
                    failure(error)
            })
        }
    }

    func writeBit(address: Int32, status: Bool, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            if modbus_write_bit(self.mb!, address, status ? 1 : 0) >= 0 {
                DispatchQueue.main.async{
                    success()
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func writeRegister(address: Int32, value: Int32, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            if modbus_write_register(self.mb!, address, value) >= 0 {
                DispatchQueue.main.async {
                    success()
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func readBitsFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            let tab_reg: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(count))
            if modbus_read_bits(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                //for i in Int(count){
                //for var i = 0; i < Int(count); i+1 {
                for i in (0..<Int(count)){
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async{
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async{
                    failure(error)
                }
            }
        }
    }
    
    func readInputBitsFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            let tab_reg: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(count))
            if modbus_read_input_bits(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                //for var i = 0; i < Int(count); i++ {
                for i in (0..<Int(count)){
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async{
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }


    func readRegistersFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            let tab_reg: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: Int(count))
            if modbus_read_registers(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                //for var i = 0; i < Int(count); i++ {
                for i in (0..<Int(count)){
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async{
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async{
                    failure(error)
                }
            }
        }
    }

    func readInputRegistersFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            let tab_reg: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: Int(count))
            if modbus_read_input_registers(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                //for var i = 0; i < Int(count); i++ {
                for i in (0..<Int(count)){
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async {
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func writeRegistersFromAndOn(address: Int32, numberArray: NSArray, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue!.async() {
            let valueArray: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: numberArray.count)
            //for var i = 0; i < numberArray.count; i++ {
            for i in (0..<numberArray.count){
                valueArray[i] = UInt16(numberArray[i] as! Int)
            }
            
            if modbus_write_registers(self.mb!, address, Int32(numberArray.count), valueArray) >= 0 {
                DispatchQueue.main.async {
                    success()
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async{
                    failure(error)
                }
            }
        }
    }
 
    private func buildNSError(errno: Int32, errorString: NSString) -> NSError {
        let details = NSMutableDictionary()
        details.setValue(errorString, forKey: NSLocalizedDescriptionKey)
        //let error = NSError(domain: "Modbus", code: Int(errno), userInfo: (details as [NSObject : AnyObject]))
        let error = NSError(domain: "Modbus", code: Int(errno), userInfo: (details as! [String : Any]))
        return error
    }
    
    private func buildNSError(errno: Int32) -> NSError {
        //let errorString = NSString(UTF8String: modbus_strerror(errno))
        let errorString = NSString(string: String(describing: modbus_strerror(errno)))
        return self.buildNSError(errno: errno, errorString: errorString)
    }

    deinit {
//        dispatch_release(modbusQueue);
        modbus_free(mb!);
    }
}
