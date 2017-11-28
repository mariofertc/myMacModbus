//
//  ModelController.swift
//  myModbus
//
//  Created by Jeannette Yungan on 28/11/17.
//  Copyright © 2017 Mario Torres. All rights reserved.
//

import UIKit
//import Foundation

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData: [String] = []
    //var mod: NSObject;
    //var client: SwiftLibModbus = nil
    private let swiftLibModbus: SwiftLibModbus

    override init() {
        swiftLibModbus = SwiftLibModbus(ipAddress: "192.168.1.6", port: 502, device: 1)
        super.init()
        // Create the data model.
        let dateFormatter = NSDateFormatter()
        pageData = dateFormatter.monthSymbols
        //Inicia modbus call
        //client = SwiftLibModbus(192.168.1.6,3,3)
        
        swiftLibModbus.connect(
            { () -> Void in
                print("exito")
                self.swiftLibModbus.readRegistersFrom(40001, count: 2,
                    success: { (array: [AnyObject]) -> Void in
                        //Do something with the returned data (NSArray of NSNumber)..
                        print("success: \(array)")
                    },
                    failure:  { (error: NSError) -> Void in
                        //Handle error
                        print("error")
                })
                
                //connected and ready to do modbus calls
            },
            failure: { (error: NSError) -> Void in
                //Handle error
                print("error")
        })
    }
    func disconnect(){
        self.swiftLibModbus.disconnect()
    }

    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
        dataViewController.dataObject = self.pageData[index]
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

}

