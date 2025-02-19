//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Nebojša Gujaničić on 3.1.25..
//
import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
