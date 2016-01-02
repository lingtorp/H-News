//
//  HNewsTableViewCell.swift
//  H-News
//
//  Created by Alexander Lingtorp on 29/07/15.
//  Copyright (c) 2015 Lingtorp. All rights reserved.
//

import UIKit
import MCSwipeTableViewCell

class HNewsTableViewCell: MCSwipeTableViewCell {
    
    static let cellID = "Cell"
    
    static let trashImage       = UIImageView(image: UIImage(named: "UIButtonBarTrash"))
    static let readingPileImage = UIImageView(image: UIImage(named: "reading_list_icon"))
    static let upvoteImage      = UIImageView(image: UIImage(named: "upvote_arrow"))
    
    private static let dateCompsFormatter = NSDateComponentsFormatter()
    
    @IBOutlet var title: UILabel!
    @IBOutlet var commentsCount: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var url: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var time: UILabel!
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
    
            // Set selection color theme
            let view = UIView()
            view.backgroundColor = UIColor.orangeColor()
            selectedBackgroundView = view
            defaultColor = UIColor.darkGrayColor()
            
            // Setup NSDateFormatter
            HNewsTableViewCell.dateCompsFormatter.unitsStyle = .Short
            HNewsTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .DropAll
            HNewsTableViewCell.dateCompsFormatter.maximumUnitCount = 1

            title.text         = story.title
            commentsCount.text = "\(story.comments)"
            author.text        = story.author
            time.text          = HNewsTableViewCell.dateCompsFormatter.stringFromTimeInterval(-story.date.timeIntervalSinceNow)
            
            if story.read {
                title.textColor = UIColor.grayColor()
            }
            
            if let news = story as? News {
                url.text   = news.url.host
                score.text = "\(news.score)"
            }
            
            setNeedsDisplay()
        }
    }
}