//
//  Models.swift
//  H-News
//
//  Created by Alexander Lingtorp on 08/12/15.
//  Copyright © 2015 Lingtorp. All rights reserved.
//

protocol Story {
    var id    : Int    { get } // A unique id of the Story
    var title : String { get }
    var author: String { get }
    var date  : NSDate { get }
    var kids  : [Int]  { get } // Contains the ids of its descendents
}

struct News: Story {
    let id    : Int
    let title : String
    let author: String
    let date  : NSDate
    let kids  : [Int]       // These are the ids of the comments
    
    let url   : NSURL
    let isRead: Bool = false
    let score : Int
}

struct Comment: Story {
    let id    : Int
    let title : String
    let author: String
    let date  : NSDate
    let kids  : [Int]
    
    let text  : String
}

struct Ask: Story {
    let id    : Int
    let title : String
    let author: String
    let date  : NSDate
    let kids  : [Int]
    
    let text  : String
    let score : Int
}
