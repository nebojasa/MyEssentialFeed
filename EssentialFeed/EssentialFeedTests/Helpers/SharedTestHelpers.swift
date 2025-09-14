//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Nebojša Gujaničić on 14. 9. 2025..
//
import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}
