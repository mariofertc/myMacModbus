//
//  DataViewController.swift
//  myModbus
//
//  Created by Jeannette Yungan on 28/11/17.
//  Copyright © 2017 Mario Torres. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""
    var dataReceive: String = ""
    var timer: NSTimer!
    var refresher: UIRefreshControl!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getTimeOfDate), userInfo: nil, repeats: true)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:Selector("refreshEvery1Secs"), userInfo: nil, repeats: true)
        //appDelegate.Check="Modified"
    }
    
    func refreshEvery1Secs(){
        if(appDelegate.result.count>0){
            print("actualizando valor")
        self.txtPrueba.text = String(appDelegate.result[0])
        }
        // refresh code
    }
    
    func refresh(sender: AnyObject){
        
        refreshEvery1Secs() // calls when ever button is pressed
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel.text = dataObject;
        //self.modelCo
        //self.txtPrueba.text = dataReceive
//        self.txtPrueba.text = appDelegate.result
        //self.dataLabel!.text = dataObject
    }
    @IBOutlet weak var txtPrueba: UILabel!
    //MARK: Properties
    
}

