//
//  MasterViewController.swift
//  H-News
//
//  Created by Alexander Lingtorp on 27/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import UIKit
import SafariServices

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController?
    
    private var stories: [Story] = [] {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
    
    private let newsGenerator  = AsyncGenerator<Story>()
    private let newsDownloader = AsyncDownloader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.registerNib(UINib(nibName: "HNewsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Cell")
        newsGenerator.next(25, newsDownloader.fetchNextBatch, onFinish: updateDatasource)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            clearsSelectionOnViewWillAppear = false
            preferredContentSize = CGSize(width: 320.0, height: 600.0)
            navigationItem.rightBarButtonItem = nil // Hide detail btn on ipads
        }
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = controllers.last as? DetailViewController
        }
    }
    
    @IBAction func settingsButtonPressed(sender: UIBarButtonItem) {
        presentViewController(SettingsViewController(), animated: true, completion: nil)
    }
}

// MARK: - Paging
extension MasterViewController {
    private func updateDatasource(items: [Story]) {
        stories += items
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 1) - 1 {
            async { self.newsGenerator.next(15, self.newsDownloader.fetchNextBatch, onFinish: self.updateDatasource) }
        }
    }
}

// MARK: - UITableViewDatasource
extension MasterViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? HNewsTableViewCell else { return UITableViewCell() }
        guard let news = stories[indexPath.row] as? News else { return UITableViewCell() }
        
        cell.story = news
        cell.secondTrigger = 0.5
        
        // Add to Reading Pile gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.readingPileImage, color: UIColor.whiteColor(), mode: .Exit, state: .State1,
            completionBlock: { (cell, state, mode) -> Void in
                guard let cell = cell as? HNewsTableViewCell else { return }
                guard let news = cell.story as? News         else { return }
                HNewsReadingPile()?.addNews(news)
                ArticleTextExtractor().downloadArticle(news.url, newsID: news.id)
                self.stories = self.stories.filter { $0.id == news.id ? false : true }
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
}

// MARK: - UITableViewDelegate
extension MasterViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let news = stories[indexPath.row] as? News else { return }
        // TODO: Use Settings - Use SafariViewController or custom webview?
        // let safariVC = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
        performSegueWithIdentifier("webview", sender: news.url)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueID = segue.identifier else { return }
        
        switch segueID {
            case "webview":
                guard let webViewVC = segue.destinationViewController.childViewControllers.first as? HNewsWebViewController else { return }
                guard let url = sender as? NSURL else { return }
                webViewVC.url = url
            default: return
        }
    }
}
