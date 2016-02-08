//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

    var businesses: [Business]!{
        didSet{
            tableView.reloadData()
        }
    }
    var selectedBusiness : Business?
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var searchBar : UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar(frame: CGRectMake(-5.0, 0.0, 300.0, 44.0))
        searchBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        let searchBarView = UIView(frame: CGRectMake(0.0, 0.0, 310.0, 44.0))
     
        searchBar.delegate = self
        searchBarView.addSubview(searchBar)
        self.navigationItem.titleView = searchBarView
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        if !isMoreDataLoading{
            reloadData()
        }
        

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isMoreDataLoading{
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging){
                
                
                // Code to load more results
                loadMoreData()
            }
            
        }
    }
    
    func reloadData(){
        isMoreDataLoading = true
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
        
        Business.searchWithTerm(searchBar.text!, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
        })
    }
    
    func loadMoreData(){
        isMoreDataLoading = true
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
        
        Business.searchWithTerm(searchBar.text!, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses.appendContentsOf(businesses)
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
        })

    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        reloadData()
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let navigationController = segue.destinationViewController as? UINavigationController {
            if let filtersViewController = navigationController.topViewController as? FiltersViewController{
                
                filtersViewController.delegate = self
            }else if let businessCellViewController = navigationController.topViewController as? BusinessCellViewController{
                businessCellViewController.business = businesses[(tableView.indexPathForSelectedRow?.row)!]
                print("here2")
            }
        }
        print("here3")
        
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as![String]
        
        Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals:nil, offset: nil){
            (businesses:[Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        NSLog("did select and the text is \(cell?.textLabel?.text)")
        selectedBusiness = businesses[indexPath.row]
        print("here1")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil{
            return businesses!.count
        }else{
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessViewCell
        cell.business = businesses[indexPath.row]
        
        return cell
    }
}
