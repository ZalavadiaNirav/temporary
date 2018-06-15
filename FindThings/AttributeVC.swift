//
//  AttributeVC.swift
//  FindThings
//
//  Created by Gaurav Amrutiya on 07/06/18.
//  Copyright © 2018 Gaurav Amrutiya. All rights reserved.
//

import UIKit

class AttributeVC: UIViewController {

    
    @IBOutlet weak var addAttributeBtn: UIButton!
    @IBOutlet weak var attributeNameTxt: UITextField!
    @IBOutlet weak var attributeValueTxt: UITextField!
    @IBOutlet weak var attributeTbl: UITableView!
    @IBOutlet weak var notesTxtVw: UITextView!
    
    
    var attributeArr = NSMutableArray()
    var selectedAttributeArr = NSMutableArray()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        attributeArr = NSMutableArray()
        attributeTbl.delegate=self
        attributeTbl.dataSource=self
        attributeTbl.allowsMultipleSelection=true
        selectedAttributeArr = NSMutableArray ()
    }
    @IBAction func addAttributeAction(_ sender: Any)
    {
        if (attributeNameTxt.text?.isEmpty == false && (attributeValueTxt.text?.isEmpty == false))
        {
            let dict:Dictionary = ["attribute":attributeNameTxt.text,"value":attributeValueTxt.text]
            attributeArr.add(dict)
            attributeTbl.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributeArr.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension AttributeVC : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.font = UIFont.systemFont(ofSize:20.0)
        cell?.textLabel?.text = (attributeArr[indexPath.row] as? [String : String])?["attribute"]
        
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize:18.0)
        cell?.detailTextLabel?.text = (attributeArr[indexPath.row] as? [String:String])?["value"]
        cell?.accessoryType = UITableViewCellAccessoryType.none
        
        return cell!
    }
}


extension AttributeVC : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        //        if let sr = tableView.indexPathsForSelectedRows {
        ////            if sr.count == limit {
        ////                let alertController = UIAlertController(title: "Oops", message:
        ////                    "You are limited to \(limit) selections", preferredStyle: .alert)
        ////                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
        ////                }))
        ////                self.present(alertController, animated: true, completion: nil)
        ////
        ////                return nil
        ////            }
        //        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("selected  \(attributeArr[indexPath.row])")
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.isSelected {
                cell.accessoryType = .checkmark
            }
        }
        
        if let sr = tableView.indexPathsForSelectedRows {
            print("didDeselectRowAtIndexPath selected rows:\(sr)")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        print("deselected  \(attributeArr[indexPath.row])")
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        
        if let sr = tableView.indexPathsForSelectedRows {
            print("didDeselectRowAtIndexPath selected rows:\(sr)")
        }
    }
}
