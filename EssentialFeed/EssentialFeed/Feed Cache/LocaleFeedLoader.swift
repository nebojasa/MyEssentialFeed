//
//  LocaleFeedLoader.swift
//  EssentialFeed
//
//  Created by Nebojša Gujaničić on 11. 7. 2025..
//

import Foundation

public final class LocaleFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCashedFeed { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                cache(items: items, with: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: currentDate()) { [weak self] casheInsertionError in
            guard self != nil else { return }
            completion(casheInsertionError)
        }
    }
}
