//
//  ViewState.swift
//  RemoteRecruit
//
//  A small, reusable enum that models the four UI states the brief asks
//  for: loading, loaded (with content), empty, and error. Driving the UI
//  from a single enum keeps invalid combinations (e.g. "loading + error")
//  unrepresentable.
//

import Foundation

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
