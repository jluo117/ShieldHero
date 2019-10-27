//
//  ViewController.swift
//  Activ5-Device
//
//  Created by starbuckbg on 08/27/2018.
//  Copyright (c) 2019 ActivBody Inc. <https://activ5.com>. All rights reserved.
//
import SpriteKit
import UIKit
import CoreBluetooth
import Activ5Device
import FirebaseDatabase
var curNewton = 0
class ViewController: UIViewController {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBAction func launch(_ sender: UIButton) {
        launchGame()
    }
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var devices: [String: A5Device] = A5DeviceManager.devices
    var lastMessage: [String: String] = [:]
    lazy var deviceNames: [String] = {return Array(self.devices.keys)}()

    @IBOutlet weak var launchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        A5DeviceManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchForDevicesTapped(_ sender: Any) {
        self.statusLabel.text = "Searching for devices"
        A5DeviceManager.scanForDevices {
            // Action when a device has been found
        }
    }
    func launchGame(){
        statusLabel.isHidden = true
        searchButton.isHidden = true
        launchButton.isHidden = true
        if let view = self.view as! SKView? {
            tableView.isHidden = true
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
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let deviceName = self.deviceNames[indexPath.row]
        cell.textLabel?.text = deviceName
        cell.detailTextLabel?.text = ""
        if let deviceInfo = self.devices[deviceName] {
            if deviceInfo.deviceDataState == .disconnected {
                cell.detailTextLabel?.text = "Disconnected"
            } else {
                cell.detailTextLabel?.text = self.lastMessage[deviceName] ?? ""
            }
        }

        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let device = self.devices[deviceNames[indexPath.row]] else {
            return
        }

        let alertSheet = UIAlertController(title: "Select action", message: nil, preferredStyle: .actionSheet)
        let connectAction = UIAlertAction(title: "Connect", style: .default) { (_) in
            A5DeviceManager.connect(device: device.device)
        }
        let disconnectAction = UIAlertAction(title: "Disconnect", style: .destructive) { (_) in
            device.disconnect()
        }
        let requestIsomAction = UIAlertAction(title: "Request isometric", style: .default) { (_) in
            device.startIsometric()
        }
        let requestTare = UIAlertAction(title: "Request tare", style: .default) { (_) in
            device.sendCommand(.tare)
        }
        let requestStop = UIAlertAction(title: "Request stop", style: .default) { (_) in
            device.stop()
        }
        let switchOnEvergreenMode = UIAlertAction(title: "Swith On Evergreen", style: .default) { (_) in
            device.evergreenMode = true
        }
        let switchOffEvergreenMode = UIAlertAction(title: "Swith Off Evergreen", style: .destructive) { (_) in
            device.evergreenMode = false
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            alertSheet.dismiss(animated: true, completion: nil)
        }

        switch device.deviceDataState {
        case .disconnected:
            alertSheet.addAction(connectAction)
            alertSheet.addAction(cancelAction)
        default:
            alertSheet.addAction(requestIsomAction)
            alertSheet.addAction(requestTare)
            alertSheet.addAction(requestStop)
            
            switch device.evergreenMode {
            case true:
                alertSheet.addAction(switchOffEvergreenMode)
            case false:
                alertSheet.addAction(switchOnEvergreenMode)
            }
            
            alertSheet.addAction(disconnectAction)
            alertSheet.addAction(cancelAction)
        }

        self.present(alertSheet, animated: true, completion: nil)

    }
}

extension ViewController: A5DeviceDelegate {
    func searchCompleted() {
        self.statusLabel.text = "Search completed"
    }

    func deviceFound(device: A5Device) {
        self.devices = A5DeviceManager.devices
        deviceNames = Array(self.devices.keys)
        self.statusLabel.text = (device.name ?? "A Device") + " found"
        self.tableView.reloadData()
    }

    func deviceConnected(device: A5Device) {
        self.statusLabel.text = (device.name ?? "A Device") + " connected"
        if let deviceName = device.name {
            self.lastMessage[deviceName] = "Connected"
            if let deviceIndex = self.deviceNames.index(of: deviceName) {
                self.tableView.reloadRows(at: [IndexPath(row: deviceIndex, section: 0)], with: .none)
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
                self.tableView.reloadRows(at: [IndexPath(row: deviceIndex, section: 0)], with: .none)
            }
        }
    }

    func didReceiveIsometric(device: A5Device, value: Int) {
        //let ref = Database.database().reference()
        if let deviceName = device.name {
            self.lastMessage[deviceName] = "IS" + value.description
            if let deviceIndex = self.deviceNames.index(of: deviceName) {
                self.tableView.reloadRows(at: [IndexPath(row: deviceIndex, section: 0)], with: .none)
            }
        }
        
        if value <= 0{
            return
        }
        let ref = Database.database().reference()
        ref.child("Newton").setValue(value)
        print(value)
        curNewton = value
    }
    func deviceDisconnected(device: A5Device) {
        self.statusLabel.text = (device.name ?? "A Device") + " disconnected"
        self.tableView.reloadData()
    }

    func didFailToConnect(device: A5Device, error: Error?) {

    }
}
