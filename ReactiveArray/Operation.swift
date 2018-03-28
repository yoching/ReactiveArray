//
//  Operation.swift
//  ReactiveArray
//
//  Created by Guido Marucci Blas on 7/1/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Foundation

public enum ArrayOperation<T>: CustomDebugStringConvertible {
    
    case append(value: T)
    case insert(value: T, at: Int)
    case update(value: T, at: Int)
    case remove(at: Int)
    
    public func map<U>(_ mapper: (T) -> U) -> ArrayOperation<U> {
        let result: ArrayOperation<U>
        switch self {
        case .append(let value):
            result = ArrayOperation<U>.append(value: mapper(value))
        case .insert(let value, let index):
            result = ArrayOperation<U>.insert(value: mapper(value), at: index)
        case .update(let value, let index):
            result = ArrayOperation<U>.update(value: mapper(value), at: index)
        case .remove(let index):
            result = ArrayOperation<U>.remove(at: index)
        }
        return result
    }
    
    public var debugDescription: String {
        let description: String
        switch self {
        case .append(let value):
            description = ".append(value:\(value))"
        case .insert(let value, let index):
            description = ".insert(value: \(value), at:\(index))"
        case .update(let value, let index):
            description = ".update(value: \(value), at:\(index))"
        case .remove(let index):
            description = ".remove(at:\(index))"
        }
        return description
    }
    
    public var value: T? {
        switch self {
        case .append(let value):
            return value
        case .insert(let value, _):
            return value
        case .update(let value, _):
            return value
        default:
            return Optional.none
        }
    }
    
}

public func ==<T: Equatable>(lhs: ArrayOperation<T>, rhs: ArrayOperation<T>) -> Bool {
    switch (lhs, rhs) {
    case (.append(let leftValue), .append(let rightValue)):
        return leftValue == rightValue
    case (.insert(let leftValue, let leftIndex), .insert(let rightValue, let rightIndex)):
        return leftIndex == rightIndex && leftValue == rightValue
    case (.update(let leftValue, let leftIndex), .update(let rightValue, let rightIndex)):
        return leftIndex == rightIndex && leftValue == rightValue
    case (.remove(let leftIndex), .remove(let rightIndex)):
        return leftIndex == rightIndex
    default:
        return false
    }
}

// WTF!!! Again this is needed because the compiler is super stupid!
public func !=<T: Equatable>(lhs: ArrayOperation<T>, rhs: ArrayOperation<T>) -> Bool {
    return !(lhs == rhs)
}

// This is needed because somehow the compiler does not realize
// that when T is equatable it can compare an array of operations.
public func ==<T: Equatable>(lhs: [ArrayOperation<T>], rhs: [ArrayOperation<T>]) -> Bool {
    let areEqual: () -> Bool = {
        for i in lhs.indices {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
    return lhs.count == rhs.count && areEqual()
}
