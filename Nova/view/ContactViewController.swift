//
//  Copyright 2017 Andrej Jurkin.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  ContactViewController.swift
//  Nova
//
//  Created by Andrej Jurkin on 26/09/17.
//

import Cocoa

class ContactViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
       
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.setTransparentTitle()
        AppDelegate.shared().menuBarView?.hidePopover()
    }
   
    @IBAction func onLinkedinClick(_ sender: Any) {
        if let url = URL(string: "https://www.linkedin.com/in/andrej-jurkin-9691379a/") {
            NSWorkspace.shared().open(url)
        }
    }

    @IBAction func onGithubClick(_ sender: Any) {
        if let url = URL(string: "https://github.com/andrejjurkin") {
            NSWorkspace.shared().open(url)
        }
    }
}
