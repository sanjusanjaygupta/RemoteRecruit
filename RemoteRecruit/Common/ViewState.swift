//
//  ViewState.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 02/06/26.
//

import Foundation

// One enum to drive a screen, so we can't accidentally end up in an
// impossible combination like "loading and error at the same time".
enum ViewState<Value: Equatable>: Equatable {
    case loading
    case loaded(Value)
    case empty
    case failed(message: String)

    var value: Value? {
        if case let .loaded(value) = self { return value }
        return nil
    }
}
