//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Nebojša Gujaničić on 14. 7. 2025..
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetreival() {
        let (sut, store) = makeSUT()
        sut.load()
        XCTAssertEqual(store.receivedMessages, [.retrieve])

    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocaleFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocaleFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
}
