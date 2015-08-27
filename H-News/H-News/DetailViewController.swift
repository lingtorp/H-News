//
//  DetailViewController.swift
//  H-News
//
//  Created by Alexander Lingtorp on 27/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController: UITableViewController {
    
    private var notiToken: NotificationToken?
    private var news: [News] = HNewsReadingPile()?.fetchAllNews() ?? []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Observe Realm Notifications
        notiToken = HNewsReadingPile()?.realm?.addNotificationBlock { notification, realm in
            self.news = HNewsReadingPile()?.fetchAllNews() ?? []
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        tableView.registerNib(UINib(nibName: "HNewsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDatasource
extension DetailViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? HNewsTableViewCell else { return UITableViewCell() }
        cell.story = news[indexPath.row]
        cell.secondTrigger = 0.5
        
        // Remove from Reading Pile gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.readingPileImage, color: UIColor.redColor(), mode: .Exit, state: .State1,
            completionBlock: { (cell, state, mode) -> Void in
                guard let cell = cell as? HNewsTableViewCell else { return }
                guard let news = cell.story as? News         else { return }
                HNewsReadingPile()?.removeNews(news.id)
                self.news = self.news.filter { $0.id == news.id ? false : true }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        })
        
        // Upvote story gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.upvoteImage, color: UIColor.whiteColor(), mode: .Switch, state: .State3,
            completionBlock: { (cell, state, mode) -> Void in

        })
        
        // Read comments gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.commentImage, color: UIColor.whiteColor(), mode: .Switch, state: .State4,
            completionBlock: { (cell, state, mode) -> Void in
        
        })
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HNewsReadingPile()?.newsCount() ?? 0
    }
}

// MARK: - UITableViewDelegate
extension DetailViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Try to fetch the downloaded data from the Reading Pile
        // Then load that into the webview otherwise just load the url.
        // Will also need to check if the downloaded version is still valid somehow.
        if let downloadedHTML = HNewsReadingPile()?.html(news[indexPath.row]) {
            performSegueWithIdentifier("webview", sender: downloadedHTML)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueID = segue.identifier else { return }
        
        switch segueID {
        case "webView":
            guard let webViewVC = segue.destinationViewController.childViewControllers.first as? HNewsWebViewController else { return }
            guard let data = sender as? NSData else { return }
            webViewVC.data = data
        default: return
        }
    }
}