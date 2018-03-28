//
//  ReactiveArray.swift
//  ReactiveArray
//
//  Created by Guido Marucci Blas on 6/29/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public final class ReactiveArray<T>: Collection, MutableCollection, CustomDebugStringConvertible {
    
    public typealias OperationProducer = SignalProducer<ArrayOperation<T>, NoError>
    public typealias OperationSignal = Signal<ArrayOperation<T>, NoError>
    
    private var _elements: Array<T> = []
    
    private let (_signal, _sink) = OperationSignal.pipe()
    public var signal: OperationSignal {
        return _signal
    }
    
    public var producer: OperationProducer {
        
        let appendCurrentElements = OperationProducer(_elements.map { .append(value: $0) })
        let forwardOperations = OperationProducer { (observer, dispoable) in self._signal.observe(observer) }
        
        return appendCurrentElements.concat(forwardOperations)
    }
    
    private let _mutableCount: MutableProperty<Int>
    public let observableCount: Property<Int>
    
    public var isEmpty: Bool {
        return _elements.isEmpty
    }
    
    public var count: Int {
        return _elements.count
    }
    
    public var startIndex: Int {
        return _elements.startIndex
    }
    
    public var endIndex: Int {
        return _elements.endIndex
    }
    
    public var first: T? {
        return _elements.first
    }
    
    public var last: T? {
        let value: T?
        if _elements.count > 0 {
            value = _elements[_elements.count - 1]
        } else {
            value = Optional.none
        }
        return value
    }
    
    public var debugDescription: String {
        return _elements.debugDescription
    }
    
    public init(elements:[T]) {
        _elements = elements
        _mutableCount = MutableProperty(elements.count)
        observableCount = Property(_mutableCount)
        
        _signal.observe { [unowned self] event in
            if case .value(let operation) = event {
                self.updateArray(operation)
            }
        }

    }
    
    public convenience init(producer: OperationProducer) {
        self.init()
        
        producer.start(_sink)
    }
    
    public convenience init() {
        self.init(elements: [])
    }
    
    public subscript(index: Int) -> T {
        get {
            return _elements[index]
        }
        set(newValue) {
            update(newValue, at: index)
        }
    }
    
    public func index(after i: Int) -> Int {
        guard i < endIndex else {
            fatalError("Cannot increment endIndex")
        }
        return i + 1
    }
    
    public func append(_ element: T) {
        let operation: ArrayOperation<T> = .append(value: element)
        _sink.send(value: operation)
    }
    
    public func insert(_ newElement: T, at index : Int) {
        let operation: ArrayOperation<T> = .insert(value: newElement, at: index)
        _sink.send(value: operation)
    }
    
    public func update(_ element: T, at index: Int) {
        let operation: ArrayOperation<T> = .update(value: element, at: index)
        _sink.send(value: operation)
    }
    
    public func remove(at index: Int) {
        let operation: ArrayOperation<T> = .remove(at: index)
        _sink.send(value: operation)
    }
    
    public func mirror<U>(_ transformer: @escaping (T) -> U) -> ReactiveArray<U> {
        return ReactiveArray<U>(producer: producer.map { $0.map(transformer) })
    }
    
    public func toArray() -> Array<T> {
        return _elements
    }
    
    private func updateArray(_ operation: ArrayOperation<T>) {
        switch operation {
        case .append(let value):
            _elements.append(value)
            _mutableCount.value = _elements.count
        case .insert(let value, let index):
            _elements.insert(value, at: index)
            _mutableCount.value = _elements.count
        case .update(let value, let index):
            _elements[index] = value
        case .remove(let index):
            _elements.remove(at: index)
            _mutableCount.value = _elements.count
        }
    }
    
}
