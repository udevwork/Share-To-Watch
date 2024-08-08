//
//  DataTransfer.swift
//  Watch App
//
//  Created by Denis Kotelnikov on 20.07.2024.
//

#if canImport(WatchConnectivity)
import WatchConnectivity
import Foundation
import Combine

class WatchDataTransfer: NSObject, WCSessionDelegate {
    
    var session: WCSession?
    
    enum Event: String {
        case add
        case delete
        case edit
        case unowned
    }
    
    let emitter = CurrentValueSubject<(WatchDataTransfer.Event, [String: Any]), Never>((.unowned, [:]))
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        session.outstandingUserInfoTransfers.forEach { info in
            if let text = info.userInfo.first?.key {
                self.send(text: text)
            }
        }
        self.send(text: "watch: activationDidComplete")
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
#endif
    
    // MARK: Receive UserInfo
    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {
        self.send(text: "> didReceiveUserInfo! \(userInfo.first?.value ?? "-=x=-")")
        DispatchQueue.main.async {
            
            guard 
                let eventName = userInfo["event"] as? String,
                let event = Event(rawValue: eventName),
                let noteData = userInfo["note"] as? [String: Any]
            else {
                self.send(text: "> didReceiveUserInfo! guard fail")
                return
            }
            
            self.send(text: "> didReceiveUserInfo! emited success")
            self.emitter.send((event, noteData))
        }
    }
    
    // MARK: Receive Message
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        print("[ReceiveMessage]: \(message["msg"] as! String)")
    }
    
    // MARK: Send Event
    func sendData(
        event: Event,
        item: [String: Any]
    ) {
        let userInfo: [String: Any] = [
            "event": event.rawValue,
            "note": item
        ]
        DispatchQueue.main.async {
            self.session?.transferUserInfo(userInfo)
        }
        print("sendData: \(event.rawValue)")
    }
    
    // MARK: Send Message
    func send(text: String) {
        session?.sendMessage(["msg" : text], replyHandler: nil)
    }

    func session(_ session: WCSession,
                 didFinish userInfoTransfer: WCSessionUserInfoTransfer,
                 error: (any Error)?) {
    }
}
#endif
