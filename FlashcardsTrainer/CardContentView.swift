import SwiftUI
import SwiftData

struct CardContentView: View {
    let isFlipped: Bool
    let card: Card
    let appLanguage: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isFlipped {
                CardBackView(card: card, appLanguage: appLanguage)
            } else {
                CardFrontView(card: card, appLanguage: appLanguage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)
        .animation(.easeInOut, value: isFlipped)
    }
}

#Preview {
    CardContentView(isFlipped: false, card: Card(front: "Front", back: "Back", isKnown: false), appLanguage: "en")
}
