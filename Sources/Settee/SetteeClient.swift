//
//  File.swift
//  
//
//  Created by James Beattie on 27/09/2019.
//

import Foundation
import Dispatch

/**
 Configures an instance of CouchDBClient.
 */
public struct ClientConfiguration {
    /**
     Should the client back off when a 429 response is encountered. Backing off will result
     in the client retrying the request at a later time.
     */
    public var shouldBackOff: Bool
    /**
     The number of attempts the client should make to back off and get a successful response
     from server.

     - Note: The maximum is hard limited by the client to 10 retries.
     */
    public var backOffAttempts: UInt

    /**
     The initial value to use when backing off.

     - Remark: The client uses a doubling back off when a 429 reponse is encountered, so care is required when selecting
     the initial back off value and the number of attempts to back off and successfully retreive a response from the server.
     */
    public var initialBackOff:DispatchTimeInterval

    /**
     Creates an ClientConfiguration
     - parameter shouldBackOff: Should the client automatically back off.
     - parameter backOffAttempts: The number of attempts the client should make to back off and
     get a successful response. Default 3.
     - parameter initialBackOff: The time to wait before retrying when the first 429 response is received,
     this value will be doubled for each subsequent back off

     */
    public init(shouldBackOff: Bool, backOffAttempts: UInt = 3, initialBackOff: DispatchTimeInterval =  .milliseconds(250)){
        self.shouldBackOff = shouldBackOff
        self.backOffAttempts = backOffAttempts
        self.initialBackOff = initialBackOff
    }

}


/**
 Class for running operations against a CouchDB instance.
 */
public class SetteeClient {

    private let session: InterceptableSession
    private let queue: OperationQueue

    internal let username: String?
    internal let password: String?
    internal let rootURL: URL

    // The version number of swift-cloudant, as a string
    static let version = "0.0.1"

    /**
     Creates a CouchDBClient instance.

     - parameter url: url of the server to connect to.
     - parameter username: the username to use when authenticating.
     - parameter password: the password to use when authenticating.
     - parameter configuration: configuration options for the client.
     */
    public init(url: URL,
                username: String?,
                password: String?,
                configuration: ClientConfiguration = ClientConfiguration(shouldBackOff: false)) {
        self.rootURL = url
        self.username = username
        self.password = password
        queue = OperationQueue()

        let sessionConfiguration = InterceptableSessionConfiguration(shouldBackOff: configuration.shouldBackOff,
                                                                     backOffRetries: configuration.backOffAttempts,
                                                                     initialBackOff: configuration.initialBackOff,
                                                                     username: username,
                                                                     password: password)

        self.session = InterceptableSession(delegate: nil, configuration: sessionConfiguration)

    }

    /**
     Adds an operation to the queue to be executed.
     - parameter operation: the operation to add to the queue.
     - returns: An `Operation` instance which represents the executing
     `CouchOperation`
     */
    @discardableResult
    public func add(operation: CouchOperation) -> Operation {
        let cOp = Operation(couchOperation: operation)
        self.add(operation: cOp)
        return cOp
    }

    /**
     Adds an operation to the queue to be executed.
     - parameter operation: the operation to add to the queue.
     */
    func add(operation: Operation) {
        operation.mSession = self.session
        operation.rootURL = self.rootURL
        queue.addOperation(operation)
    }

}
