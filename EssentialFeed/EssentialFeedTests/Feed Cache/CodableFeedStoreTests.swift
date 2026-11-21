//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 2. 10. 2025..
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

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
    
    func test_retreive_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retreival")
        var retrivedFirstResult: RetriveCachedFeedResult?
        var retrivedSecondResult: RetriveCachedFeedResult?
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    retrivedFirstResult = firstResult
                    retrivedSecondResult = secondResult
                default :
                    XCTFail("Expected empty result, got \(firstResult), \(secondResult) instead.")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrivedFirstResult, .empty)
        XCTAssertEqual(retrivedSecondResult, .empty)
        XCTAssertEqual(retrivedFirstResult, retrivedSecondResult)
    }
    
    func test_retreiveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().localItems
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retreival")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected the feed to be inserted successfully!")
            sut.retrieve { retreiveResult in
                switch retreiveResult {
                case let .found(retreivedFeed, retreivedTimestamp):
                    XCTAssertEqual(retreivedFeed, feed)
                    XCTAssertEqual(retreivedTimestamp, timestamp)
                default :
                    XCTFail("Expected found result, fith feed \(feed) and timestamp \(timestamp), got \(retreiveResult) instead.")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
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
