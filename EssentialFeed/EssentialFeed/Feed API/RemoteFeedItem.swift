//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Nebojša Gujaničić on 14. 7. 2025..
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
