import SwiftUI
import SwiftData

struct CardBackView: View {
    let card: Card
    let appLanguage: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("back_label".localized(for: appLanguage))
                .font(.caption)
                .foregroundColor(.blue)
                .accessibilityLabel("back_label".localized(for: appLanguage))
                .dynamicTypeSize(.medium ... .xxLarge)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            Text(card.back)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .accessibilityLabel(card.back)
                .dynamicTypeSize(.medium ... .xxLarge)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    CardBackView(card: Card(front: "Front", back: "Back", isKnown: false), appLanguage: "en")
}
