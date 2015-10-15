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
    
    func getDateFormat() -> PostDateFormat
    {
        switch self
        {
            case .RSS2:
                return .RFC822
            
            case .Atom, .RSS1:
                return .ISO8601
            
            default:
                return .RFC822
        }
    }
}

class FeedParser: NSObject, NSXMLParserDelegate
{
    private var parser: NSXMLParser = NSXMLParser()
    
    var currentFeedType: FeedType = .Unknown
    
    var isItemTag : Bool = false
    var selectedIndex : Int? = nil
    var postArray: [Post] = []
    var currentPost = Post()
    var eName: String = ""
    
    func parseLink(link: String) throws -> [Post]
    {
        postArray = []
        
        if let url = NSURL(string: link)
        {
            let request = NSURLRequest(URL: url)
            var response: NSURLResponse? = NSURLResponse()
            
            guard let data = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) else
            {
                throw FeedParserError.UnableToConnect
            }
            parser = NSXMLParser(data: data)
            self.parser.delegate = self
            self.parser.parse()
            
            if currentFeedType == .Unknown
            {
                throw FeedParserError.UnknownFeedFormat
            }
            else if postArray.isEmpty
            {
                throw FeedParserError.InvalidURL
            }
        }
        else
        {
            throw FeedParserError.UnableToConnect
        }
        
        return postArray
    }
    
    // MARK: - NSXMLParser
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
            eName = elementName
            
            //Determiniamo il tipo di Feed
            if elementName == FeedType.RSS2.rawValue {self.currentFeedType = .RSS2; return}
            else if elementName == FeedType.Atom.rawValue {self.currentFeedType = .Atom; return}
            else if elementName == FeedType.RSS1.rawValue {self.currentFeedType = .RSS1; return}
            
            //Determiniamo il tipo di elemento (tag) che stimao analizzando
            if self.currentFeedType == .RSS2 { self.parseStartOfRSS2Element(elementName) }
            else if self.currentFeedType == .Atom { self.parseStartOfAtomElement(elementName, attributeDict: attributeDict) }
            else if self.currentFeedType == .RSS1 { self.parseStartOfRSS2Element(elementName) } //Lo stesso di RSS2 dovrebbe funzionare
            else { parser.abortParsing() }
    }
    
    func parseStartOfRSS2Element(elementName: String)
    {
        print("Element: \(elementName)")
        if elementName == "item"
        {
            isItemTag = true
        }
    }
    
    func parseStartOfAtomElement(elementName: String, attributeDict: [String : String])
    {
        if elementName == "entry"
        {
            isItemTag = true
        }
        else if elementName == "link"
        {
            currentPost.link = attributeDict["href"]!
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
        if eName == "title" && isItemTag { currentPost.title += data }
        else if eName == "description" { currentPost.postDescription += data }
        else if eName == "link" { currentPost.link = data }
        else if eName == "pubDate" && isItemTag { currentPost.published = NSDate.dateFromString(data, format: currentFeedType.getDateFormat())}
    }
    
    func checkAtomFoundCharacters(data: String)
    {
        if eName == "title" && isItemTag { currentPost.title += data }
        else if eName == "summary" ||
                eName == "subtitle" { currentPost.postDescription += data }
        else if eName == "updated" && isItemTag { currentPost.published = NSDate.dateFromString(data, format: currentFeedType.getDateFormat())}
    }
    
    // MARK: - Metodi supplementari
    
    func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError)
    {
        NSLog("ERRORE NELLA VALIDAZIONE!")
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError)
    {
        NSLog("ERRORE DURANTE IL PARSING!")
    }
    
    func parserDidStartDocument(parser: NSXMLParser)
    {
        NSLog("BEGIN PARSING...")
    }
    
    func parserDidEndDocument(parser: NSXMLParser)
    {
        NSLog("PARSING END.")
    }
    
}