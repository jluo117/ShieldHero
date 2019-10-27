//
//  GameViewController.swift
//  DodgeMonster
//
//  Created by james luo on 10/26/19.
//  Copyright © 2019 james luo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Activ5Device
import CoreBluetooth
class GameViewController: UIViewController{
    var devices: [String: A5Device] = A5DeviceManager.devices
    var lastMessage: [String: String] = [:]
    lazy var deviceNames: [String] = {return Array(self.devices.keys)}()


    override func viewDidLoad() {
        A5DeviceManager.delegate = self
        super.viewDidLoad()
        
        self.devices = A5DeviceManager.devices
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension GameViewController: A5DeviceDelegate {
    func didFailToConnect(device: A5Device, error: Error?) {
        print("fail to connect")
    }
    
    func deviceDisconnected(device: A5Device) {
        print("disconnect")
    }
    
    func searchCompleted() {
        //self.statusLabel.text = "Search completed"
    }

    func deviceFound(device: A5Device) {
        self.devices = A5DeviceManager.devices
        deviceNames = Array(self.devices.keys)
        //self.statusLabel.text = (device.name ?? "A Device") + " found"
       // self.tableView.reloadData()
    }

    func deviceConnected(device: A5Device) {
       // self.statusLabel.text = (device.name ?? "A Device") + " connected"
        if let deviceName = device.name {
            self.lastMessage[deviceName] = "Connected"
            if let deviceIndex = self.deviceNames.index(of: deviceName) {
              //  self.tableView.reloadRows(at: [IndexPath(row: deviceIndex, section: 0)], with: .none)
                print("connected")
                
            }
            
        }
    }

    func didReceiveMessage(device: A5Device, message: String, type: MessageType) {
        if let deviceName = device.name {
            var messageToShow = ""
            switch type {
            case .initialMessage:
                messageToShow = "Connected"
            case .isometric:
                break
            default:
                messageToShow = ""
            }

            self.lastMessage[deviceName] = messageToShow

            if let deviceIndex = self.deviceNames.index(of: deviceName) {
                //self.tableView.reloadRows(at: [IndexPath(row: deviceIndex, section: 0)], with: .none)
            }
        }
    }

    func didReceiveIsometric(device: A5Device, value: Int) {
        if let deviceName = device.name {
            self.lastMessage[deviceName] = "IS" + value.description
            
            }
    
        print(value)
    }
    
}
