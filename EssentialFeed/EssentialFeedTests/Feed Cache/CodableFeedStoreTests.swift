//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 2. 10. 2025..
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return  feed.map(\.local)
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retreive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
    
    func test_retreive_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localItems
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retreival")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected the feed to be inserted successfully!")
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFound), .found(secondFound)):
                        XCTAssertEqual(firstFound.feed, feed)
                        XCTAssertEqual(firstFound.timestamp, timestamp)
                        
                        XCTAssertEqual(secondFound.feed, feed)
                        XCTAssertEqual(secondFound.timestamp, timestamp)
                    default :
                        XCTFail("Expected retreiving twice from non empty cache to deliver same found result with feed \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testsSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testsSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of:self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testsSpecificStoreURL())
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
