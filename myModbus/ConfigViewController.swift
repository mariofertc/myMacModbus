//
//  DataViewController.swift
//  myModbus
//
//  Created by Jeannette Yungan on 28/11/17.
//  Copyright © 2017 Mario Torres. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""
    @IBOutlet weak var gvMedidor: WMGaugeView!
    var dataReceive: String = ""
    var refresher: UIRefreshControl!
    @IBOutlet weak var txtIp: UITextField!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnGuardar: UIButton!
    @IBOutlet weak var uivAjustes: UIView!
    @IBOutlet weak var txtPort: UITextField!
    @IBOutlet weak var txtRegistro: UITextField!
    @IBOutlet weak var txtMaximo: UITextField!
    //@IBOutlet weak var txtMinimo: UITextField!
    @IBOutlet weak var imgState: UIImageView!
    @IBOutlet weak var segBits: UISegmentedControl!
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var btnLink: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnGuardar.addTarget(self, action: #selector(btnGuardarAction), for: .touchUpInside)
        btnLink.addTarget(self, action: #selector(linkClicked), for: .touchUpInside)
    }
    
    @IBAction func linkClicked(sender: AnyObject) {
        openUrl(urlStr: "http://www.gentec.com.ec")
    }
    func openUrl(urlStr:String!) {
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    //@objc func tappedButton(sender: UIButton!)
    @objc func btnGuardarAction(sender: UIButton!)
    {
        defaults.setValue(self.txtIp.text, forKey: "ip")
        defaults.setValue(self.txtPort.text, forKey: "port")
        defaults.setValue(self.txtRegistro.text, forKey: "registro")
        defaults.setValue(self.txtMaximo.text, forKey: "maximo")
        //defaults.setValue(self.txtMinimo.text, forKey: "minimo")
        defaults.setValue(true, forKey: "esReiniciar")
        defaults.setValue(self.segBits.selectedSegmentIndex, forKey: "bits")
        
        /*gvMedidor.maxValue = 2000.0;
         gvMedidor.minValue = 10;*/
        
        //appDelegate.setValue("192.168.1.7", forKey: "ip")
        print("tapped button")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.dataLabel.text = dataObject;
             self.txtIp.text=String(defaults.string(forKey: "ip")!)
             self.txtPort.text=String(defaults.integer(forKey: "port"))
             self.txtRegistro.text=String(defaults.integer(forKey: "registro"))
             self.txtMaximo.text=String(defaults.integer(forKey: "maximo"))
             //self.txtMinimo.text=String(defaults.integer(forKey: "minimo"))
             self.segBits.selectedSegmentIndex = defaults.integer(forKey: "bits")
            //print(defaults.string(forKey: "registro"))
        
        //let defaults = NSUserDefaults.standardUserDefaults()
        //self.gvMedidor.isHidden = true
        //self.modelCo
        //self.txtPrueba.text = dataReceive
        //        self.txtPrueba.text = appDelegate.result
        //self.dataLabel!.text = dataObject
    }
}
