
/// A Story is something that comes up as a post on HN.
protocol Story {
    var id       : Int    { get } // A unique id of the Story
    var title    : String { get }
    var author   : String { get }
    var date     : Date { get }
    var read     : Bool   { get } // Has the user read this story
    var score    : Int    { get } // Number of upvotes
    var comments : Int    { get }
}

/// Represents all entries/items on HN except Ask:s and Comments.
struct News: Story {
    let id       : Int
    let title    : String
    let author   : String
    let date     : Date
    let read     : Bool
    let score    : Int
    let comments : Int
    
    let url   : URL
}

struct Ask: Story {
    let id       : Int
    let title    : String
    let author   : String
    let date     : Date
    let read     : Bool
    let score    : Int
    let comments : Int

    let question: String
}

struct Comment {
    let id    : Int
    let author: String
    let date  : Date
    let text  : String
    let offset: Int
}
