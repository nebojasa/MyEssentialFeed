//
//  CasheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 9.2.25..
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCashedFeedCallCount = 0
    
    func deleteCashedFeed() {
        deleteCashedFeedCallCount += 1
    }
}

class LocaleFeedLoader {
    private let store: FeedStore
    
    public init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCashedFeed()
    }
}

class CasheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocaleFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCashedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = FeedStore()
        let sut = LocaleFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCashedFeedCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any string", location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "https://www.any-URL.com")!
    }
}

