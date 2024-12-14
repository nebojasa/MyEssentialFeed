//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 14.12.24..
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    var requestedURL: URL?
    
    private init() {}
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    var client: HTTPClient!
    var sut: RemoteFeedLoader!
    
    override func setUp() {
        super.setUp()
        client = HTTPClient.shared
        sut = RemoteFeedLoader()
    }
    
    override func tearDown() {
        super.tearDown()
        client = nil
        sut = nil
    }
    
    func test_doesNotRequestDataFromURL() {
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        // Given
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        // When
        sut.load()
        // Then
        XCTAssertNotNil(client.requestedURL)
    }
}
