//
//  FeedCacheTestHelpers.swift
//  EssentialFeed
//
//  Created by Nebojša Gujaničić on 14. 9. 2025..
//

import Foundation
import XCTest
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], localItems: [LocalFeedImage]) {
    let items = [uniqueImage(), uniqueImage()]
    let localFeedItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models: items, localItems: localFeedItems)
}

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any string", location: nil, url: anyURL())
}

extension Date {
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }

    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func minusFeedCacheMaxAge() -> Date {
       adding(days: -feedCacheMaxAgeInDays)
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
