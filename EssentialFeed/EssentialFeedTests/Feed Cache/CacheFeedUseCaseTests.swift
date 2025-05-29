//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 29.5.25..
//

import Foundation
import XCTest

class FeedStore {
    var deleteCasheFeedCount: Int = 0
    func deleteCacheFeed() {
        deleteCasheFeedCount += 1
    }
}

class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCashe_uponCreation() throws {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCasheFeedCount, 0)
    }
}
