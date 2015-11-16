//
//  MasterViewController.swift
//  H-News
//
//  Created by Alexander Lingtorp on 27/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController?
    
    private var stories: [Story] = [] {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }
    
    private let newsGenerator  = AsyncGenerator<Story>()
    private let newsDownloader = AsyncDownloader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.registerNib(UINib(nibName: "HNewsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: HNewsTableViewCell.cellID)
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
    
    @IBAction func didRefreshFeed(sender: UIRefreshControl) {
        newsGenerator.reset()
        newsDownloader.reset()
        stories.removeAll()
        newsGenerator.next(25, newsDownloader.fetchNextBatch, onFinish: updateDatasource)
    }
}

// MARK: - Paging
extension MasterViewController {
    private func updateDatasource(items: [Story]) {
        stories += items
        refreshControl?.endRefreshing()
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
        guard let cell = tableView.dequeueReusableCellWithIdentifier(HNewsTableViewCell.cellID) as? HNewsTableViewCell else { return UITableViewCell() }
        guard let news = stories[indexPath.row] as? News else { return UITableViewCell() }
        
        cell.story = news
        cell.secondTrigger = 0.5
        
        // Add to Reading Pile gesture
        cell.setSwipeGestureWithView(HNewsTableViewCell.readingPileImage, color: UIColor.darkGrayColor(), mode: .Exit, state: .State1,
            completionBlock: { (cell, state, mode) -> Void in
                guard let cell = cell as? HNewsTableViewCell else { return }
                guard let news = cell.story as? News         else { return }
                HNewsReadingPile()?.addNews(news)
                async { self.downloadArticle(news.url, newsID: news.id) }
                self.stories = self.stories.filter { $0.id == news.id ? false : true }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        })
        
        return cell
    }
    
    private func downloadArticle(url: NSURL, newsID: Int) {
        let request = NSMutableURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, err) -> Void in
            guard let data = data else { return }
            HNewsReadingPile()?.save(data, newsID: newsID)
        }
        task.resume()
    }
}

// MARK: - UITableViewDelegate
extension MasterViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let news = stories[indexPath.row] as? News else { return }
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
