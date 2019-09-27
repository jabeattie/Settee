//
//  File.swift
//  
//
//  Created by James Beattie on 27/09/2019.
//

import Foundation

/**
 An operation to create and update documents in bulk.
 
 Example usage:
 
 ```
 let documents = [["hello":"world"], ["foo":"bar", "_id": "foobar", "_rev": "1-revision"]]
 let bulkDocs = PutBulkDocsOperation(databaseName: "exampleDB", documents: documents) { response, httpInfo, error in
    guard let response = response, httpInfo = httpInfo, error == nil
    else {
        //handle the error
        return
    }
 
    //handle success.
 }
 
 ```
 */
public class PutBulkDocsOperation : CouchDatabaseOperation, JSONOperation {
    
    public typealias Json = [[String: Any]]

    public let databaseName: String
    
    public let completionHandler: (([[String:Any]]?, HTTPInfo?, Error?) -> Void)?
    
    /**
     The documents that make up this request.
    */
    public let documents: [[String:Any]]
    
    /**
     If false, CouchDB will not assign documents new revision IDs. This option is normally
     used for replication with CouchDB.
    */
    public let newEdits: Bool?
    
    /**
    If true the commit mode for the request will be "All or Nothing" meaning that if one document
    fails to be created or updated, no documents will be commited to the database.
    */
    public let allOrNothing: Bool?
    
    /**
     Creates the operation
     
     - parameter databaseName: The name of the database where the documents should be created or updated.
     - parameter documents: The documents that should be saved to the server.
     - parameter newEdits: Should the server treat the request as new edits or save as is.
     - parameter allOrNothing: The commit mode for the database, if set to true, if one document fails
     to be inserted into the database, all other documents in the request will also not be inserted.
     - parameter completionHandler: Optional handler to call when the operation completes.
     */
    public init(databaseName: String,
                documents:[[String:Any]],
                newEdits: Bool? = nil,
                allOrNothing: Bool? = nil,
                completionHandler: (([[String:Any]]?, HTTPInfo?, Error?) -> Void)? = nil){
        self.databaseName = databaseName
        self.documents = documents
        self.newEdits = newEdits
        self.allOrNothing = allOrNothing
        self.completionHandler = completionHandler
    }
    
    public var endpoint: String {
        return "/\(databaseName)/_bulk_docs"
    }
    
    public func validate() -> Bool {
        return JSONSerialization.isValidJSONObject(documents)
    }
    
    
    private var jsonData: Data?
    
    public func serialise() throws {
        var request:[String: Any] = ["docs":documents]
        
        if let newEdits = newEdits {
            request["new_edits"] = newEdits
        }
        
        if let allOrNothing = allOrNothing {
            request["all_or_nothing"] = allOrNothing
        }
        
        jsonData = try JSONSerialization.data(withJSONObject: request);
    }
    
    public var data: Data? {
        return jsonData
    }
    
    public var method:String {
        return "POST"
    }
}
