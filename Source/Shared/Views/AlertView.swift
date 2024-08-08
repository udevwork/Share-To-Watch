import SwiftUI

struct AlertView: View {
    var image: String
    var title: String
    var subtitle: String
    var сolor: Color

    var body: some View {
        HStack(alignment: .center, spacing: 10, content: {
            Image(systemName: image)
                .font(.title)
                .imageScale(.large)
                .padding(EdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 10))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.title3)
                Text(subtitle).font(.footnote)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 25))
            Spacer()
        })
        .background(сolor.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct WatchAlertView: View {
    var image: String
    var title: String
    var subtitle: String
    var сolor: Color

    var body: some View {
        HStack(alignment: .center, spacing: 5, content: {
            Image(systemName: image)
                .imageScale(.large)
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 10))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.title3)
                Text(subtitle).font(.footnote)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
            Spacer()
        })
        .background(сolor.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    AlertView(image: "applewatch", title: "Watch is not connected", subtitle: "The notes may not sync correctly", сolor: .yellow)
}
