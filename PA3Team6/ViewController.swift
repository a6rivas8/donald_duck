//
//  ViewController.swift
//  PA3Team6
//
//  Created by Team6 on 11/21/19.
//  Copyright © 2019 Team6. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreMotion

let chestImage = UIImage(named: "chest")
let duckImage = UIImage(named: "donald_duck")
class ViewController: UIViewController {
    var context = LAContext()
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    let chest = UIImageView(image: chestImage!)
    let donald = UIImageView(image: duckImage!)
    
    var dx: CGFloat = 0.0
    var dy: CGFloat = 0.0
    let screenSize = UIScreen.main.bounds
    
    var score: Int = 0
    var gameEnd: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) {
         context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Insert Password", reply: {(success, error) in
                if success {
                    print("Authentication succeeded")
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let random_x = CGFloat.random(in: 25...(screenSize.width - chest.bounds.width / 2))
        let random_y = CGFloat.random(in: 25...(screenSize.height - chest.bounds.height / 2))
        
        donald.frame = CGRect(x: screenSize.midX, y: screenSize.midY, width: 100, height: 100)
        view.addSubview(donald)
        
        chest.frame = CGRect(x: random_x, y: random_y, width: 50, height: 50)
        view.addSubview(chest)
        chestLocation()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1
        }

        motionManager.startAccelerometerUpdates()
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(moveObject), userInfo: nil, repeats: true)

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1
        }
    }
    
    @objc func moveObject() {
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        var point: CGPoint = donald.center
        
        if let accelorometerData = motionManager.accelerometerData {
            dx = CGFloat(accelorometerData.acceleration.x) * 20
            dy = CGFloat(accelorometerData.acceleration.y) * 20
        }
        
        // top bound
        if point.y < (donald.bounds.width / 2) {
            point.y = donald.bounds.width / 2
        }
        
        // right bound
        if point.x > (screenWidth - (donald.bounds.width / 2)) {
            point.x = (screenWidth - (donald.bounds.width / 2))
        }
        
        // left bound
        if point.x < (donald.bounds.width / 2) {
            point.x = (donald.bounds.width / 2)
        }
        
        // bottom bound
        if point.y > (screenHeight - (donald.bounds.width / 2)) {
            point.y = (screenHeight - (donald.bounds.width / 2))
        }

        point.x = point.x + dx
        point.y = point.y - dy
        donald.center = point
        
        if pow((chest.center.x - donald.center.x), 2) + pow((chest.center.y - donald.center.y), 2) < pow((chest.bounds.width / 2), 2) {
            score += 100
            scoreLabel.text = "Score: \(score)"
            chestLocation()
        }
    }
    
    func chestLocation() {
        var point: CGPoint = chest.center
        let random_x = CGFloat.random(in: (chest.bounds.width / 2)...(screenSize.width - chest.bounds.width / 2))
        let random_y = CGFloat.random(in: (chest.bounds.width / 2)...(screenSize.height - chest.bounds.height / 2))
        
        point.x = random_x
        point.y = random_y
        chest.center = point
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alert = UIAlertController(title: "GAME END", message: "Game ended :(", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { _ in self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            motionManager.stopAccelerometerUpdates()
            motionManager.stopGyroUpdates()
            
            donald.center.x = screenSize.midX
            donald.center.y = screenSize.midY
            return
        }
    }
}

