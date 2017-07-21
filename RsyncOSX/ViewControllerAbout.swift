//
//  ViewControllerAbout.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/11/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length

import Foundation
import Cocoa

class ViewControllerAbout: NSViewController {

    // Dismisser
    weak var dismissDelegate: DismissViewController?
    // RsyncOSX version
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var downloadbutton: NSButton!
    @IBOutlet weak var thereisanewversion: NSTextField!

    // new version
    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    // External resources as documents, download
    private var resource: Resources?

    @IBAction func dismiss(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func changelog(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func documentation(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .documents))!)
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func download(_ sender: NSButton) {
        guard Configurations.shared.URLnewVersion != nil else {
            self.dismissDelegate?.dismiss_view(viewcontroller: self)
            return
        }
        NSWorkspace.shared.open(URL(string: Configurations.shared.URLnewVersion!)!)
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    private func checkforupdates() {
        globalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist!) {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    if self.runningVersion != nil {
                        if let url = contents?.object(forKey: self.runningVersion!) {
                            self.urlNewVersion = url as? String
                            Configurations.shared.URLnewVersion = self.urlNewVersion
                            globalMainQueue.async(execute: { () -> Void in
                                self.downloadbutton.isEnabled = true
                                self.thereisanewversion.isHidden = false
                            })
                        } else {
                            globalMainQueue.async(execute: { () -> Void in
                                self.thereisanewversion.stringValue = "No new version"
                                self.thereisanewversion.isHidden = false
                            })

                        }
                    }
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // External resource object
        self.resource = Resources()
        if let resource = self.resource {
            self.urlPlist = resource.getResource(resource: .urlPlist)
        }
        if let pvc = self.presenting as? ViewControllertabMain {
            self.dismissDelegate = pvc
        }
        let infoPlist = Bundle.main.infoDictionary
        let version = (infoPlist?["CFBundleShortVersionString"] as? String)!
        self.version.stringValue = "RsyncOSX ver: " + version
        self.runningVersion = version
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.downloadbutton.isEnabled = false
        self.thereisanewversion.isHidden = true
        self.checkforupdates()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.downloadbutton.isEnabled = false
        self.thereisanewversion.isHidden = true
    }

}
