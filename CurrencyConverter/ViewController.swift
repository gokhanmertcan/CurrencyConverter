//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Mac14 on 14.06.2021.
//  Copyright © 2021 Mac6. All rights reserved.
//

import UIKit
import Foundation

//rgb renk kodlarını kullanmak için
extension UIColor {
    convenience init(rgb:UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >>  8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, XMLParserDelegate{
    var parser = XMLParser()
    var currency = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var currencyName = NSMutableString()
    var forexBuying = NSMutableString()
    
    var baseRate:Double = 1.0
    //    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnCalculate: UIButton!
    @IBOutlet weak var lblCName: UILabel!
    @IBOutlet weak var lblCPrice: UILabel!
    
    //hesaplama işlemleri
    @IBAction func convertPressed(_ sender: UIButton) {
        let base = textField.text!
        //sayı giriş kontrolü
        if let num = Double(base) {
            print("girilen karakter sayı")
            baseRate = num
            parsingDataFromURL()
        }
        else{
            let refreshAlert = UIAlertController(title: "Hata!", message: "Lütfen geçerli bir sayı giriniz.", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parsingDataFromURL()
        textField.textAlignment = .left
        tblView.dataSource = self
        tblView.allowsSelection = false
        tblView.showsVerticalScrollIndicator = false
        
        //tableview renklendirme
        UITableView.appearance().separatorStyle = .singleLine
        UITableView.appearance().backgroundColor = UIColor(rgb: 0x540000)
        UITableViewCell.appearance().backgroundColor = UIColor(rgb: 0x540000)
        
        tblView.separatorColor = UIColor(rgb: 0xFFFFFF)
        
        btnCalculate.backgroundColor = UIColor(rgb: 0x540000)
        btnCalculate.layer.cornerRadius = 5
        btnCalculate.tintColor = .white
//        btnCalculate.layer.borderWidth = 1
//        btnCalculate.layer.borderColor = UIColor.black.cgColor
    }
    
    
    
    func parsingDataFromURL()
    {
        currency = []
        parser = XMLParser(contentsOf: NSURL(string: "https://www.tcmb.gov.tr/kurlar/today.xml")! as URL)!
        parser.delegate = self
        parser.parse()
        tblView.reloadData()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        element = elementName as NSString
        if(elementName as NSString).isEqual(to: "Currency"){
            elements = NSMutableDictionary()
            elements = [:]
            currencyName = NSMutableString()
            currencyName = " "
            forexBuying = NSMutableString()
            forexBuying = " "
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String){
        if element.isEqual(to: "Isim"){
            currencyName.append(string)
        }else if element.isEqual(to: "ForexBuying"){
            forexBuying.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if(elementName as NSString).isEqual(to: "Currency"){
            if !currencyName.isEqual(nil){
                elements.setObject(currencyName, forKey: "Isim" as NSCopying)
            }
            if !forexBuying.isEqual(nil){
                elements.setObject(forexBuying, forKey: "ForexBuying" as NSCopying)
            }
            currency.add(elements)
        }
        
    }
    
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currency.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        
        if(cell.isEqual(NSNull.self)){
            cell = Bundle.main.loadNibNamed("myCell",owner: self,options:nil)![0] as! UITableViewCell
        }
        
        cell.textLabel?.text = (currency.object(at: indexPath.row) as AnyObject).value(forKey: "Isim") as! NSString as String
        cell.detailTextLabel?.text = (currency.object(at: indexPath.row) as AnyObject).value(forKey: "ForexBuying") as! NSString as String
        
        
        let str = cell.detailTextLabel?.text
        
        //" 12.121221\n\t\t\t"
        
        let sep1 = str!.components(separatedBy: "\n")
        let sep2 = sep1[0]

        let sep3 = sep2.components(separatedBy: " ")
        let sep4 = sep3[1]
        
        if let cost = Double(sep4) {
            cell.detailTextLabel?.text = String(format: "%.3f", cost * baseRate)
        } else {
            print("gelen değeri int'e çeviremedim \(sep4)")
        }
        
        return cell
        
    }
    
}

