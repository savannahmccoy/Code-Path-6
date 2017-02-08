//
//  UserViewController.swift
//  TumblrClientApp
//
//  Created by A on 1/31/17.
//  Copyright © 2017 SVM. All rights reserved.
//

import UIKit
import AFNetworking

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var posts: [NSDictionary] = []
    

    override func viewDidLoad() {
      
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        
        // OLD SWIFT SYNTAX : refreshControl.addTarget(self, action: #selector(refreshControlAction (_refreshControl:)), for: UIControlEvents.valueChanged)
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)

        tableView.insertSubview(refreshControl, at: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 240;

        
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                            print("responseDictionary: \(responseDictionary)")
                            
                            // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                            // This is how we get the 'response' field
                            let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                            
                            // This is where you will store the returned array of posts in your posts property
                            self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                            
                            
                            self.tableView.reloadData()
                    }
                    
                }
        })
        task.resume()
        
    }
    
    
    // ------------------------ PULL TO REFRESH ---------------------------
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        // ... Create the URLRequest `myRequest` ...
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photocell") as! PhotosTableViewCell
        let post = posts[indexPath.row]
        
        if let photos = post["photos"] as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                cell.PhotoView.setImageWith(imageUrl)
            } else {
                
            }
        } else {
            
        }
        return cell
        
    } // returns nil if cell is not visible or index path is out of range
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // -------------------------- PREPARE FOR SEGUE -------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        let vc = segue.destination as! PhotoDetailsViewController
        
        var indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        
        let post = posts[indexPath.row]

        
        if let photos = post["photos"] as? [NSDictionary] {
            
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            
            if let imageUrl = NSURL(string: imageUrlString!) {
                vc.photoURL = imageUrl
            }
        }
        
    }

  

}
