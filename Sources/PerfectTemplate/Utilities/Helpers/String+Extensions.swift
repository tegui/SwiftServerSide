//
//  String+Extensions.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 3/26/19.
//

import Foundation

extension String {
    
    func replacingLastOccurrenceOfString(_ searchString: String, with replacementString: String, caseSensitive: Bool = true) -> String {
        let options: String.CompareOptions = caseSensitive ? [.backwards, .caseInsensitive] : [.backwards]
        
        guard let range = self.range(of: searchString, options: options, range: nil, locale: nil) else {
            return self
        }
        
        return self.replacingCharacters(in: range, with: replacementString)
    }
    
    func typeOfRequest() -> RequestType {
        if let _ = Int(self) {
            return .singleGet
        } else if self == "/" {
            return .multiGet
        }
        
        return .errorInUrl
    }
}
