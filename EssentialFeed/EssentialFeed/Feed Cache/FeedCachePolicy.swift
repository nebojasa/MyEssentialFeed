//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Nebojša Gujaničić on 26. 9. 2025..
//
import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCachedAgeInDays: Int {
        7
    }
    
    private init() {}

    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCachedAge = calendar.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else { return false }
        return date < maxCachedAge
    }
}
