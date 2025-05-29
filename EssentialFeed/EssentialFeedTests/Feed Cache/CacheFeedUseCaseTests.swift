//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 29.5.25..
//

import Foundation
import XCTest
@testable import EssentialFeed

class FeedStore {
    var deleteCasheFeedCount: Int = 0
    
    func deleteCachedFeed() {
        deleteCasheFeedCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    public init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCashe_uponCreation() throws {
        let store = FeedStore()
        _ = makeSUT(store: store)
        XCTAssertEqual(store.deleteCasheFeedCount, 0)
    }
    
    func test_save_requestsCasheDeletion() throws {
        let store = FeedStore()
        let sut = makeSUT(store: store)
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        XCTAssertEqual(store.deleteCasheFeedCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(store: FeedStore = FeedStore()) -> LocalFeedLoader {
       return LocalFeedLoader(store: store)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "Title 1", location: "Content 1", imageURL: self.anyURL())
    }
}
