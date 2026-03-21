//
//  DatePickerView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/20.
//


import SwiftUI
import _LocationEssentials
import MapKit

enum DateMood: String, CaseIterable, Identifiable {
    case chill = "Chill"
    case romantic = "Romantic"
    case fun = "Fun"
    case adventure = "Adventure"
    
    var id: String { rawValue }
}

enum CurrencyOption: String, CaseIterable, Identifiable {
    case yen = "¥"
    case dollar = "$"
    case euro = "€"
    
    var id: String { rawValue }
}

private struct CurrencyPressPicker: View {
    @Binding var selectedCurrency: CurrencyOption
    @State private var isExpanded = false
    @State private var hoveredCurrency: CurrencyOption? = nil

    private let itemSize: CGFloat = 40
    private let itemSpacing: CGFloat = 8
    private let menuPadding: CGFloat = 8

    private var menuWidth: CGFloat {
        let count = CGFloat(CurrencyOption.allCases.count)
        return (count * itemSize) + ((count - 1) * itemSpacing) + (menuPadding * 2)
    }

    var body: some View {
        Text(selectedCurrency.rawValue)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: 42, height: 42)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .overlay(alignment: .bottomTrailing) {
                if isExpanded {
                    HStack(spacing: itemSpacing) {
                        ForEach(CurrencyOption.allCases) { currency in
                            Text(currency.rawValue)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(currencyForeground(for: currency))
                                .frame(width: itemSize, height: itemSize)
                                .background(
                                    Circle()
                                        .fill(currencyBackground(for: currency))
                                )
                        }
                    }
                    .padding(menuPadding)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .offset(x: 0, y: itemSize + 25)
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .bottomTrailing)))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isExpanded {
                            isExpanded = true
                        }
                        hoveredCurrency = currency(at: value.location)
                    }
                    .onEnded { value in
                        if let currency = currency(at: value.location) {
                            selectedCurrency = currency
                        }
                        hoveredCurrency = nil
                        withAnimation(.easeOut(duration: 0.18)) {
                            isExpanded = false
                        }
                    }
            )
            .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }

    private func currencyForeground(for currency: CurrencyOption) -> Color {
        hoveredCurrency == currency ? Color.black.opacity(0.9) : Color.white.opacity(0.9)
    }

    private func currencyBackground(for currency: CurrencyOption) -> Color {
        hoveredCurrency == currency ? Color.white : Color.white.opacity(0.10)
    }

    private func currency(at location: CGPoint) -> CurrencyOption? {
        let menuHeight: CGFloat = itemSize + (menuPadding * 2)
        let menuMinX: CGFloat = 42 - menuWidth
        let menuMaxX: CGFloat = 42
        let menuMinY: CGFloat = 42 + 10
        let menuMaxY: CGFloat = menuMinY + menuHeight

        guard location.x >= menuMinX,
              location.x <= menuMaxX,
              location.y >= menuMinY,
              location.y <= menuMaxY else {
            return nil
        }

        let relativeX = location.x - menuMinX - menuPadding
        let slotWidth = itemSize + itemSpacing
        let index = Int(relativeX / slotWidth)

        guard index >= 0, index < CurrencyOption.allCases.count else { return nil }

        let slotStartX = CGFloat(index) * slotWidth
        let xInsideSlot = relativeX - slotStartX

        guard xInsideSlot >= 0, xInsideSlot <= itemSize else { return nil }

        return CurrencyOption.allCases[index]
    }
}

private struct MapPreview: View {
    let isPreview: Bool
    let selectedLocation: String
    let selectedLatitude: Double?
    let selectedLongitude: Double?
    let radius: CLLocationDistance
    @Binding var position: MapCameraPosition

