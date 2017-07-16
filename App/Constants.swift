//
//  Constants.swift
//
//

import Foundation
import UIKit

let Domain = "http://192.168.0.9:3000"

struct K {
    struct Session {
        static let AppNameForUserAgent = "TurbolinksApp"
    }
    
    struct NotificationCenter {
        static let hasDismissedForm = "dismissedForm"
    }
    
    struct URL {
        static let Tab1           = K.URL.urlFor("/")
        static let Tab2           = K.URL.urlFor("/about")
//        static let Tab3           = K.URL.urlFor("/firefox")
//        static let Tab4           = K.URL.urlFor("/safari")
//        static let Tab5           = K.URL.urlFor("/icecat")

        
        
        struct DefaultPrefix {
            static let Email = "mailto:"
            static let Tel = "tel:"
        }
        
        
        static func urlFor(_ string: String) -> Foundation.URL {
            let str = Domain + string
            let protocolSuffixRange = str.range(of: "://")
            var urlString = ""
            if let indexAfterProtocol = protocolSuffixRange?.upperBound {
                let range = indexAfterProtocol..<str.endIndex
                urlString = str.replacingOccurrences(of: "//", with: "/", range: range)
            } else {
                urlString = str.replacingOccurrences(of: "//", with: "/")
            }
            guard let URL = Foundation.URL(string: urlString) else {
                debugPrint("ERROR:", "Not valid URL:", urlString)
                return Foundation.URL(string: Domain)!
            }
            return URL
        }
    }
}
