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
        sut.load { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])

    }
    
    func test_load_failsOnCacheRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        var recevedError: Error?
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case .failure(let error):
                recevedError = error
            default:
                XCTFail("Expected failure, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recevedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedImages: [FeedImage]?
        let exp = expectation(description: "Wait for load completion")

        sut.load { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected sucess, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        store.completeRetrievalWithEmptyCache()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedImages, [])
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
