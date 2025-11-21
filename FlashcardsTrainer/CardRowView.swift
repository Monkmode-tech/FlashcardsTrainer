import SwiftUI
import SwiftData

struct CardRowView: View {
    let card: Card
    let appLanguage: String
    var onFlip: () -> Void
    @State private var isFlipped: Bool = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
            HStack {
                Group {
                    CardContentView(isFlipped: isFlipped, card: card, appLanguage: appLanguage)
                }
                Spacer(minLength: 40)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                Button(action: {
                    withAnimation {
                        let wasFlipped = isFlipped
                        isFlipped.toggle()
                        if !wasFlipped {
                            onFlip()
                        }
                    }
                }) {
                    Image(systemName: "arrow.2.circlepath")
                        .imageScale(.large)
                        .accessibilityLabel("flip_card".localized(for: appLanguage))
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 16),
                alignment: .trailing
            )
        }
        .frame(height: 100)
    }
}

#Preview {
    CardRowView(card: Card(front: "Front", back: "Back", isKnown: false), appLanguage: "en", onFlip: {})
}
