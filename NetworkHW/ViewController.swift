//
//  ViewController.swift
//  NetworkHW
//
//  Created by a.belkov on 20/11/2017.
//  Copyright © 2017 bestK1ng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var infoVectorLabel: NSTextField!
    @IBOutlet weak var codeRangeButton: NSPopUpButton!
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var cycleCodeLabel: NSTextField!
    
    var table: [TableRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.isEnabled = false
        indicator.isDisplayedWhenStopped = false
        cycleCodeLabel.stringValue = ""
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: Actions
    
    @IBAction func calculateAction(_ sender: Any) {
        
        self.cycleCodeLabel.stringValue = ""
        
        let infoVectorString = infoVectorLabel.stringValue
        let infoVector = Int(infoVectorString, radix: 2) ?? 0b0
        
        var n = 0
        var k = 0
        switch codeRangeButton.selectedItem!.title {
        case "Ц [7, 4]":
            n = 7
            k = 4
            break
        case "Ц [15, 11]":
            n = 15
            k = 11
            break
        default:
            break
        }
        
        let container = CycleCodeCalculator(infoVector: infoVector, n: n, k: k)
        
        let cycleCodeString = String(container.cycleCode, radix: 2)
        self.cycleCodeLabel.stringValue = "Циклический код: \(cycleCodeString)"

        self.indicator.startAnimation(self)
        DispatchQueue.global(qos: .background).async {
            let table = container.calculateDetectingAbilitiesInTable()
            self.table = table
            
            DispatchQueue.main.async {
                self.tableView.isEnabled = true
                self.tableView.reloadData()
                self.indicator.stopAnimation(self)
            }
        }
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return table.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let tableRow = table[row]
        
        var text = ""
        switch tableColumn! {
        case tableView.tableColumns[0]:
            text = "\(tableRow.value)"
            break
        case tableView.tableColumns[1]:
            text = "\(tableRow.combinationsCount)"
            break
        case tableView.tableColumns[2]:
            text = "\(tableRow.errorsCount)"
            break
        case tableView.tableColumns[3]:
            text = "\(tableRow.detectingAbility)"
            break
        default:
            break
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TableViewCellID"), owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            
            return cell
        }
        
        return nil
    }
}
