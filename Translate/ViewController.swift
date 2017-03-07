//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var selectLang: UIPickerView!
    @IBOutlet weak var langLabel: UILabel!
    @IBOutlet weak var langSelector: UITextField!
    var languages: [String] = ["French", "Irish", "Japanese", "Korean"]
    var langSelected = ""
    let defaultLang = 0
    
    
    //var data = NSMutableData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Remove keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(ViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        //Code for picker
        self.selectLang.dataSource = self
        self.selectLang.delegate = self
        //Set a default value for the picker
        selectLang.selectRow(defaultLang, inComponent:0, animated:false)
        langSelector.text = languages[defaultLang]
        
        self.selectLang.isHidden = true;
        
    }
    
    //Function called to remove keyboard
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count;
    }
    
    //Adds the data into the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row];
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        langLabel.text = languages[row]
        langSelector.text = languages[row]
        self.selectLang.isHidden = true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == self.langSelector)
        {
            self.selectLang.isHidden = false
        }
    }
    
    //Translates Function
    @IBAction func translate(_ sender: AnyObject) {
        
        let str = textToTranslate.text
        let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        switch selectLang.selectedRow(inComponent: 0){
        case 0:
            langSelected = "fr"
        case 1:
            langSelected = "ga"
        case 2:
            langSelected = "ja"
        case 3:
            langSelected = "ko"
            
        default:
            langSelected = "fr"
            langLabel.text = languages[defaultLang]
            
        }
        
        let langStr = ("en|"+langSelected).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
        let url = URL(string: urlStr)
        
        let request = URLRequest(url: url!)// Creating Http Request
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.color = UIColor.purple
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        var result = "<Translation Error>"
        
        //New Code
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request){
            (data, response, error) in
            
        indicator.stopAnimating()
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if(httpResponse.statusCode == 200)
                {
                    
                    let jsonDict: NSDictionary!=(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    
                    if(jsonDict.value(forKey: "responseStatus") as! NSNumber == 200)
                    {
                        let responseData: NSDictionary = jsonDict.object(forKey: "responseData") as! NSDictionary
                        
                        result = responseData.object(forKey: "translatedText") as! String
                    }
                }
                
                DispatchQueue.main.sync()
                {
                    self.translatedText.text = result
                }
            }
            
        }
        
        task.resume()
        
    }
}

