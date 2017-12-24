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

    @IBOutlet weak var uivAjustes: UIView!
    @IBOutlet weak var txtPort: UITextField!
    @IBOutlet weak var txtRegistro: UITextField!
    @IBOutlet weak var txtMaximo: UITextField!
    @IBOutlet weak var txtMinimo: UITextField!

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getTimeOfDate), userInfo: nil, repeats: true)
        initialize_graph()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(DataViewController.refreshEvery1Secs), userInfo: nil, repeats: true)
        //btnGuardar.targetForAction(Selector("tappedButton"), withSender: self)
        //appDelegate.Check="Modified"
        
        //btnGuardar.
        
        btnGuardar.addTarget(self, action: #selector(btnGuardarAction), for: .touchUpInside)
    }
    
    //@objc func tappedButton(sender: UIButton!)
    @objc func btnGuardarAction(sender: UIButton!)
    {
        defaults.setValue(self.txtIp.text, forKey: "ip")
        defaults.setValue(self.txtPort.text, forKey: "port")
        defaults.setValue(self.txtRegistro.text, forKey: "registro")
        defaults.setValue(self.txtMaximo.text, forKey: "maximo")
        defaults.setValue(self.txtMinimo.text, forKey: "minimo")
        defaults.setValue(true, forKey: "esReiniciar")
        initialize_graph()
        /*gvMedidor.maxValue = 2000.0;
        gvMedidor.minValue = 10;*/
        
        //appDelegate.setValue("192.168.1.7", forKey: "ip")
        print("tapped button")
    }
    
    //@objc func refreshEvery1Secs(){
    @objc func refreshEvery1Secs(){
        if(appDelegate.result.count>0){
            //print("actualizando valor")
            let res = get32BytesFloat(result: appDelegate.result)
            self.txtPrueba.text = String(describing: res) + " KVA"
            //gvMedidor.value = Float(appDelegate.result[0] as! NSNumber)
            gvMedidor.value = Float(res)
        }else{
            print("nodata")
        }
        // refresh code
    }
    
    func get32BytesFloat(result: [AnyObject]) -> Float{
        let bytesResult: [UInt16] = result as! [UInt16]
        //17143
        var v16 : UInt16 = bytesResult[0]
        let b1 = v16>>8&0x00ff
        let b2 = v16&0x0ff
        //41148
        v16 = bytesResult[1]
        let b3 = v16>>8&0x00ff
        let b4 = v16&0x0ff
        //Result 123.814
        let cllBytes: [UInt8] = [UInt8(b1),UInt8(b2),UInt8(b3),UInt8(b4)]
        let data_res = Data(cllBytes)
        return Float(bitPattern:UInt32(bigEndian: data_res.withUnsafeBytes{$0.pointee}))
    }
    
    func pad(string : String, toSize: Int32) -> String {
        var padded = string
        for _ in 0..<(UInt32(toSize) - UInt32(string.count)) {
            padded = "0" + padded
        }
        return padded
    }
    
    func initialize_graph(){
        //gvMedidor.style = WMGaugeViewStyleFlatThin()
        gvMedidor.style = WMGaugeViewStyle3D()
        //WMGaugeViewStyle3D)
        //WMGaugeViewStyleFlatThin
        
        let maximo = defaults.float(forKey: "maximo")
        gvMedidor.maxValue = maximo;
        gvMedidor.minValue = defaults.float(forKey: "minimo");
        //print(defaults.float(forKey: "maximo"))
        //gvMedidor.maxValue = 2000;
        gvMedidor.showRangeLabels = true;
        
        //gvMedidor.rangeValues = [500, 1000, 1500, 2000.0];
        gvMedidor.rangeValues = [maximo*0.25, maximo*0.5, maximo*0.75, maximo];
        gvMedidor.rangeColors = [UIColor.white,UIColor.green, UIColor.orange,UIColor.red];
        gvMedidor.rangeLabels = ["Muy Bajo", "Bajo", "Alto", "Muy Alto"];
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
        if(dataObject == "Inicio"){
            //uivAjustes.hidden = true
            self.gvMedidor.isHidden = false
            self.uivAjustes.isHidden = true
            self.btnGuardar.isHidden = true
        }else{
            self.uivAjustes.isHidden = false
            self.txtIp.text=String(defaults.string(forKey: "ip")!)
            self.txtPort.text=String(defaults.integer(forKey: "port"))
            //print(defaults.string(forKey: "registro"))
            self.txtRegistro.text=String(defaults.integer(forKey: "registro"))
            self.txtMaximo.text=String(defaults.integer(forKey: "maximo"))
            self.txtMinimo.text=String(defaults.integer(forKey: "minimo"))
            self.btnGuardar.isHidden = false
        }
        //let defaults = NSUserDefaults.standardUserDefaults()
        //self.gvMedidor.isHidden = true
        //self.modelCo
        //self.txtPrueba.text = dataReceive
//        self.txtPrueba.text = appDelegate.result
        //self.dataLabel!.text = dataObject
    }
    @IBOutlet weak var txtPrueba: UILabel!
    //MARK: Properties
    
}

