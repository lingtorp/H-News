//
//  Models.swift
//  H-News
//
//  Created by Alexander Lingtorp on 08/12/15.
//  Copyright © 2015 Lingtorp. All rights reserved.
//

/// A Story is something that comes up as a post on HN.
protocol Story {
    var id       : Int    { get } // A unique id of the Story
    var title    : String { get }
    var author   : String { get }
    var date     : NSDate { get }
    var read     : Bool   { get } // Has the user read this story
    var score    : Int    { get } // Number of upvotes
    var comments : Int    { get }
}

struct News: Story {
    let id       : Int
    let title    : String
    let author   : String
    let date     : NSDate
    let read     : Bool
    let score    : Int
    let comments : Int
    
    let url   : NSURL
}

struct Comment {
    let id    : Int
    let author: String
    let date  : NSDate
    let text  : String
    let offset: Int
}
