//
//  ViewController.swift
//  NetworkHW
//
//  Created by a.belkov on 20/11/2017.
//  Copyright © 2017 bestK1ng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func calculateAction(_ sender: Any) {
        
        let container = CycleCodeCalculator(infoVector: 0b00001010001, n: 15, k: 11)
        
        let cycleCodeString = String(container.cycleCode, radix: 2)
        print("Циклический код: \(cycleCodeString)")
        
        let table = container.calculateDetectingAbilitiesInTable()
        for row in table {
            print("\(row.value)|\(row.combinationsCount)|\(row.errorsCount)|\(row.detectingAbility)")
        }
    }
}

