//
//  ViewController.swift
//  Calculator
//
//  Created by Richard Kim on 7/11/16.
//  Copyright © 2016 Richard Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var history: UILabel!

    private var userIsInTheMiddleOfTyping = false
    private var hasDecimal = false
    
    
    @IBAction private func touchDigit(sender: UIButton){
        let digit = sender.currentTitle!
        
        if (digit == "."){
            if hasDecimal{
                return
            }
            if !userIsInTheMiddleOfTyping{
                display.text = "0"
                userIsInTheMiddleOfTyping = true
            }
            hasDecimal = true
        }
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var historyValue: String {
        get {
            return history.text!
        }
        set {
            history.text = newValue
        }
    }
    
    var savedEquation: CalculatorBrain.VariablePropertyList?
    
    @IBAction func saveEquation() {
        savedEquation = brain.variableProgram
    }
    
    @IBAction func insertEquation() {
        brain.variableOperand = displayValue
        brain.variableProgram = savedEquation!
        displayValue = brain.result
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        brain.program = savedProgram!
        displayValue = brain.result
    }
    
    @IBAction func clearButton() {
        userIsInTheMiddleOfTyping = false
        displayValue = 0.0
        brain.clear()
        hasDecimal = false
        
    }
    
    
    private var brain = CalculatorBrain()
    
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        historyValue = brain.historyResult
    }


}







