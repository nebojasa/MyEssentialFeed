//
//  CasheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 9.2.25..
//

import XCTest

class FeedStore {
    var deleteCashedFeedCallCount = 0
}

class LocaleFeedLoader {
    private let store: FeedStore
    
    public init(store: FeedStore) {
        self.store = store
    }
}

class CasheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocaleFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCashedFeedCallCount, 0)
    }
}

