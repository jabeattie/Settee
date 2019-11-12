//
//  File.swift
//  
//
//  Created by James Beattie on 27/09/2019.
//

import Foundation

/**
 Contains HTTP response information.
 */
public struct HTTPInfo {
    /**
     The status code of the HTTP request.
     */
    public let statusCode: Int
    /**
     The headers that were returned by the server.
     */
    public let headers: [String: String]
}

/**
 Executes a `HTTPRequestOperation`'s HTTP request.
 */
class OperationRequestExecutor: InterceptableSessionDelegate {

    /**
     The HTTP task currently processing
     */
    var task: URLSessionTask?
    /**
     The operation which this OperationRequestExecutor is Executing.
     */
    let operation: HTTPRequestOperation
    
    var buffer: Data
    var response: HTTPURLResponse?
    /**
     Creates an OperationRequestExecutor.
     - parameter operation: The operation that this OperationRequestExecutor will execute
     */
    init(operation: HTTPRequestOperation) {
        self.operation = operation
        task = nil
        buffer = Data()
    }
    
    func received(data: Data) {
        // This class doesn't support streaming of data
        // so we buffer until the request completes
        // and then we will deliver it to the
        // operation in chunk.
        buffer.append(data)
    }
    
    func received(response: HTTPURLResponse) {
        // Store the response to deliver with the data when the task completes.
        self.response = response
    }
    
    func completed(error: Error?) {
        self.task = nil // allow task to be deallocated.
        
        // task has completed, handle the operation canceling etc.
        if self.operation.isCancelled {
            self.operation.completeOperation()
            return
        }
        
        let httpInfo: HTTPInfo?
        
        if let response = response {
                var headers: [String: String] = [:]
                for (key, value) in response.allHeaderFields {
                    headers["\(key)"] = "\(value)"
                }
                httpInfo = HTTPInfo(statusCode: response.statusCode, headers: headers)
        } else {
            httpInfo = nil
        }
        
        self.operation.processResponse(data: buffer, httpInfo: httpInfo, error: error)
        self.operation.completeOperation()

    }

    /**
     Executes the HTTP request for the operation held in the `operation` property
     */
    func executeRequest () {

        do {
            let builder = OperationRequestBuilder(operation: self.operation)
            let request = try builder.makeRequest()

            self.task = self.operation.session.dataTask(request: request, delegate: self)
            self.task?.resume()
        } catch {
            self.operation.processResponse(data: nil, httpInfo: nil, error: error)
            self.operation.completeOperation()
        }

    }

    /**
     Cancels the currently processing HTTP task.
     */
    func cancel() {
        if let task = task {
            task.cancel()
        }
    }

}
