//
//  Feed.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation

class Post: NSObject
{
    var title: String = String()
    var postDescription: String = String()
    var link: String = String()
    var published: NSDate?
    var checked: Bool = false
    
    override var description: String {
        
        return "[Title: \(title), Description: \(postDescription), Link: \(link)]"
    }
    
    convenience init(title: String, link: String, postDescription: String, published: NSDate?)
    {
        self.init()
        self.title = title
        self.link = link
        self.postDescription = postDescription
        self.published = published
    }
    
    convenience init(title: String, link: String, postDescription: String)
    {
        self.init(title: title, link: link, postDescription: postDescription, published: nil)
    }
    
    convenience init(post: Post)
    {
        self.init()
        title = post.title
        postDescription = post.postDescription
        link = post.link
        published = post.published
    }
}

func == (left: Post, right: Post) -> Bool
{
    return left.title == right.title
}

func != (left: Post, right: Post) -> Bool
{
    return left.title != right.title
}