//
//  DefaultHtmlResponse.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 4/3/19.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectLib

func getHTMLContent(with variation: String) -> String {
    return "<html><title>Hello, worldddd!</title><body>Hello, worlddd\(variation)</body></html>"
}

func handler(request: HTTPRequest, response: HTTPResponse) {
    
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: getHTMLContent(with: "klasdalksj"))
    response.appendBody(string: getHTMLContent(with: "klasdalksj"))
    
    response.completed()
}
