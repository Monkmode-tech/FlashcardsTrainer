//
//  ContentView.swift
//  FlashcardsTrainer
//
//  Created by Caleb Tetteh on 10/26/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Card.createdAt, order: .forward)]) var cards: [Card]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("showKnownOnly") private var showKnownOnly: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = "system"
    @State private var showAddSheet = false
    @State private var showDeleteAlert = false
    @State private var cardToDelete: Card?
    @State private var showEditSheet = false
    @State private var selectedCard: Card?
    
    var filteredCards: [Card] {
        showKnownOnly ? cards.filter { $0.isKnown } : cards
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("app_title".localized(for: appLanguage))
                        .font(.largeTitle)
                        .bold()
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Toggle(isOn: $showKnownOnly) {
                        Text("show_known_only".localized(for: appLanguage))
                    }
                    .toggleStyle(.switch)
                    .accessibilityLabel("show_known_only".localized(for: appLanguage))
                }
                .padding([.top, .horizontal])
                List {
                    ForEach(filteredCards) { card in
                        Button {
                            selectedCard = card
                            showEditSheet = true
                        } label: {
                            CardRowView(card: card, appLanguage: appLanguage) {
                                // Mark as known only when flipping to back
                                if !card.isKnown {
                                    card.isKnown = true
                                    card.modifiedAt = Date()
                                    try? modelContext.save()
                                }
                            }
                        }
                        .listRowBackground(card.isKnown ? Color("KnownColor") : Color("NewColor"))
                        .accessibilityElement(children: .combine)
                        .swipeActions {
                            Button(role: .destructive) {
                                cardToDelete = card
                                showDeleteAlert = true
                            } label: {
                                Label("delete_card".localized(for: appLanguage), systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Label("add_card".localized(for: appLanguage), systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: markAllKnown) {
                            Text("mark_all_known".localized(for: appLanguage))
                        }
                
                        Button(action: resetAll) {
                            Text("reset_all".localized(for: appLanguage))
                        }
                        
                        Picker("Language", selection: $appLanguage) {
                            Text("System Default (Device Language)").tag("system")
                            Text("English").tag("en")
                            Text("Español").tag("es")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 115)
                        .accessibilityLabel("language_picker".localized(for: appLanguage))
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EditCardView(card: Card(), isNew: true, onSaveOrCancel: { showAddSheet = false })
                    .environment(\.modelContext, modelContext)
            }
            .sheet(item: $selectedCard) { card in
                EditCardView(card: card, isNew: false)
                    .environment(\.modelContext, modelContext)
            }
            .alert("delete_card".localized(for: appLanguage), isPresented: $showDeleteAlert, presenting: cardToDelete) { card in
                Button(role: .destructive) {
                    if let card = cardToDelete {
                        modelContext.delete(card)
                        cardToDelete = nil
                    }
                } label: {
                    Text("delete_card".localized(for: appLanguage))
                }
                Button(role: .cancel) {} label: {
                    Text("Cancel")
                }
            } message: { card in
                Text("delete_confirm".localized(for: appLanguage))
            }
        }
    }
    
    private func markAllKnown() {
        for card in cards where !card.isKnown {
            card.isKnown = true
            card.modifiedAt = Date()
        }
    }
    
    private func resetAll() {
        for card in cards where card.isKnown {
            card.isKnown = false
            card.modifiedAt = Date()
        }
    }
}

extension String {
    func localized(for lang: String) -> String {
        let resolvedLang: String
        if lang == "system" {
            if let languageCode = Locale.current.language.languageCode?.identifier {
                resolvedLang = languageCode
            } else {
                resolvedLang = "en"
            }
        } else {
            resolvedLang = lang
        }
        guard let path = Bundle.main.path(forResource: resolvedLang, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

extension DateFormatter {
    static let flashcard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
