//
//  FirstViewController.swift
//  FindThings
//
//  Created by Gaurav Amrutiya on 07/06/18.
//  Copyright © 2018 Gaurav Amrutiya. All rights reserved.
//

import UIKit
import RATreeView

class ManageVC:UIViewController,UITabBarDelegate,RATreeViewDelegate,RATreeViewDataSource
{

    var treeView : RATreeView!
    var data : [DataObject]
    var editButton : UIBarButtonItem!
    var childArr = NSMutableArray()
    var parentArr = NSMutableArray()
    
    convenience init() {
        self.init(nibName : nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        data = ManageVC.commonInit()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        data = ManageVC.commonInit()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.view.backgroundColor=UIColor.white
        title = "Things"
        setupTreeView()
        updateNavigationBarButtons()
        
        
        print("parent=\(self.iterateparent())")
        
        //        let x:Int = 10
        //        var y:Int = 80
        //        self.extractChild(child: data, Px: x, Py:  &y)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        let tabBar = tabBarController as! BaseTabbarController
        self.iterateparent()
        
        tabBar.structure = self.parentArr
        tabBar.dataArr = data
       
    }
    
    func iterateparent()
    {
        for item in data
        {
            if let item = item as? DataObject
            {
                let childDict = NSMutableDictionary()
//                childDict.setObject(item.name, forKey: "name" as String)
                childDict["name"]=item.name
                if(item.children.count != 0)
                {
                    let childArr = self.iteratechild(child:item.children)
                    childDict["child"]=childArr
//                    childDict.setObject(childArr, forKey:"child" as String)
                    parentArr.add(childDict)
                    
                }
                else
                {
                    let arr = NSArray()
                    childDict["child"]=arr
//                    childDict.setObject(arr, forKey:"child" as String)
                    parentArr.add(childDict)
                }
            }
        }
        print("parent array = \(parentArr)")
    }
    
    func iteratechild(child:[DataObject]) -> NSMutableArray
    {
        let childDict = NSMutableDictionary()
        childArr = NSMutableArray()
        for item in child
        {
            childArr.addObjects(from:([item.name as Any]))
        }
        return childArr
    }
    
    
    func extractChild(child:[DataObject],Px:Int, Py: inout Int)
    {
     
        var y=Py+30
        var x=Px+10
        for index in 0...child.count-1
        {
            
            let parent = child[index]
            let parentBtn = UIButton()
            print("\(parent.name) x=\(x) y=\(y)")
            parentBtn.setTitle("\(parent.name)", for: .normal)
            parentBtn.setTitleColor(UIColor.blue, for: .normal)
            parentBtn.frame = CGRect(x: x, y: y, width: 100, height: 20)
            //            parentBtn.addTarget(self, action: #selector(myClass.pressed(_:)), forControlEvents: .TouchUpInside)
            self.view.addSubview(parentBtn)
            let subchild:[DataObject] = parent.children
            
            if(subchild.count != 0)
            {
//                childArr.add(parent.name)
                x=x+10
                extractChild(child: subchild, Px: x, Py: &y)
            }
            else
            {
                parentArr.add(parent.name)
                y=y+30
                Py=y
            }
        }
    
    }
    
    func setupTreeView() -> Void {
        treeView = RATreeView(frame: view.bounds)
        treeView.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        treeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        treeView.delegate = self;
        treeView.dataSource = self;
        treeView.treeFooterView = UIView()
        treeView.backgroundColor = .clear
        view.addSubview(treeView)
    }
    
    func updateNavigationBarButtons() -> Void {
        let systemItem = treeView.isEditing ? UIBarButtonSystemItem.done : UIBarButtonSystemItem.edit;
        self.editButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(ManageVC.editButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
    
    @objc func editButtonTapped(_ sender: AnyObject) -> Void {
        
        let walls = DataObject(name: "wills")
        data.append(walls)
        
        //        let newItem = DataObject(name: "wills")
        //        treeView.insertItems(at: IndexSet(integer:0), inParent: newItem, with: RATreeViewRowAnimationNone);
        treeView.reloadData()
        
        
    }
    
    
    //MARK: RATreeView data source
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? DataObject {
            return item.children.count
        } else {
            return self.data.count
        }
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? DataObject {
            return item.children[index]
        } else {
            
            return data[index] as AnyObject
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        let item = item as! DataObject
        
        let level = treeView.levelForCell(forItem: item)
        let detailsText = "Number of children \(item.children.count)"
        cell.selectionStyle = .none
        cell.setup(withTitle: item.name, detailsText: detailsText, level: level, additionalButtonHidden: false)
        cell.additionButtonActionBlock = { [weak treeView] cell in
            guard let treeView = treeView else {
                return;
            }
            let item = treeView.item(for: cell) as! DataObject
            let newItem = DataObject(name: "Added value")
            item.addChild(newItem)
            treeView.insertItems(at: IndexSet(integer: item.children.count-1), inParent: item, with: RATreeViewRowAnimationNone);
            treeView.reloadRows(forItems: [item], with: RATreeViewRowAnimationNone)
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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController.isKind(of: ManageVC.self as AnyClass)
        {
            let viewController = tabBarController.viewControllers?[1] as! StoreItemVC
            viewController.data = self.data
        }
        
//        if viewController.isKind(of: firstsubsecoundViewController.self as AnyClass) {
//            let viewController  = tabBarController.viewControllers?[1] as! secondViewController
//            viewController.arrayData = self.arrayName
//        }
//        
        return true
    }
}



private extension ManageVC {
    
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
    
}

