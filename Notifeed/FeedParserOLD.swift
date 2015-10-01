//
//  FeedParser.swift
//  Notifeed
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation

enum FeedParserErrorOLD: ErrorType
{
    case UnableToConnect
    case InvalidURL
}

class FeedParserOLD: NSObject, NSXMLParserDelegate
{
    private var parser: NSXMLParser = NSXMLParser()
    
    var isItemTag : Bool = false
    var selectedIndex : Int? = nil
    var postArray: [Post] = []
    var post = Post()
    
    func parseLink(link: String) throws -> [Post]
    {
        postArray = []
        
        if let url = NSURL(string: link)
        {
            parser = NSXMLParser(contentsOfURL: url)!
            parser.delegate = self
            
            parser.parse()
        }
        
        if postArray.isEmpty
        {
            throw FeedParserError.InvalidURL
        }
        
        return postArray
    }
    
    // MARK: - NSXMLParser
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        post.eName = elementName
        if elementName == "item"
        {
            isItemTag = true
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if(!data.isEmpty)
        {
            if post.eName == "title" && isItemTag
            {
                post.title += " " + data
            }
            else if post.eName == "description"
            {
                post.postDescription += data
            }
            else if post.eName == "link"
            {
                post.link = data
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "item"
        {
            let newPost: Post = Post(post: post)
            self.postArray.append(newPost)
            post = Post()
            isItemTag = false
        }
    }
}