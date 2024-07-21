//
//  DataTransfer.swift
//  Watch App
//
//  Created by Denis Kotelnikov on 20.07.2024.
//

import Foundation
import WatchConnectivity

class DataTransfer: NSObject, WCSessionDelegate {
    
    var session: WCSession?
    
    enum Event: String {
        case add
        case delete
        case edit
    }
    
    var onRecive: (Event, Note) -> () = { _,_ in }
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        session.outstandingUserInfoTransfers.forEach { info in
            self.send(text: "\(info.userInfo.first?.key)")
        }
        self.send(text: "watch: activationDidComplete")
    }
    
    func test() {
        session?.outstandingUserInfoTransfers.forEach { info in
            self.send(text: "\(info.userInfo.first?.key)")
        }
        self.send(text: "watch: activationDidComplete")
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
#endif
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        self.send(text: "> didReceiveUserInfo!")
        DispatchQueue.main.async {
            guard let eventName = userInfo.first?.key else { return }
            self.send(text: "> didReceiveUserInfo! \(eventName)")
            let event = Event(rawValue: eventName)
            let modelContext = DataContainer.context
            if let data = userInfo[eventName] as? [String : Any],
               let note = Note.fromDictionary(data),
               let event = event {
                print("Received event: \(event.rawValue) info: \(note.text ?? "notext")")
                self.onRecive(event, note)
            } else {
                print("Invalid data was received!")
            }
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: (any Error)?) {
        
    }
    
    func sendData(event: Event, item: [String: Any]) {
        let userInfo: [String: Any] = [event.rawValue: item]
        session?.transferUserInfo(userInfo)
        print("sendData: \(event.rawValue)")
    }
        
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[ReceiveMessage]: \(message["msg"] as! String)")
    }
    
    func send(text: String) {
        if session!.isReachable {
            session?.sendMessage(["msg" : text], replyHandler: nil)
        }
    }
}
