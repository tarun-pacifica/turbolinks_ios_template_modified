//
//  Constants.swift
//  Stockland
//
//  Created by Mark Biegel on 6/1/17.
//

import Foundation
import UIKit

let Domain = "http://localhost:3000"

struct K {
    struct Session {
        static let AppNameForUserAgent = "TurbolinksApp"
    }
    
    struct NotificationCenter {
        static let hasDismissedForm = "dismissedForm"
    }
    
    struct URL {
        static let Tab1           = K.URL.urlFor("/")
        static let Tab2           = K.URL.urlFor("/google")
        static let Tab3           = K.URL.urlFor("/firefox")
        static let Tab4           = K.URL.urlFor("/safari")
        static let Tab5           = K.URL.urlFor("/icecat")

        
        
        struct DefaultPrefix {
            static let Email = "mailto:"
            static let Tel = "tel:"
        }
        
        
        static func urlFor(string: String) -> NSURL {
            let str = Domain + string
            let protocolSuffixRange = str.rangeOfString("://")
            var urlString = ""
            if let indexAfterProtocol = protocolSuffixRange?.endIndex {
                let range = indexAfterProtocol..<str.endIndex
                urlString = str.stringByReplacingOccurrencesOfString("//", withString: "/", range: range)
            } else {
                urlString = str.stringByReplacingOccurrencesOfString("//", withString: "/")
            }
            guard let URL = NSURL(string: urlString) else {
                debugPrint("ERROR:", "Not valid URL:", urlString)
                return NSURL()
            }
            return URL
        }
    }
}
