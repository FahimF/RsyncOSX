//
//  ViewControllerInformation.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar line_length

import Foundation
import Cocoa

// protocol for kill function
protocol Information : class {
    func getInformation () -> [String]
}

class ViewControllerInformation: NSViewController {

    // TableView
    @IBOutlet weak var detailsTable: NSTableView!

    // output from Rsync
    var output: Array<String>?
    weak var informationDelegate: Information?
    weak var dismissDelegate: DismissViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        detailsTable.delegate = self
        detailsTable.dataSource = self
        // Setting the source for delegate function
        self.informationDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.output = self.informationDelegate?.getInformation()
        detailsTable.reloadData()
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

}

extension ViewControllerInformation: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.output?.count ?? 0
    }

}

extension ViewControllerInformation: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = self.output![row]
            cellIdentifier = "outputID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
