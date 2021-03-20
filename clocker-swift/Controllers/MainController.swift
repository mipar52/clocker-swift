//
//  MainController.swift
//  MicroStudent
//
//  Created by Milan Parađina on 28.12.2020..
//

import UIKit

class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func newEntryPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToEntry", sender: self)
    }
    
    
}