    var body: some View {
        ZStack {
            if isPreview {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))

                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.75))

                    Text("Map disabled in Preview")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
            } else if let lat = selectedLatitude, let lon = selectedLongitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                Map(position: $position) {
                    MapCircle(center: coordinate, radius: radius)
                        .foregroundStyle(.blue.opacity(0.14))
                        .stroke(.blue.opacity(0.55), lineWidth: 2)

                    Marker(selectedLocation, coordinate: coordinate)
                }
                .mapStyle(.standard(elevation: .realistic))
                .allowsHitTesting(false)
            } else {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))

                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.75))

                    Text("Map preview will appear here")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct DatePickerView: View {
    @State private var budget: Double = 5000
    @State private var selectedBudget: Int = 5000
    @State private var selectedCurrency: CurrencyOption = .yen
    @State private var selectedLocation: String = "Choose an area"
    @State private var selectedLocationRadius: CLLocationDistance = 1500
    @State private var selectedLatitude: Double? = nil
    @State private var selectedLongitude: Double? = nil
    @State private var mapPreviewPosition: MapCameraPosition = .automatic
    
    @State private var selectedMood: DateMood? = nil
    @State private var userIdeas: String = ""
    
    #if DEBUG
    private let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    #else
    private let isPreview = false
    #endif

    init(debugMock: Bool = false) {
        if debugMock {
            _selectedLatitude = State(initialValue: 35.681236)
            _selectedLongitude = State(initialValue: 139.767125)
            _selectedLocation = State(initialValue: "Tokyo Station")
            _selectedLocationRadius = State(initialValue: 1000)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                /// Main view
                VStack (alignment: .leading){
                    
                    /// Title view
                    HStack {
                        Text("Create your date")
                            .font(.largeTitle)
                            .bold()
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    HStack {
                        Text("What are you in the mood for? ")
                        Image(systemName: "smallcircle.circle.fill")
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    ScrollView {
                        /// Budget view
                        VStack {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundStyle(Color.yellow.opacity(0.8))
                                Text("Budget")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.8))
                                Spacer()
                                CurrencyPressPicker(selectedCurrency: $selectedCurrency)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(selectedCurrency.rawValue)\(selectedBudget)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.6))
                            
                            CustomSlider(value: $budget, range: budgetRange)
                            
                            HStack {
                                Text("\(Int(budgetRange.lowerBound))\(selectedCurrency.rawValue)")
                                Spacer()
                                Text("\(Int(budgetRange.upperBound))\(selectedCurrency.rawValue)")
                            }
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        }
                        .cardBackground()
                        
                        /// localisation view
                        VStack {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(Color.yellow.opacity(0.8))
                                NavigationLink {
                                    LocationSelectionView(
                                        selectedLocation: $selectedLocation,
                                        selectedLocationRadius: $selectedLocationRadius,
                                        selectedLatitude: $selectedLatitude,
                                        selectedLongitude: $selectedLongitude
                                    )
                                } label: {
                                    Text("Location")
                                        .font(.title)
                                        .foregroundStyle(.white.opacity(0.8))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Current area: \(selectedLocation) • \(Int(selectedLocationRadius))m")
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            MapPreview(
                                isPreview: isPreview,
                                selectedLocation: selectedLocation,
                                selectedLatitude: selectedLatitude,
                                selectedLongitude: selectedLongitude,
                                radius: selectedLocationRadius,
                                position: $mapPreviewPosition
                            )
                        }
                        .cardBackground()
                        
                        /// Mood view
                        VStack {
                            HStack {
                                Image(systemName: "heart.circle")
                                    .foregroundStyle(Color.red.opacity(0.8))
                                Text("Mood")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack (spacing: 10) {
                                    ForEach(DateMood.allCases) { mood in
                                        let isSelected = (selectedMood == mood)
                                        Button {
                                            if isSelected {
                                                selectedMood = nil
                                            } else {
                                                selectedMood = mood
                                            }
                                        } label: {
                                            Text(mood.rawValue)
                                                .font(.title2.weight(.semibold))
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.12))
                                                )
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.white.opacity(isSelected ? 0.0 : 0.25), lineWidth: 1)
                                                )
                                                .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.85))
                                        }
                                        .buttonStyle(.plain)
                                        
                                    }
                                }
                            }
                        }
                        .cardBackground()
                    }
                    .padding(.top, 20)
                    
                }
                .onAppear {
                    budget = defaultBudget(for: selectedCurrency)
                    selectedBudget = Int(budget)
                    updateMapPreviewCamera()
                }
                .onChange(of: budget) { _, newValue in
                    selectedBudget = Int(newValue)
                }
                .onChange(of: selectedCurrency) { oldValue, newValue in
                    if oldValue != newValue {
                        budget = defaultBudget(for: newValue)
                        selectedBudget = Int(budget)
                    }
                }
                .onChange(of: selectedLatitude) { _, _ in
                    updateMapPreviewCamera()
                }
                .onChange(of: selectedLongitude) { _, _ in
                    updateMapPreviewCamera()
                }
                .onChange(of: selectedLocationRadius) { _, _ in
                    updateMapPreviewCamera()
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        OptionsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title)
                    }
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }
    
    private var budgetRange: ClosedRange<Double> {
        switch selectedCurrency {
        case .yen:
            return 2000...10000
        case .dollar, .euro:
            return 20...100
        }
    }

    private func defaultBudget(for currency: CurrencyOption) -> Double {
        switch currency {
        case .yen:
            return 5000
        case .dollar, .euro:
            return 50
        }
    }
    
    private func updateMapPreviewCamera() {

        guard let lat = selectedLatitude, let lon = selectedLongitude else {
            mapPreviewPosition = .automatic
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let radiusInKilometers = max(selectedLocationRadius / 1000, 0.2)
        let latitudeDelta = max(radiusInKilometers * 0.018 * 2.4, 0.01)
        let longitudeDelta = max(radiusInKilometers * 0.022 * 2.4, 0.01)

        let newRegion: MapCameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: latitudeDelta,
                    longitudeDelta: longitudeDelta
                )
            )
        )

        withAnimation(.easeInOut(duration: 0.35)) {
            mapPreviewPosition = newRegion
        }
    }
}

#Preview {
    DatePickerView()
}

