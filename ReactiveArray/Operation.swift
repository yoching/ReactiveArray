//
//  Operation.swift
//  ReactiveArray
//
//  Created by Guido Marucci Blas on 7/1/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Foundation

public enum ArrayOperation<T>: CustomDebugStringConvertible {
    
    case Append(value: T)
    case Insert(value: T, atIndex: Int)
    case Update(value: T, atIndex: Int)
    case RemoveElement(atIndex: Int)
    
    public func map<U>(mapper: (T) -> U) -> ArrayOperation<U> {
        let result: ArrayOperation<U>
        switch self {
        case .Append(let value):
            result = ArrayOperation<U>.Append(value: mapper(value))
        case .Insert(let value, let index):
            result = ArrayOperation<U>.Insert(value: mapper(value), atIndex: index)
        case .Update(let value, let index):
            result = ArrayOperation<U>.Update(value: mapper(value), atIndex: index)
        case .RemoveElement(let index):
            result = ArrayOperation<U>.RemoveElement(atIndex: index)
        }
        return result
    }
    
    public var debugDescription: String {
        let description: String
        switch self {
        case .Append(let value):
            description = ".Append(value:\(value))"
        case .Insert(let value, let index):
            description = ".Insert(value: \(value), atIndex:\(index))"
        case .Update(let value, let index):
            description = ".Update(value: \(value), atIndex:\(index))"
        case .RemoveElement(let index):
            description = ".RemoveElement(atIndex:\(index))"
        }
        return description
    }
    
    public var value: T? {
        switch self {
        case .Append(let value):
            return value
        case .Insert(let value, _):
            return value
        case .Update(let value, _):
            return value
        default:
            return Optional.none
        }
    }
    
}

public func ==<T: Equatable>(lhs: ArrayOperation<T>, rhs: ArrayOperation<T>) -> Bool {
    switch (lhs, rhs) {
    case (.Append(let leftValue), .Append(let rightValue)):
        return leftValue == rightValue
    case (.Insert(let leftValue, let leftIndex), .Insert(let rightValue, let rightIndex)):
        return leftIndex == rightIndex && leftValue == rightValue
    case (.Update(let leftValue, let leftIndex), .Update(let rightValue, let rightIndex)):
        return leftIndex == rightIndex && leftValue == rightValue
    case (.RemoveElement(let leftIndex), .RemoveElement(let rightIndex)):
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
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
    return lhs.count == rhs.count && areEqual()
}
