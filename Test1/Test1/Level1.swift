//
//  Level1.swift
//  Test1
//
//  Created by simona1971 on 25/06/19.
//  Copyright © 2019 Comelicode. All rights reserved.
//
// Level1: creates two elements, then a line between them, and detects if
// the user pans inside the line

import UIKit
import AudioKit
import AVFoundation

class Level1: UIViewController {
    
    // AudioKit setup and start
    
    var oscillator = AKFMOscillator()
    var oscillator2 = AKOscillator()
    var panner = AKPanner()
    var mixerCat = AKMixer()
    
    var catSound: AVAudioPlayer?
    var kittenSound: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        // Creates AudioKit mixer and panner
        
        //var catMeow = try! AKAudioPlayer(file: catSound!)
        //var kittenMeow = try! AKAudioPlayer(file: kittenSound!)
        
        let mixer = AKMixer(oscillator,oscillator2)
        
        panner = AKPanner(mixer, pan: 0.0)
        
        AudioKit.output = panner
        
        // Audio is played with silent mode as well
        
        AKSettings.playbackWhileMuted = true
        
        
        try! AudioKit.start()
        
        // Hides the kitten label
        
        kitten.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            try! AudioKit.stop()
        }
    }
    
    @IBOutlet var cat: UIImageView!
    @IBOutlet var kitten: UIImageView!
    
    var firstLevelShape: Shape!
    
    var gameStarted: Bool = false
    
    var catShown: Bool = false
    var levelComplete: Bool = false
    
    var startingPoint = CGPoint()
    var startedFromKitten: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Game logic: find the cat, find the kitten
        // When both are found create the line
        // If the kitten has been reached, go to the next level
        
        // Tell the user to find the cat
        
        if gameStarted == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                UIAccessibility.post(notification: .announcement, argument: "Find the cat")
            })
        }
    }
    
    // Sets the line location and dimension:
    // it is located between the cat and the kitten
    // it has the same heigth as the element
    
    func createLine() -> Void {
        
        let kittenMaxX = kitten.frame.maxX
        let catMinX = cat.frame.minX
        
        let shapeWidth: CGFloat = catMinX - kittenMaxX
        
        // Creates an accessibile rectangle shape
        
        firstLevelShape = Shape(frame: CGRect(x: kittenMaxX,
                                              y: self.view.frame.size.height / 2 - 32.5,
                                              width: shapeWidth,
                                              height: 75))
        
        firstLevelShape.isAccessibilityElement = true
        firstLevelShape.accessibilityHint = "shape"
        
        self.view.addSubview(firstLevelShape)
    }
    
    // Detects panning on the shape and adds sonification based on the finger position
    
    var catFound = 0
    var kittenFound = 0
    var levelCompleteCounter = 0
    
    @IBAction func panDetector(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let catSoundPath = Bundle.main.path(forResource: "cat.wav", ofType:nil)!
        let catSoundUrl = URL(fileURLWithPath: catSoundPath)
        let kittenSoundPath = Bundle.main.path(forResource: "kitten.wav", ofType:nil)!
        let kittenSoundUrl = URL(fileURLWithPath: kittenSoundPath)
        
        print("panDetector")
        
        // Saves the point touched by the user
        
        let initialPoint = gestureRecognizer.location(in: view)
        
        guard gestureRecognizer.view != nil else {return}
        
        /*var catMeow = try! AKAudioPlayer(file: catSound!)
        var kittenMeow = try! AKAudioPlayer(file: kittenSound!)
        mixerCat = AKMixer(catMeow, kittenMeow)  // Create AKMixer object, with audio loops as inputs
        AudioKit.output = mixerCat    // Connect the mixer’s output to be AudioKit’s output
        
        try! AudioKit.start()
 */
        
        // Updates the position for the .began, .changed, and .ended states
        
        if gameStarted == false && levelComplete == false {
        
            if isInsideCat(point: initialPoint) {
                
                // If it is the first time finding the cat tell the user it has been found
                // and show the kitten
                // else tell the user it is the cat
                
                print("cat: first tap")
                
                /*do {
                    self.catSound = try AVAudioPlayer(contentsOf: catSoundUrl)
                    self.catSound?.play()
                } catch {
                    // couldn't load file :(
                }*/
                
                //UIAccessibility.post(notification: .announcement, argument: "You found the cat! Find the kitten")
                
                // Show the kitten
                
                catFound = catFound + 1
                catShown = true
                kitten.isHidden = false
            } else {
                catFound = 0
            }
        
            if catShown == true {
                
                if isInsideKitten(point: initialPoint) {
                    
                    startingPoint = initialPoint
                    print("startingPoint 2: ", startingPoint)
                    
                    print("kitten: tap")
                    
                    kittenFound = kittenFound + 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        // Create the line
                        
                        self.createLine()
                        
                        // Start the game
                        
                        self.gameStarted = true
                    })
                } else {
                    kittenFound = 0
                }
            }
        }
        
        if gameStarted == true {
            
            if isInsideKitten(point: initialPoint) {
                startingPoint = initialPoint
                print("startingPoint 2: ", startingPoint)
                
                startedFromKitten = true
                
                UIAccessibility.post(notification: .announcement, argument: "Kitten")
                
            }
            
            if gestureRecognizer.state == .changed {
                print(initialPoint)
                
                let firstLevelRect = firstLevelShape.getCGRect()
                
                // Distinguishes 3 cases based on the finger position:
                // 1. Inside the line but not in the center
                // 2. At the center of the line
                // 3. Outside the line
                
                // The finger is inside the line
                
                if (firstLevelRect.contains(initialPoint)) {
                    print("OK: point is inside shape")
                    
                    // Creates a sub-shape which indicates the line center
                    
                    let screenMiddleLineY = self.view.frame.size.height / 2
                    let middleLineMinY = screenMiddleLineY - 5
                    let middleLineMaxY = screenMiddleLineY + 5
                    
                    let middleLineX = kitten.frame.maxX..<cat.frame.minX
                    let middleLineY = middleLineMinY..<middleLineMaxY
                    
                    // 1. Inside the line but not in the center
                    
                    oscillator2.stop()
                    if initialPoint.y > middleLineMaxY {
                        oscillator.baseFrequency = 300 - Double(initialPoint.y)
                    } else {
                        oscillator.baseFrequency = 300 + Double(initialPoint.y)
                    }
                    oscillator.amplitude = 1
                    oscillator.start()
                    
                    // 2. At the center of the line
                    
                    if(middleLineX.contains(initialPoint.x) && middleLineY.contains(initialPoint.y)) {
                        print("Inside the middle line")
                        oscillator2.stop()
                        
                        panner.pan = normalize(num: Double(initialPoint.x))
                        
                        oscillator.baseFrequency = 300
                    } 
                    
                } else {
                    // 3. Outside the line
                    
                    print("NO: point is outside shape")
                    
                    panner.pan = 0.0
                    
                    oscillator.stop()
                    oscillator2.amplitude = 0.5
                    oscillator2.frequency = 200
                    oscillator2.start()
                    
                    // Two cases
                    // Finger is outside the line and inside the kitten: great! Level completed
                    // Finger is outside the line but outside the kitten: restart
                    
                    if isInsideCat(point: initialPoint) {
                        print("Last point is inside element")
                        
                        if startedFromKitten {
                            oscillator.stop()
                            oscillator2.stop()
                            
                            gameStarted = false
                            
                            levelComplete = true
                    
                        }
                        
                    } else if !isInsideKitten(point: initialPoint) || startedFromKitten == false {
                        print("Last point is outside element")
                        print("restart game")
                        UIAccessibility.post(notification: .announcement, argument: "Go back and follow the line")
                    }
                }
            }
            
            if gestureRecognizer.state == .ended {
                print("Pan released")
                print("restart game")
                UIAccessibility.post(notification: .announcement, argument: "Go back and follow the line")
                startedFromKitten = false
                levelCompleteCounter = 0
            }
        }
        
        if levelComplete == true {
            
            gestureRecognizer.isEnabled = false
            
            UIAccessibility.post(notification: .announcement, argument: "Level 1 completed")
            
            do {
                self.catSound = try AVAudioPlayer(contentsOf: catSoundUrl)
                self.catSound?.play()
            } catch {
                // couldn't load file :(
            }
        }
        
        if catFound == 1 {
            
            do {
                self.catSound = try AVAudioPlayer(contentsOf: catSoundUrl)
                self.catSound?.play()
            } catch {
                // couldn't load file :(
            }
            
            UIAccessibility.post(notification: .announcement, argument: "You found the cat! Find the kitten")
        }
        
        if kittenFound == 1 {
            
            do {
                kittenSound = try AVAudioPlayer(contentsOf: kittenSoundUrl)
                kittenSound?.play()
            } catch {
                // couldn't load file :(
            }
            
            UIAccessibility.post(notification: .announcement, argument: "You found the kitten! Follow the line to connect the kitten to the cat")
        }
    }
    
    // Returns true if the passed point is inside the cat
    
    func isInsideCat(point: CGPoint) -> Bool {
        let catMaxX = cat.frame.maxX
        let catMinX = cat.frame.minX
        let catMaxY = cat.frame.maxY
        let catMinY = cat.frame.minY
        
        return point.x >= catMinX && point.x <= catMaxX &&
            point.y >= catMinY && point.y <= catMaxY
    }
    
    // Returns true if the passed point is inside the kitten
    
    func isInsideKitten(point: CGPoint) -> Bool {
        let kittenMaxX = kitten.frame.maxX
        let kittenMinX = kitten.frame.minX
        let kittenMaxY = kitten.frame.maxY
        let kittenMinY = kitten.frame.minY
        
        return point.x >= kittenMinX && point.x <= kittenMaxX &&
            point.y >= kittenMinY && point.y <= kittenMaxY
    }
    
    // Normalizes double values for AudioKit panner
    
    func normalize(num: Double) -> Double {
        let min = Double(kitten.frame.minX + 10)
        let max = Double(cat.frame.maxX - 10)
        return 2 * ((num - min) / (max - min)) - 1
    }
}
