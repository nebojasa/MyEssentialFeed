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
        expect(sut, toRetreive: .empty)
    }
    
    func test_retreive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetreiveTwice: .empty)
    }
    
    func test_retreive_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localItems
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetreive: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retreive_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localItems
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetreiveTwice: .found(feed: feed, timestamp: timestamp))
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testsSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ cashe: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertation")
        sut.insert(cashe.feed, timestamp: cashe.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected the feed to be inserted successfully!", file: file, line: line)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetreive expectedResult: RetriveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for cache retreival")
        sut.retrieve { retreivedResult in
            switch (expectedResult, retreivedResult) {
            case (.empty, .empty):
                break
            case let (.found(expected), .found(retreived)):
                XCTAssertEqual(retreived.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retreived.timestamp, expected.timestamp, file: file, line: line)
            default :
                XCTFail("Expected to retreive \(expectedResult), got \(retreivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func expect(_ sut: CodableFeedStore, toRetreiveTwice expectedResult: RetriveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetreive: expectedResult, file: file, line: line)
        expect(sut, toRetreive: expectedResult, file: file, line: line)
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
