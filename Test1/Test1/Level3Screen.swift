//
//  Level3Screen.swift
//  Test1
//
//  Created by Fede on 21/07/19.
//  Copyright © 2019 Comelicode. All rights reserved.
//

import UIKit

class Level3Screen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Places view elements on the screen: title, text and button
        // they are centered vertically and their dimension depends on
        // screen width and height
        
        let screenWidth = view.frame.width
        let screenHeight = view.frame.size.height
        
        screenTitle.sizeToFit()
        screenTitle.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.8, height: screenHeight * 0.2)
        screenTitle.center.x = self.view.center.x
        screenTitle.center.y = self.view.center.y - screenHeight * 0.3
        
        screenText.sizeToFit()
        screenText.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.8, height: screenHeight * 0.4)
        screenText.center = self.view.center
        
        // Sets constant to multiply for button: different between iPhone and iPad
        
        var screenHeighMultiplicationConstant = CGFloat()
        if screenWidth >= 1024 {
            screenHeighMultiplicationConstant = 0.15
        } else {
            screenHeighMultiplicationConstant = 0.2
        }
        
        screenButton.sizeToFit()
        screenButton.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.3, height: screenHeight * screenHeighMultiplicationConstant)
        screenButton.center.x = self.view.center.x
        screenButton.center.y = self.view.center.y + screenHeight * 0.3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            UIAccessibility.post(notification: .announcement, argument: "The line is now diagonal. Press play to continue.")
        })
    }
    
    @IBOutlet var screenTitle: UILabel!
    @IBOutlet var screenText: UILabel!
    @IBOutlet var screenButton: UIButton!
    
}
