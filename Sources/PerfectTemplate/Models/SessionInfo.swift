//
//  SessionInfo.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 3/27/19.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer

// when handlers further down need the request you can pass it along. this is not necessary though
typealias RequestSession = (request: HTTPRequest, session: SessionInfo)

struct SessionInfo: Codable {
    //...could be an authentication token, etc.
    let id: String
}

// intermediate handler for /api
func checkSession(request: HTTPRequest) throws -> RequestSession {
    // one would check the request to make sure it's authorized
    let sessionInfo: SessionInfo = try request.decode() // will throw if request does not include id
    return (request, sessionInfo)
}
