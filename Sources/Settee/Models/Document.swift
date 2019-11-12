//
//  File.swift
//  
//
//  Created by James Beattie on 12/11/2019.
//

import Foundation

public protocol Document: Codable {
    var id: String { get }
    var revision: String { get }
    
    func toDictionary() -> [String: Any]
}
