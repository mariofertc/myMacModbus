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
    @IBOutlet weak var imgState: UIImageView!
    @IBOutlet weak var txtPrueba: UILabel!
 
    @IBOutlet weak var scTransGen: UISegmentedControl!
    let defaults = UserDefaults.standard
    
    var _modelController: ModelController? = nil
    
    @IBOutlet weak var btnLink: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getTimeOfDate), userInfo: nil, repeats: true)
        //startView()
        //Call modelController
        if _modelController == nil {
            _modelController = ModelController()
        }
        addNavLogo()
        btnLink.addTarget(self, action: #selector(linkClicked), for: .touchUpInside)
    }
    
    @IBAction func didTapUrl(sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.gentec.com.ec")!)
        //UIApplication.shared.openURL(NSURL(string: "http://www.gentec.com.ec ")! as URL)
    }
    @IBAction func linkClicked(sender: AnyObject) {
        openUrl(urlStr: "http://www.gentec.com.ec")
    }
    @IBAction func didChangeTransGen(_ sender: Any) {
        initialize_graph()
        print("Ecy")
    }
    func startView(){
        initialize_graph()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(DataViewController.refreshEvery1Secs), userInfo: nil, repeats: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        startView()
    }
    func openUrl(urlStr:String!) {
        
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.openURL(url as URL)
        }
        
    }
    
    //@objc func refreshEvery1Secs(){
    @objc func refreshEvery1Secs(){
        if(appDelegate.result.count>0){
            //print("actualizando valor")
            var res:Float = 0
            if(defaults.integer(forKey: "bits") == 1){
                res = get32BytesFloat(result: appDelegate.result)
            }else{
                res = appDelegate.result[0] as! Float
            }
            res = res / defaults.float(forKey: "operacion")
            
            self.txtPrueba.text = String(format: "%.2f KVA", res)
            //self.txtPrueba.text = String(describing: res) + " KVA"
            //gvMedidor.value = Float(appDelegate.result[0] as! NSNumber)
            gvMedidor.value = Float(res)
            imgState.isHighlighted = true
        }else{
            imgState.isHighlighted = false
            self.txtPrueba.text = "0 KVA"
            gvMedidor.value = 0
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
        gvMedidor.style = WMGaugeViewStyle3D()
        //WMGaugeViewStyle3D)
        //WMGaugeViewStyleFlatThin
        var maximo:Float = 0
        if(self.scTransGen.selectedSegmentIndex == 0){
            maximo = defaults.float(forKey: "maximo")
        }else{
            maximo = defaults.float(forKey: "maxGen")
        }
        gvMedidor.maxValue = maximo;
        gvMedidor.minValue = defaults.float(forKey: "minimo");
        gvMedidor.showRangeLabels = true;
        
        //gvMedidor.rangeValues = [500, 1000, 1500, 2000.0];
        //gvMedidor.rangeValues = [maximo*0.25, maximo*0.5, maximo*0.75, maximo];
        gvMedidor.rangeValues = [maximo*0.90,maximo];
        //gvMedidor.rangeColors = [UIColor.white,UIColor.green, UIColor.orange,UIColor.red];
        gvMedidor.rangeColors = [UIColor.lightGray, UIColor.red];
        gvMedidor.rangeLabels = ["Normal", "Muy Alto"];
        gvMedidor.scaleDivisions = 10;
        gvMedidor.scaleSubdivisions = 5;
        if(maximo<=10){
            gvMedidor.scaleDivisions = CGFloat(maximo)
            gvMedidor.scaleSubdivisions = 1;
        }
        if(maximo<50){
            gvMedidor.scaleSubdivisions = 1;
        }
        gvMedidor.scaleStartAngle = 30;
        gvMedidor.unitOfMeasurement = "KVA";
        gvMedidor.showUnitOfMeasurement = true;
        gvMedidor.scaleDivisionsWidth = 0.002;
        gvMedidor.scaleSubdivisionsWidth = 0.04;
        gvMedidor.scaleEndAngle = 280;
        gvMedidor.rangeLabelsFontColor = UIColor.black;
        gvMedidor.rangeLabelsWidth = 0.04;
        gvMedidor.rangeLabelsFont = UIFont.init(name: "Calibri", size: 0.04)
        //gvMedidor.rangeLabelsFont = UIFont.init(name: "Helvetica", size: 0.04)
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
        print(dataObject)
    }
    func windowShouldClose(sender: Any) {
        _modelController?.disconnect()
        //NSApplication.shared().terminate(self)
    }
    func addNavLogo(){
        let navController = navigationController!
        let image = #imageLiteral(resourceName: "gentec150")
        let imageView = UIImageView(image:image)
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerX = bannerWidth/2 - image.size.width/2
        let bannerY = bannerHeight/2 - image.size.height/2
        imageView.frame = CGRect(x: bannerX, y:bannerY, width: bannerWidth, height:bannerHeight)
        imageView.contentMode = .scaleAspectFit
        //navigationItem.titleView = imageView
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView:imageView)
        let btnConfig = UIButton(type: .system)
        let adjustImage = #imageLiteral(resourceName: "config.io")
        btnConfig.setImage(adjustImage.withRenderingMode(.automatic), for: .normal)
        btnConfig.frame = CGRect(x:0, y:0, width: 34, height:34)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView:btnConfig)
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        btnConfig.addTarget(self, action: #selector(btnConfigAction), for: .touchUpInside)
    }
    @objc func btnConfigAction(sender: UIButton!)
    {
        /*let vc = ConfigViewController(nibName: "ConfigViewController",bundle: nil)
        navigationController?.pushViewController(vc,animated: true)*/
        /*let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfigViewController") as! ConfigViewController
        self.present(loginVC, animated: true, completion: nil)*/
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfigViewController") as! ConfigViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
        print("tapped button")
    }
}

