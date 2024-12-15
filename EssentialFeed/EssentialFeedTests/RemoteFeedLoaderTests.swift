//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 14.12.24..
//

import XCTest

class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!
        _ = RemoteFeedLoader(url: url, client: client)
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        // Given
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        // When
        sut.load()
        // Then
        XCTAssertEqual(client.requestedURL, url)
    }
}
