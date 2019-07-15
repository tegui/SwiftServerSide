//
//  RequestHelper.swift
//  PerfectTemplate
//
//  Created by Julian Amortegui on 3/27/19.
//

import Foundation

enum Result<T, Error: Swift.Error> {
    case success(T)
    case failure(Error)
}

enum RequestError: Error {
    case unauthorized
    case requestFailed
    case invalidResponse
    case emptyResponse
    case existenceData
    case forbiddenData
    case internalError
    case invalidUser
    case invalidToken
    case invalidSessionToken
    case notFound
}

enum RequestType {
    case singleGet
    case multiGet
    case errorInUrl
}

