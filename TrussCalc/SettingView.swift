import SwiftUI
import Combine

class StockManager: ObservableObject {
    @Published var stock: [String: Bool] = [:]
    
    init() {
        loadStock()
    }
    
    func loadStock() {
        // Charger la disponibilité des éléments depuis UserDefaults ou une autre source de persistance
        if let savedStock = UserDefaults.standard.dictionary(forKey: "trussStock") as? [String: Bool] {
            stock = savedStock
        } else {
            stock = Dictionary(uniqueKeysWithValues: eurotrussFD34.map { ($0.name, true) })
        }
    }
    
    func saveStock() {
        // Sauvegarder la disponibilité des éléments dans UserDefaults ou une autre source de persistance
        UserDefaults.standard.set(stock, forKey: "trussStock")
    }
}

struct SettingsView: View {
    @ObservedObject var stockManager: StockManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Text("Paramètres")
                    .font(.title)
                    .padding()
                Spacer()
                Button("Terminé") {
                    // Sauvegarder les modifications
                    stockManager.saveStock()
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            Divider()
            List {
                Section(header: Text("Disponibilité des éléments Eurotruss")) {
                    ForEach(eurotrussFD34, id: \.id) { element in
                        Toggle(isOn: Binding(
                            get: { stockManager.stock[element.name, default: true] },
                            set: { stockManager.stock[element.name] = $0 }
                        )) {
                            Text(element.name)
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle()) // Utilisez SidebarListStyle sur macOS
        }
        .preferredColorScheme(.dark)  // Force dark mode for the entire view
    }
}
