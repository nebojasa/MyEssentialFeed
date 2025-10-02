//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 2. 10. 2025..
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_retreive_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retreival")
        var retrivedResult: RetriveCachedFeedResult?
        
        sut.retrieve { result in
            switch result {
            case .empty:
                retrivedResult = result
            default :
                XCTFail("Expected empty result, got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrivedResult, .empty)
    }
}

extension RetriveCachedFeedResult: @retroactive Equatable {
    public static func == (lhs: RetriveCachedFeedResult, rhs: RetriveCachedFeedResult) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.found(feed: let feed, timestamp: let timestamp), .found(feed: let feed2, timestamp: let timestamp2)):
            return feed == feed2 && timestamp == timestamp2
        default:
            return false
        }
    }
}
