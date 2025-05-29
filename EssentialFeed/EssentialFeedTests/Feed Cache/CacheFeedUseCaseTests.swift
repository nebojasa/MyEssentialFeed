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
    var insertCallCount: Int = 0
    func deleteCachedFeed() {
        deleteCasheFeedCount += 1
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        
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
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCasheFeedCount, 0)
    }
    
    func test_save_requestsCasheDeletion() throws {
        let (sut, store) = makeSUT()
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        XCTAssertEqual(store.deleteCasheFeedCount, 1)
    }
    
    func test_save_doesNotRequestsCasheInsertation_onDeletionError() throws {
        let (sut, store) = makeSUT()
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items: items)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStore) {
        let store: FeedStore = .init()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "Title 1", location: "Content 1", imageURL: self.anyURL())
    }
}
