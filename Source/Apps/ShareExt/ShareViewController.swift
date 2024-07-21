//
//  ShareViewController.swift
//  CtWShareExt
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import UIKit
import Social
import SwiftUI
import CoreData
import WatchConnectivity


class ShareViewViewModel {
    @MainActor func saveTextToCoreData(text: String) {
        let container = DataContainer.context.container
        let note = Note(id: UUID().uuidString, text: text, noteType: "you")

        container.mainContext.insert(note)
        try! container.mainContext.save()
    }
}

class ShareViewController: SLComposeServiceViewController {
  
    let model = ShareViewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func isContentValid() -> Bool {
        return !self.contentText.isEmpty
    }

    override func didSelectPost() {
        
        if !self.contentText.isEmpty {
            print("Post was selected with text: \(self.contentText ?? "")")
            model.saveTextToCoreData(text: self.contentText)
        } else {
            print("NO POST")
        }

        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        var items = [SLComposeSheetConfigurationItem]()
        
        if let item = SLComposeSheetConfigurationItem() {
            item.title = "Save"
    
            item.tapHandler = { [self] in
                print("Location picker tapped")
                model.saveTextToCoreData(text: "HELLO FROM EXT")
            }
            items.append(item)
        }

        return items
    }
    
}
