//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 14.12.24..
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_doesNotRequestDataFromURL() {
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        // Given
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        // When
        sut.load()
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // Given
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        // When
        sut.load()
        sut.load()
        // Then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversAnErrorOnClientError() {
        // Given
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        // When
        
        // Than
        XCTAssertEqual(capturedErrors, [.conectivity])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private var messages = [(url: URL, compltion: (Error) -> Void)]()
        
        func get(
            from url: URL,
            completion: @escaping (Error) -> Void
        ) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].compltion(error)
        }
    }

}
