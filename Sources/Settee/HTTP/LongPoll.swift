//
//  File.swift
//  
//
//  Created by James Beattie on 12/11/2019.
//

import Foundation

enum LongPollError: Error {
    case incorrectlyFormattedUrl
    case httpError
}

protocol LongPollingDelegate: class {
    func received(result: Result<Data, Error>)
}

public class LongPollingRequest {
    private weak var longPollDelegate: LongPollingDelegate?
    private var request: URLRequest?
    private let backgroundQueue: DispatchQueue = DispatchQueue.global(qos: .background)

    init(delegate: LongPollingDelegate) {
        longPollDelegate = delegate
    }

    public func poll(endpointUrl: String) throws {
        guard let url = URL(string: endpointUrl) else {
            throw LongPollError.incorrectlyFormattedUrl
        }
        request = URLRequest(url: url)
        poll()
    }

    private func poll() {
        backgroundQueue.async {
            self.longPoll()
        }
    }

    private func longPoll() {
        guard let request = request else { return }
        autoreleasepool {
            do {
                let session = URLSession.shared
                let task = session.dataTask(with: request) { [weak self] (data, _, error) in
                    if let data = data {
                        self?.longPollDelegate?.received(result: .success(data))
                        self?.poll()
                    } else if let error = error {
                        self?.longPollDelegate?.received(result: .failure(error))
                        self?.poll()
                    }
                }
                task.resume()
            }
        }
    }
}
