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
        sut.load { _ in }
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // Given
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        // When
        sut.load { _ in }
        sut.load { _ in }
        // Then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversAnErrorOnClientError() {
        // Given
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        expect(sut, toCompleteWithError: .conectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversAnErrorOnNon200HTTPResponse() {
        // Given
        let (sut,client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversAnErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWithError error: RemoteFeedLoader.Error,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(
            from url: URL,
            completion: @escaping (HTTPClientResult) -> Void
        ) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(
            withStatusCode code: Int = 0,
            data: Data = Data(),
            at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
