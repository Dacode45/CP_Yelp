//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Labuser on 2/7/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
   optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate : FiltersViewControllerDelegate?
    var categories : [[String:String]]!
    var switchStates : [Int:Bool]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        categories = yelpCategories()
        switchStates = [Int:Bool]()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        var filters = [String:AnyObject]()
        var selectedCategories = [String]()
        for (row,isSelected) in switchStates{
            if isSelected{
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        filters["categories"] = selectedCategories
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }
    func yelpCategories() -> [[String:String]]{
        if let path = NSBundle.mainBundle().pathForResource("categories", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path)
            {
                if let jsonResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                {
                    if let categories : NSArray = jsonResult[0] as? [NSDictionary]
                    {
                        // Do stuff
                        var toReturn = [[String:String]]()
                        for cat in categories{
                            var temp  = [String:String]()
                            temp["name"] = cat["title"] as? String
                            temp["code"] = cat["alias"] as? String
                            toReturn.append(temp)
                        }
                        return toReturn
                    }
                }
            }
        }
        return [["name":"None", "code":"none"]]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories != nil{
            return categories.count
        }else{
            return 0;
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        cell.switchLabel.text = categories[indexPath.row]["name"]
        cell.delegate = self
    
        cell.onSwitch.on = switchStates[indexPath.row] ?? false
        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switchStates[indexPath.row] = value
    }
}
