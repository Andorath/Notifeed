//
//  PostDateFormat.swift
//  Notifeed
//
//  Created by Marco Salafia on 04/10/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation

enum PostDateFormat
{
    case ISO8601
    case RFC822
}

extension NSDate
{
    class func dateFromString(swiftString: String, format: PostDateFormat) -> NSDate?
    {
        if swiftString.isEmpty
        {
            return nil
        }
        
        let string = swiftString as NSString
        
        switch format
        {
            //TODO: Non funziona in alcuni casi
            case .ISO8601:
                
                var s = string
                if string.hasSuffix(" 00:00")
                {
                    s = s.substringToIndex(s.length-6) + "GMT"
                }
                else if string.hasSuffix("+00:00")
                {
                    s = s.substringToIndex(s.length-6) + "GMT"
                }
                else if string.hasSuffix("Z")
                {
                    s = s.substringToIndex(s.length-1) + "GMT"
                }
                else if string.hasSuffix("+0000")
                {
                    s = s.substringToIndex(s.length-5) + "GMT"
                }
                
                if s.containsString(".")
                {
                    s = s.substringToIndex(s.length-7) + "GMT"
                }
                
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
                
                if let date = formatter.dateFromString(s as String)
                {
                    return NSDate(timeInterval:0, sinceDate:date)
                }
                else
                {
                    return nil
                }
         
        case .RFC822:
            
            var s  = string
            
            if string.hasSuffix("Z")
            {
                s = s.substringToIndex(s.length-1) + "GMT"
            }
            else if string.hasSuffix("+0000")
            {
                s = s.substringToIndex(s.length-5) + "GMT"
            }
            else if string.hasSuffix("+00:00")
            {
                s = s.substringToIndex(s.length-6) + "GMT"
            }
            
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
            
            if let date = formatter.dateFromString(s as String)
            {
               return NSDate(timeInterval:0, sinceDate:date)
            }
            else
            {
                return nil
            }
        }
    }
}