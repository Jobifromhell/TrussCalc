import SwiftUI

struct ContentView: View {
    
    enum StructureType: String, CaseIterable, Identifiable {
        case autoportee = "Autoporté"
        case arche = "Arche"
        var id: String { self.rawValue }
    }
    @StateObject private var stockManager = StockManager()
    
    @State private var structureType: StructureType = .autoportee
    @State private var length: String = ""
    @State private var width: String = ""
    @State private var height: String = ""
    @State private var selectedTruss: [TrussElement] = []
    @State private var trussCount: [String: Int] = [:]
    @State private var totalWeight: Double = 0.0
    @State private var totalVolume: Double = 0.0
    @State private var totalPins: Int = 0
    @State private var adjustedLength: Double = 0.0
    @State private var adjustedWidth: Double? = nil
    @State private var adjustedHeight: Double = 0.0
    @State private var showAdjustedDimensionsAlert = false
    @State private var showSettingsView = false
    @State private var showSizeWarningAlert = false
    
    var body: some View {
        VStack {
            Text("TrussCalc")
                .font(.largeTitle)
                .bold()
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            //            Text("Pour une structure autoportée ou une arche")
            //                .font(.subheadline)
            //                .padding(.top, 20)
            
            Picker("Type de structure", selection: $structureType) {
                ForEach(StructureType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Longueur (m)")
                        .font(.headline)
                    TextField("Longueur", text: $length)
                        .foregroundColor(.primary)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1))
                }
                .onChange(of: length) { newValue in
                    length = newValue.replacingOccurrences(of: ",", with: ".")
                    checkForSizeWarning()
                }
                
                if structureType == .autoportee {
                    VStack(alignment: .leading) {
                        Text("Largeur (m)")
                            .font(.headline)
                        TextField("Largeur", text: $width)
                            .foregroundColor(.primary)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1))
                    }
                    .onChange(of: width) { newValue in
                        width = newValue.replacingOccurrences(of: ",", with: ".")
                        checkForSizeWarning()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Hauteur (m)")
                        .font(.headline)
                    TextField("Hauteur", text: $height)
                        .foregroundColor(.primary)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1))
                }
                .onChange(of: height) { newValue in
                    height = newValue.replacingOccurrences(of: ",", with: ".")
                }
            }
            .padding(.horizontal)
            
            
            
            Button(action: {
                hideKeyboard()
                calculateTruss()
            }) {
                HStack{
                    Text("Calculate Truss")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(7)
                        .background(Color.blue)
                        .cornerRadius(8)
                    Button(action: {
                        showSettingsView.toggle()
                    }) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    }
                }
            }
            .padding()
            //            .alert(isPresented: $showAdjustedDimensionsAlert) {
            //                Alert(
            //                    title: Text("Dimensions Ajustées"),
            //                    message: Text("Les dimensions ont été ajustées aux valeurs réalisables les plus proches:\n\nLongueur: \(adjustedLength) m\n\(structureType == .autoportee ? "Largeur: \(adjustedWidth ?? 0) m\n" : "")Hauteur: \(adjustedHeight) m"),
            //                    dismissButton: .default(Text("OK"))
            //                )
            //            }
            
            if trussCount.isEmpty {
                Text("Spécifier les dimensions")
                    .foregroundColor(.primary)
                    .padding()
            } else {
                List {
                    Section(header: Text("Elements Eurotruss")) {
                        ForEach(trussCount.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            let element = eurotrussFD34.first { $0.name == key.split(separator: " ").first! }
                            let weight = element?.weight ?? 0.0
                            let volume = (element?.length ?? 0.0) * (element?.width ?? 0.0) * (element?.height ?? 0.0)
                            Text("\(key): \(value) ")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Section(header: Text("Total")) {
                        Text("Poids Total: \(totalWeight, specifier: "%.2f") kg")
                            .foregroundColor(.primary)
                        Text("Volume Total: \(totalVolume, specifier: "%.2f") m³")
                            .foregroundColor(.primary)
                        Text("Total Goupilles/Sécu: \(totalPins)")
                            .foregroundColor(.primary)
                    }
                }
                .listStyle(PlainListStyle())
                .padding()
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)  // Force dark mode for the entire view
//        .alert(isPresented: $showSizeWarningAlert) {
//            Alert(
//                title: Text("Avertissement de dimension"),
//                message: Text("La longueur ou la largeur spécifiée est supérieure à 12 mètres. La structure nécessitera un angle en 'T' pour fournir un support supplémentaire."),
//                dismissButton: .default(Text("OK"))
//            )
//        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView(stockManager: stockManager)
        }
    }
    
    func checkForSizeWarning() {
        if let lengthValue = Double(length), lengthValue > 12 {
            showSizeWarningAlert = true
        } else if structureType == .autoportee, let widthValue = Double(width), widthValue > 12 {
            showSizeWarningAlert = true
        } else {
            showSizeWarningAlert = false
        }
    }
    
    func calculateTruss() {
        guard let length = Double(length), let height = Double(height) else {
            // Handle invalid input
            return
        }
        
        let widthValue = structureType == .autoportee ? Double(width) : nil
        
        selectedTruss = []
        trussCount = [:]
        totalWeight = 0.0
        totalVolume = 0.0
        totalPins = 0
        
        switch structureType {
        case .autoportee:
            guard let width = widthValue else {
                // Handle invalid input for width
                return
            }
            let (adjustedLength, adjustedWidth, adjustedHeight) = TrussCalculator.adjustDimensions(length: length, width: width, height: height, trussList: eurotrussFD34)
            self.adjustedLength = adjustedLength
            self.adjustedWidth = adjustedWidth
            self.adjustedHeight = adjustedHeight
            self.length = String(format: "%.2f", adjustedLength)
            self.width = String(format: "%.2f", adjustedWidth ?? 0)
            self.height = String(format: "%.2f", adjustedHeight)
            
            self.showAdjustedDimensionsAlert = true
            TrussCalculator.calculateAutoportee(
                length: adjustedLength,
                width: adjustedWidth!,
                height: adjustedHeight,
                trussList: eurotrussFD34,
                selectedTruss: &selectedTruss,
                trussCount: &trussCount,
                totalWeight: &totalWeight,
                totalVolume: &totalVolume,
                totalPins: &totalPins
            )
        case .arche:
            let (adjustedLength, _, adjustedHeight) = TrussCalculator.adjustDimensions(length: length, width: nil, height: height, trussList: eurotrussFD34)
            self.adjustedLength = adjustedLength
            self.adjustedHeight = adjustedHeight
            self.length = String(format: "%.2f", adjustedLength)
            self.height = String(format: "%.2f", adjustedHeight)
            
            self.showAdjustedDimensionsAlert = true
            TrussCalculator.calculateArche(
                length: adjustedLength,
                height: adjustedHeight,
                trussList: eurotrussFD34,
                selectedTruss: &selectedTruss,
                trussCount: &trussCount,
                totalWeight: &totalWeight,
                totalVolume: &totalVolume,
                totalPins: &totalPins
            )
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
