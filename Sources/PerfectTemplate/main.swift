//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//    Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//
import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectSession
import PerfectSessionSQLite


struct Main {
    
    enum Config {
        static let hostName     = "localhost"
        static let portNumber   = 8181
    }
    
    static func run() throws -> () {
        SessionConfig.name =  "PerfectApi"
        SessionConfig.idle = 86400
        SessionConfig.cookieDomain = Config.hostName
        
        let sessionDriver = SessionMemoryDriver()
        
        let server = HTTPServer()
        
        server.setRequestFilters([sessionDriver.requestFilter])
        server.setResponseFilters([sessionDriver.responseFilter])
        server.serverPort = 8181
        server.addRoutes(PerfectRoutes.shared.basicRoutes)
        
        server.setResponseFilters([(try PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])
        
        try server.start()
    }
}

try Main.run()

