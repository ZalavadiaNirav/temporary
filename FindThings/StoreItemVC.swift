//
//  StoreItemVC.swift
//  FindThings
//
//  Created by Gaurav Amrutiya on 08/06/18.
//  Copyright © 2018 Gaurav Amrutiya. All rights reserved.
//

import UIKit
import RATreeView

class  StoreItemVC: UIViewController , UIScrollViewDelegate , RATreeViewDelegate , RATreeViewDataSource, UIPickerViewDelegate , UIPickerViewDataSource , UITextFieldDelegate {
    
    var data:[DataObject] = NSArray() as! [DataObject]
    var treeView : RATreeView!
    var ParticularTree = DataObject(name: "")
    var places : NSMutableArray = []
    var selectedPlaces : String = ""
    
    
    @IBOutlet weak var itemNameTxt: UITextField!
    @IBOutlet weak var placeTxt: UITextField!
    
    @IBOutlet weak var storeBtn: UIButton!
    @IBOutlet weak var placeScrollVw: UIScrollView!
    @IBOutlet weak var addAttributeBtn: UIButton!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var placesPicker: UIPickerView!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        placeScrollVw.delegate=self
        places = NSMutableArray()
        self.extractPlaces()
    }
    
    func setupTreeView() -> Void
    {

       
        placeScrollVw.isHidden = false
        treeView = RATreeView(frame: self.view.bounds)
        treeView.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        treeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        treeView.delegate = self;
        treeView.dataSource = self;
        treeView.treeFooterView = UIView()
        treeView.backgroundColor = .clear
        treeView.tag=100
        treeView.frame = CGRect(x: 0, y:0, width:self.view.frame.size.width, height: treeView.frame.size.height)
        placeScrollVw.contentSize=CGSize(width: self.view.frame.size.width, height: (treeView.frame.size.height))
        placeScrollVw.addSubview(treeView)
        placeScrollVw.bringSubview(toFront: treeView)
        treeView.reloadData()

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (textField == placeTxt)
        {
            textField.resignFirstResponder()
            placeTxt.text=""
            placeScrollVw.isHidden = true
        //self.treeView.isHidden = true
            placesPicker.isHidden = false
            toolbar.isHidden = false
            
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    func extractPlaces()
    {
        let tabBar = tabBarController as! BaseTabbarController
        
        for index in 0...tabBar.structure.count-1
        {
            let placeArr = tabBar.structure
            let dict = placeArr[index] as? NSMutableDictionary
            let placeStr = dict!["name"] as? String
            places.insert(placeStr!, at: index)
        }
        print("places array = \(places)")
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return places.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return places[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedPlaces = (places[row] as? String)!
    }
    
    @IBAction func storeAction(_ sender: Any)
    {
        
    }
    
    @IBAction func AddAttributeAction(_ sender: Any)
    {
        
    }
    
    @IBAction func doneAction(_ sender: Any)
    {
        toolbar.isHidden=true
        placesPicker.isHidden=true
        placeTxt.text = selectedPlaces
        
        
        let tabBar = tabBarController as! BaseTabbarController
        if(tabBar.dataArr.count != 0)
        {
            for ind in 0...tabBar.dataArr.count-1
            {
                let pname = tabBar.dataArr[ind].name
                if(pname == placeTxt.text)
                {
                    ParticularTree=tabBar.dataArr[ind]
                }
            }
        }
        
        print("parent aray=\(ParticularTree)")
        self.setupTreeView()
        treeView.reloadData()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        toolbar.isHidden=true
        placesPicker.isHidden=true
        placeTxt.text = ""
    }
    
    

    
    
    //MARK: RATreeView data source
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int
    {
        if let item = item as? DataObject {
            return item.children.count
        }
        else {
            return self.ParticularTree.children.count
        }
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any
    {
        if let item = item as? DataObject {
            return item.children[index]
        }
        else {
            return ParticularTree.children[index] as AnyObject
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell
    {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        let item = item as! DataObject
        
        let level = treeView.levelForCell(forItem: item)
        let detailsText = "Number of children \(item.children.count)"
        cell.selectionStyle = .none
        cell.setup(withTitle: item.name, detailsText: detailsText, level: level, additionalButtonHidden: false)
        
        cell.additionButtonActionBlock = { [weak treeView] cell in
            
            let item=(treeView?.item(for: cell) as! DataObject)
            print("item stored here=\(treeView?.item(for: cell) as! DataObject)")
            
            let stored = UIAlertController(title:"Successfully Stored", message:"Your Item is stored In\(item.name)", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler:nil)
            
            stored.addAction(action)
            self.present(stored, animated: true, completion:
            {
                guard let treeView = treeView else {
                    return;
                }
                let item = treeView.item(for: cell) as! DataObject
            
                for index in 0...self.places.count-1
                {
                    let arrItem = self.places[index] as! DataObject
                    if(arrItem.name==item.name)
                    {
                        print("ind=\(index)")
                    }
                }
        })
                

        }
        return cell
    }
    
    //MARK: RATreeView delegate
    
    func treeView(_ treeView: RATreeView, commit editingStyle: UITableViewCellEditingStyle, forRowForItem item: Any) {
        guard editingStyle == .delete else { return; }
        let item = item as! DataObject
        let parent = treeView.parent(forItem: item) as? DataObject
        
        let index: Int
        if let parent = parent {
            index = parent.children.index(where: { dataObject in
                return dataObject === item
            })!
            parent.removeChild(item)
            
        } else {
            index = self.data.index(where: { dataObject in
                return dataObject === item;
            })!
            self.data.remove(at: index)
        }
        
        self.treeView.deleteItems(at: IndexSet(integer: index), inParent: parent, with: RATreeViewRowAnimationRight)
        if let parent = parent {
            self.treeView.reloadRows(forItems: [parent], with: RATreeViewRowAnimationNone)
        }
    }
    
    static func commonInit() -> [DataObject] {
        let phone1 = DataObject(name: "Phone 1")
        let device1 = DataObject(name: "Device 1")
        
        //        let phone11 = DataObject(name: "Devies",children:[device1])
        
        
        let phone2 = DataObject(name: "Phone 2")
        let phone3 = DataObject(name: "Phone 3")
        let phone4 = DataObject(name: "Phone 4")
        let phones = DataObject(name: "Phones", children: [phone1, phone2, phone3, phone4])
        
        
        let notebook1 = DataObject(name: "Notebook 1")
        let notebook2 = DataObject(name: "Notebook 2")
        
        let computer1 = DataObject(name: "Computer 1", children: [notebook1, notebook2])
        let computer2 = DataObject(name: "Computer 2")
        let computer3 = DataObject(name: "Computer 3")
        let computers = DataObject(name: "Computers", children: [computer1, computer2, computer3])
        
        let cars = DataObject(name: "Cars")
        let bikes = DataObject(name: "Bikes")
        let houses = DataObject(name: "Houses")
        let flats = DataObject(name: "Flats")
        let motorbikes = DataObject(name: "motorbikes")
        let drinks = DataObject(name: "Drinks")
        let food = DataObject(name: "Food")
        let sweets = DataObject(name: "Sweets")
        let watches = DataObject(name: "Watches")
        let walls = DataObject(name: "Walls")
        
        return [phones, computers, cars,
                bikes, houses, flats, motorbikes, drinks, food, sweets, watches, walls]
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
