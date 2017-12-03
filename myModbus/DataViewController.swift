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
    @IBOutlet weak var gvMedidor: WMGaugeView!
    var dataReceive: String = ""
    var timer: Timer!
    var refresher: UIRefreshControl!
    @IBOutlet weak var txtIp: UITextField!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnGuardar: UIButton!
    @IBAction func txtIp(sender: AnyObject) {
        //let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setValue(sender.textLabel, forKey: "ip")
        print("Ip Cambiada")
    }
    @IBOutlet weak var txtPort: UITextField!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getTimeOfDate), userInfo: nil, repeats: true)
        
        
        gvMedidor.style = WMGaugeViewStyleFlatThin()
        //WMGaugeViewStyle3D)
        //WMGaugeViewStyleFlatThin
        gvMedidor.maxValue = 2000.0;
        gvMedidor.showRangeLabels = true;
        gvMedidor.rangeValues = [500, 1000, 1500, 2000.0];
        gvMedidor.rangeColors = [ UIColor.white,UIColor.green, UIColor.orange,UIColor.red    ];
        gvMedidor.rangeLabels = [ "VERY LOW",          "LOW",             "OK",              "OVER FILL"        ];
        gvMedidor.scaleDivisions = 10;
        gvMedidor.scaleSubdivisions = 5;
        gvMedidor.scaleStartAngle = 30;
        gvMedidor.unitOfMeasurement = "KVA";
        gvMedidor.showUnitOfMeasurement = true;
        gvMedidor.scaleDivisionsWidth = 0.002;
        gvMedidor.scaleSubdivisionsWidth = 0.04;
        gvMedidor.scaleEndAngle = 280;
        gvMedidor.rangeLabelsFontColor = UIColor.black;
        gvMedidor.rangeLabelsWidth = 0.04;
        gvMedidor.rangeLabelsFont = UIFont.init(name: "Helvetica", size: 0.04)
        gvMedidor.value = 0;
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(DataViewController.refreshEvery1Secs), userInfo: nil, repeats: true)
        //btnGuardar.targetForAction(Selector("tappedButton"), withSender: self)
        //appDelegate.Check="Modified"
        
        //btnGuardar.
        
        btnGuardar.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        
        
       /* defaults.set
        defaults.set
        defaults.set(25, forKey: "Age")
        defaults.set(true, forKey: "UseTouchID")
        defaults.set(CGFloat.pi, forKey: "Pi")
        
        
        defaults.set("Paul Hudson", forKey: "Name")
        defaults.set(Date(), forKey: "LastRun")
        
        let elmer: Int = NSUserDefaults.standardUserDefaults().integerForKey("elmer")
*/
    }
    
    func tappedButton(sender: UIButton!)
    {
        
        defaults.setValue(self.txtIp.text, forKey: "ip")
        defaults.setValue(self.txtPort.text, forKey: "port")
        
        //appDelegate.setValue("192.168.1.7", forKey: "ip")
        print("tapped button")
    }
    
    func refreshEvery1Secs(){
        if(appDelegate.result.count>0){
            //print("actualizando valor")
            self.txtPrueba.text = String(describing: appDelegate.result[0])
            gvMedidor.value = Float(appDelegate.result[0] as! NSNumber)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel.text = dataObject;
        
        //let defaults = NSUserDefaults.standardUserDefaults()
        self.txtIp.text=String(defaults.string(forKey: "ip")!)
        self.txtPort.text=String(defaults.integer(forKey: "port"))
        //self.modelCo
        //self.txtPrueba.text = dataReceive
//        self.txtPrueba.text = appDelegate.result
        //self.dataLabel!.text = dataObject
    }
    @IBOutlet weak var txtPrueba: UILabel!
    //MARK: Properties
    
}

