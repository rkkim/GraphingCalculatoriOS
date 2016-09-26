//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Richard Kim on 7/13/16.
//  Copyright © 2016 Richard Kim. All rights reserved.
//

import Foundation

func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}

class CalculatorBrain
{
    private var historyAccumulator = ""
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var variableInternalProgram = [AnyObject]()
    
    func setOperand(operand: Double){
        accumulator = operand
        internalProgram.append(operand)
        variableInternalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation({sqrt($0)}, {"√(" + $0 + ")"}),
        "cos" : Operation.UnaryOperation(cos, {"cos(" + $0 + ")"}),
        "*" : Operation.BinaryOperation({ $0 * $1 }, {$0 + "*" + $1}),
        "/" : Operation.BinaryOperation({ $0 / $1 }, {$0 + "/" + $1}),
        "+" : Operation.BinaryOperation({ $0 + $1 }, {$0 + "+" + $1}),
        "-" : Operation.BinaryOperation({ $0 - $1 }, {$0 + "-" + $1}),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double,Double) -> Double, (String, String) -> String)
        case Equals
    }
    
    func performOperation(symbol: String){
        internalProgram.append(symbol)
        variableInternalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let associatedFunction, let unaryString):
                accumulator = associatedFunction(accumulator)
                historyAccumulator = unaryString(historyAccumulator)
            case .BinaryOperation(let associatedFunction, let binaryString):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: associatedFunction, binaryStrFunc: binaryString, firstOperand: accumulator)
                
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            historyAccumulator = pending!.binaryStrFunc(String(pending!.firstOperand), "historyAccumulator")
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var binaryStrFunc: (String, String) -> String
        var firstOperand: Double
    }

    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
            
        }
    }
    
    typealias VariablePropertyList = AnyObject
    
    var variableProgram: VariablePropertyList {
        get {
            return variableInternalProgram
        }
        set {
            if let varArrayOfOps = newValue as? [AnyObject] {
                for varOp in varArrayOfOps {
                    if let operand = varOp as? Double {
                        setOperand(operand)
                    } else if let operation = varOp as? String {
                        if (variableOperand == nil && operation == "M") {
                            pending = nil
                        } else if (variableOperand != nil && operation == "M"){
                            setOperand(variableOperand!)
                        }
                        else{
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    var variableOperand: Double?
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        variableInternalProgram.removeAll()
        historyAccumulator = ""
        
    }
    
    var result: Double{
        get {
            return accumulator
        }
    }
    
    var historyResult: String {
        get {
            return historyAccumulator
        }
    }
    
}