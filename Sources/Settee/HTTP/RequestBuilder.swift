//
//  File.swift
//  
//
//  Created by James Beattie on 27/09/2019.
//

import Foundation

// TODO rename to something that makes a little more swift sense.
/**
 Designates an operation which provides data to perform a HTTP Request.
 */
internal protocol HTTPRequestOperation   {

    /**
     The root of url, e.g. `example.cloudant.com`
     */
    var rootURL: URL { get }
    
    /**
     The path of the url e.g. `/exampledb/document1/`
     */
    var httpPath: String { get }
    /**
     The method to use for the HTTP request e.g. `GET`
     */
    var httpMethod: String { get }
    /**
     The query items to use for the request
     */
    var queryItems: [URLQueryItem] { get }
    
    /**
     The body of the HTTP request or `nil` if there is no data for the request.
     */
    var httpRequestBody: Data? { get }
    
    /**
     The content type of the HTTP request payload. This is guranteed to be called
     if and only if `httpRequestBody` is not `nil`
     */
    var httpContentType: String { get }
    
    /**
     Provides the `InterceptableSession` to use when making HTTP requests.
     */
    var session: InterceptableSession { get }
    
    /**
     A function that is called when the operation is completed.
     */
    func completeOperation()
    /**
     A function to process the response from a HTTP request.

     - parameter data: The data returned from the HTTP request or nil if there was an error.
     - parameter httpInfo: Information about the HTTP response.
     - parameter error: A type representing an error if one occurred or `nil`
     */
    func processResponse(data: Data?, httpInfo: HTTPInfo?, error: Error?);

    var isCancelled: Bool { get }

}

/**
 A class which builds `NSURLRequest` objects from `HTTPRequestOperation` objects.
 */
class OperationRequestBuilder {

    enum Error: Swift.Error {
        case URLGenerationFailed
    }

    /**
     The operation this builder will turn into a HTTP object.
     */
    let operation: HTTPRequestOperation

    /**
     Creates an OperationRequestBuilder instance.

     - parameter operation: the operation that the request will be built from.
     */
    init(operation: HTTPRequestOperation) {
        self.operation = operation
    }

    /**
     Builds the NSURLRequest from the operation in the property `operation`
     */
    func makeRequest() throws -> URLRequest {
        
        guard let components = NSURLComponents(url: operation.rootURL, resolvingAgainstBaseURL: false)
        else {
            throw Error.URLGenerationFailed
        }
        components.path = operation.httpPath
        var queryItems: [URLQueryItem] = []

        if let _ = components.queryItems {
            queryItems.append(contentsOf: components.queryItems!)
        }

        queryItems.append(contentsOf: operation.queryItems)
        components.queryItems = queryItems

        guard let url = components.url
        else {
            throw Error.URLGenerationFailed
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 10.0
        request.httpMethod = operation.httpMethod

        if let body = operation.httpRequestBody {
            request.httpBody = body
            request.setValue(operation.httpContentType, forHTTPHeaderField: "Content-Type")
        }

        return request

    }

}

