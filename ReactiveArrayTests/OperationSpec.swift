//
//  OperationSpec.swift
//  ReactiveArray
//
//  Created by Guido Marucci Blas on 7/2/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveArray
import ReactiveSwift

class OperationSpec: QuickSpec {

    override func spec() {

        var operation: ArrayOperation<Int>!
        
        describe("#map") {
            
            context("when the operation is an Append operation") {
                
                beforeEach {
                    operation = ArrayOperation.Append(value: 10)
                }
                
                it("maps the value to be appended") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == ArrayOperation.Append(value: 20)
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is an Insert operation") {
                
                beforeEach {
                    operation = ArrayOperation.Insert(value: 10, atIndex: 5)
                }
                
                it("maps the value to be inserted") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == ArrayOperation.Insert(value: 20, atIndex: 5)
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is an Update operation") {
                
                beforeEach {
                    operation = ArrayOperation.Update(value: 10, atIndex: 5)
                }
                
                it("maps the value to be updated") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == ArrayOperation.Update(value: 20, atIndex: 5)
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is a Delete operation") {
                
                beforeEach {
                    operation = ArrayOperation.RemoveElement(atIndex: 5)
                }
                
                it("does nothing") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == operation
                    expect(areEqual).to(beTrue())
                }
                
            }
            
        }
        
        describe("#value") {
        
            context("when the operation is an Append operation") {
                
                beforeEach {
                    operation = ArrayOperation.Append(value: 10)
                }
                
                it("returns the appended value") {
                    expect(operation.value).to(equal(10))
                }
                
            }
            
            context("when the operation is an Insert operation") {
                
                beforeEach {
                    operation = ArrayOperation.Insert(value: 10, atIndex: 5)
                }
                
                it("returns the inserted value") {
                    expect(operation.value).to(equal(10))
                }
                
            }
            
            context("when the operation is an Update operation") {
                
                beforeEach {
                    operation = ArrayOperation.Update(value: 10, atIndex: 5)
                }
                
                it("returns the updated value") {
                    expect(operation.value).to(equal(10))
                }
                
            }
            
            context("when the operation is an Remove operation") {
                
                beforeEach {
                    operation = ArrayOperation.RemoveElement(atIndex: 5)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
                
            }
            
        }
        
    }
    
}
