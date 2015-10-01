//
//  FeedParser.swift 2.0
//  Notifeed
//
//  Versione più potente e versatile del parser precedente.
//
//  Created by Marco Salafia on 22/09/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation

enum FeedParserError: ErrorType
{
    case UnableToConnect
    case InvalidURL
    case UnknownFeedFormat
}

enum FeedType: String
{
    case RSS2 = "rss"
    case Atom = "feed"
    case RSS1 = "rdf:RDF"
    case Unknown = "unknown"
    
}

class FeedParser: NSObject, NSXMLParserDelegate
{
    private var parser: NSXMLParser = NSXMLParser()
    
    var currentFeedType: FeedType = .Unknown
    
    var isItemTag : Bool = false
    var selectedIndex : Int? = nil
    var postArray: [Post] = []
    var currentPost = Post()
    
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
        
        if currentFeedType == .Unknown
        {
            throw FeedParserError.UnknownFeedFormat
        }
        
        return postArray
    }
    
    // MARK: - NSXMLParser
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
            currentPost.eName = elementName
            
            //Determiniamo il tipo di Feed
            if elementName == FeedType.RSS2.rawValue {self.currentFeedType = .RSS2; return}
            if elementName == FeedType.Atom.rawValue {self.currentFeedType = .Atom; return}
            if elementName == FeedType.RSS1.rawValue {self.currentFeedType = .RSS1; return}
            
            //Determiniamo il tipo di elemento (tag) che stimao analizzando
            if self.currentFeedType == .RSS2 { self.parseStartOfRSS2Element(elementName) }
            else if self.currentFeedType == .Atom { self.parseStartOfAtomElement(elementName) }
            else if self.currentFeedType == .RSS1 { self.parseStartOfRSS2Element(elementName) } //Lo stesso di RSS2 dovrebbe funzionare
    }
    
    func parseStartOfRSS2Element(elementName: String)
    {
        if elementName == "item"
        {
            isItemTag = true
        }
    }
    
    func parseStartOfAtomElement(elementName: String)
    {
        if elementName == "entry"
        {
            isItemTag = true
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if self.currentFeedType == .RSS2 { self.parseEndOfRSS2Element(elementName) }
        else if self.currentFeedType == .Atom { self.parseEndOfAtomElement(elementName) }
        else if self.currentFeedType == .RSS1 { self.parseEndOfRSS2Element(elementName) } //Lo stesso di RSS2 dovrebbe funzionare
    }
    
    func parseEndOfRSS2Element(elementName: String)
    {
        if elementName == "item" { acceptCurrentPost() }
    }
    
    func parseEndOfAtomElement(elementName: String)
    {
        if elementName == "entry" { acceptCurrentPost() }
    }
    
    func acceptCurrentPost()
    {
        let newPost: Post = Post(post: currentPost)
        self.postArray.append(newPost)
        currentPost = Post()
        isItemTag = false
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if(!data.isEmpty)
        {
            if self.currentFeedType == .RSS2 { self.checkRSS2FoundCharacters(data) }
            else if self.currentFeedType == .Atom { self.checkAtomFoundCharacters(data) }
            else if self.currentFeedType == .RSS2 { self.checkRSS2FoundCharacters(data) }
        }
    }
    
    func checkRSS2FoundCharacters(data: String)
    {
        if currentPost.eName == "title" && isItemTag { currentPost.title += data }
        else if currentPost.eName == "description" { currentPost.postDescription += data }
        else if currentPost.eName == "link" { currentPost.link = data }
    }
    
    func checkAtomFoundCharacters(data: String)
    {
        if currentPost.eName == "title" && isItemTag { currentPost.title += data }
        else if currentPost.eName == "link" { currentPost.link = data }
        else if currentPost.eName == "summary" { currentPost.postDescription += data }
    }
    
    
    
    
    
}