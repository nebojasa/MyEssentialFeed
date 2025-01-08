//
//  XCTestCase+MemoryLeakDetection.swift
//  EssentialFeedTests
//
//  Created by Nebojša Gujaničić on 8.1.25..
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been dealocated! Potential Memory leak.", file: file, line: line)
        }
    }
}
