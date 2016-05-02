struct Colors {
    
    // Application color palette
    /// White means 'unexplored', 'new'
    static let white = UIColor(red: 214, green: 214, blue: 214, alpha: 0.8)
    
    /// Peach means 'tap me', 'user-interaction', 'use me', main theme color
    static let peach = UIColor(red: 255/255, green: 120/255, blue: 65/255, alpha: 1)
    
    static let yellow = UIColor(red: 252/255, green: 190/255, blue: 50/255, alpha: 1)
    
    static let blue = UIColor(red: 0, green: 78/255, blue: 102/255, alpha: 1)
    
    static let hackerNews = UIColor(red: 255/255, green: 127/255, blue: 0/255, alpha: 1)
    
    /// Default background color
    static let gray = UIColor.darkGrayColor()
    
    /// Signals a success
    static let success = UIColor.greenColor()
    
    /// Signals a failure
    static let failure = UIColor.redColor()
    
    /// Used for texts and UI elements which will appear on the default bg color
    static let lightGray = UIColor.grayColor()
}
