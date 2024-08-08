//
//  WidgetView.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 23.07.2024.
//

import WidgetKit
import SwiftUI

struct WidgetView : View {
    var entry: DefaultWidgetProvider.Entry
    
    @Environment(\.widgetFamily)
    private var family
    
    var body: some View {
        switch family{
            case .accessoryCircular:
                Image(systemName: "square.and.pencil.circle.fill")
            case .accessoryCorner:
                Image(systemName: "square.and.pencil.circle.fill")
            case .accessoryInline:
                Image(systemName: "square.and.pencil.circle.fill")
            case .accessoryRectangular:
                VStack(alignment: .center) {
                    VStack {
                        HStack {
                            Image(systemName: "square.and.pencil.circle.fill")
                            Text("Notes")
                            Spacer()
                        }    .font(.system(size: 11))
                        HStack{
                            Text(entry.lastNote).font(.footnote)
                            Spacer()
                        }
                    }
                }
            case .systemSmall:
                VStack(alignment: .center) {
                    VStack {
                        HStack {
                            Image(systemName: "square.and.pencil.circle.fill")
                            Text("Notes")
                            Spacer()
                        }    .font(.system(size: 11))
                        HStack{
                            Text(entry.lastNote).font(.footnote)
                            Spacer()
                        }
                    }
                }
            case .systemMedium:
                VStack(alignment: .center) {
                    VStack {
                        HStack {
                            Image(systemName: "square.and.pencil.circle.fill")
                            Text("Notes")
                            Spacer()
                        }    .font(.system(size: 11))
                        HStack{
                            Text(entry.lastNote).font(.footnote)
                            Spacer()
                        }
                    }
                }
            case .systemLarge:
                VStack(alignment: .center) {
                    VStack {
                        HStack {
                            Image(systemName: "square.and.pencil.circle.fill")
                            Text("Notes")
                            Spacer()
                        }    .font(.system(size: 11))
                        HStack{
                            Text(entry.lastNote).font(.footnote)
                            Spacer()
                        }
                    }
                }
            case .systemExtraLarge:
                VStack(alignment: .center) {
                    VStack {
                        HStack {
                            Image(systemName: "square.and.pencil.circle.fill")
                            Text("Notes")
                            Spacer()
                        }    .font(.system(size: 11))
                        HStack{
                            Text(entry.lastNote).font(.footnote)
                            Spacer()
                        }
                    }
                }
            @unknown default:
                Image(systemName: "square.and.pencil.circle")
        }
        
    }
}

