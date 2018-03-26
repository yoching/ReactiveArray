//
//  ReactiveArray.swift
//  ReactiveArray
//
//  Created by Guido Marucci Blas on 6/29/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Foundation

//
//  ReactiveArray.swift
//  WLXViewModel
//
//  Created by Guido Marucci Blas on 6/15/15.
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
        
        let appendCurrentElements = OperationProducer(_elements.map { ArrayOperation.Append(value: $0) })
        let forwardOperations = OperationProducer { (observer, dispoable) in self._signal.observe(observer) }
        
        return  appendCurrentElements.concat(forwardOperations)
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
                self.updateArray(operation: operation)
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
            update(element: newValue, atIndex: index)
        }
    }
    
    public func index(after i: Int) -> Int {
        guard i < endIndex else {
            fatalError("Cannot increment endIndex")
        }
        return i + 1
    }
    
    public func append(element: T) {
        let operation: ArrayOperation<T> = .Append(value: element)
        _sink.send(value: operation)
    }
    
    public func insert(newElement: T, atIndex index : Int) {
        let operation: ArrayOperation<T> = .Insert(value: newElement, atIndex: index)
        _sink.send(value: operation)
    }
    
    public func update(element: T, atIndex index: Int) {
        let operation: ArrayOperation<T> = .Update(value: element, atIndex: index)
        _sink.send(value: operation)
    }
    
    public func removeAtIndex(index:Int) {
        let operation: ArrayOperation<T> = .RemoveElement(atIndex: index)
        _sink.send(value: operation)
    }
    
    public func mirror<U>(transformer: @escaping (T) -> U) -> ReactiveArray<U> {
        return ReactiveArray<U>(producer: producer.map { $0.map(mapper: transformer) })
    }
    
    public func toArray() -> Array<T> {
        return _elements
    }
    
    private func updateArray(operation: ArrayOperation<T>) {
        switch operation {
        case .Append(let value):
            _elements.append(value)
            _mutableCount.value = _elements.count
        case .Insert(let value, let index):
            _elements.insert(value, at: index)
            _mutableCount.value = _elements.count
        case .Update(let value, let index):
            _elements[index] = value
        case .RemoveElement(let index):
            _elements.remove(at: index)
            _mutableCount.value = _elements.count
        }
    }
    
}
