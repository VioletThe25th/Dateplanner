//
//  DatePickerView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/20.
//

import SwiftUI
import MapKit

let unselectedLocationToken = "__unselected_location__"

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

    private var currencyMenu: some View {
        HStack(spacing: itemSpacing) {
            ForEach(CurrencyOption.allCases) { currency in
                let isHovered = hoveredCurrency == currency

                Text(currency.rawValue)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isHovered ? Color.black.opacity(0.92) : Color.white.opacity(0.92))
                    .frame(width: itemSize, height: itemSize)
                    .background(
                        Circle()
                            .fill(isHovered ? Color.white : Color.white.opacity(0.10))
                    )
            }
        }
        .padding(menuPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .offset(y: itemSize + 24)
        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .bottomTrailing)))
    }

    var body: some View {
        Text(selectedCurrency.rawValue)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.92))
            .frame(width: 42, height: 42)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .overlay(alignment: .bottomTrailing) {
                if isExpanded {
                    currencyMenu
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

private struct MoodChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.white : Color.white.opacity(0.10))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(isSelected ? 0.0 : 0.16), lineWidth: 1)
                )
                .foregroundStyle(isSelected ? Color.black.opacity(0.92) : Color.white.opacity(0.86))
        }
        .buttonStyle(.plain)
    }
}

private struct PickerSectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.90))
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.10))
                    )

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.60))
        }
    }
}

private struct MapPreview: View {
    @EnvironmentObject private var localization: LocalizationManager
    let isPreview: Bool
    let selectedLocation: String
    let selectedLatitude: Double?
    let selectedLongitude: Double?
    let radius: CLLocationDistance
    @Binding var position: MapCameraPosition

    var body: some View {
        ZStack {
            if isPreview {
                placeholder(title: localization.text("datePicker.map.disabledPreview"))
            } else if let lat = selectedLatitude, let lon = selectedLongitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                Map(position: $position) {
                    MapCircle(center: coordinate, radius: radius)
                        .foregroundStyle(.blue.opacity(0.14))
                        .stroke(.blue.opacity(0.55), lineWidth: 2)

                    Marker(selectedLocation, coordinate: coordinate)
                }
                .mapStyle(.standard(elevation: .realistic))
                .environment(\.colorScheme, .dark)
                .allowsHitTesting(false)
            } else {
                placeholder(title: localization.text("datePicker.map.previewPlaceholder"))
            }
        }
        .frame(height: 146)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func placeholder(title: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))

            VStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.72))

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.58))
            }
        }
    }
}

struct DatePickerView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @State private var budget: Double = 5000
    @State private var selectedBudget: Int = 5000
    @State private var selectedCurrency: CurrencyOption = .yen
    @State private var selectedLocation: String = unselectedLocationToken
    @State private var selectedLocationRadius: CLLocationDistance = 1500
    @State private var selectedLatitude: Double? = nil
    @State private var selectedLongitude: Double? = nil
    @State private var mapPreviewPosition: MapCameraPosition = .automatic

    @State private var selectedMood: DateMood? = nil
    @State private var userIdeas: String = ""

    @State private var places: [PlaceCandidate] = []
    @State private var generatedPlan: GeneratedDatePlan? = nil
    @State private var showGeneratedPlan = false
    @State private var isGeneratingPlan = false
    @State private var generationErrorMessage: String? = nil
    @State private var hasInitializedBudgetState = false
    @FocusState private var isIdeasFieldFocused: Bool

    private let mapSearchService = MapSearchService()
    private let dateService = DateGenerationService()

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

    private var isReadyToGenerate: Bool {
        selectedLatitude != nil && selectedLongitude != nil && selectedMood != nil && !isLocationUnselected
    }

    private var locationSummaryText: String {
        isLocationUnselected
        ? localization.text("datePicker.location.areaNotSelected")
        : "\(selectedLocation) · \(Int(selectedLocationRadius))m"
    }

    private var readinessText: String {
        if isReadyToGenerate {
            return localization.text("datePicker.readiness.ready")
        }

        var missing: [String] = []
        if selectedLatitude == nil || selectedLongitude == nil {
            missing.append(localization.text("datePicker.readiness.location"))
        }
        if selectedMood == nil {
            missing.append(localization.text("datePicker.readiness.mood"))
        }

        if missing.isEmpty {
            return localization.text("datePicker.readiness.adjust")
        } else {
            return localization.text("datePicker.readiness.chooseFormat", localizedMissingList(missing))
        }
    }

    private var isLocationUnselected: Bool {
        selectedLocation == unselectedLocationToken
    }

    private func localizedMissingList(_ values: [String]) -> String {
        if values.count <= 1 {
            return values.first ?? ""
        }

        let separator = localization.language == .french ? " et "
            : localization.language == .spanish ? " y "
            : localization.language == .japanese ? "と"
            : localization.language == .chinese ? "和"
            : localization.language == .korean ? " 및 "
            : " and "

        return values.joined(separator: separator)
    }

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                PickerSectionHeader(
                    icon: "dollarsign.circle.fill",
                    title: localization.text("datePicker.section.budget.title"),
                    subtitle: localization.text("datePicker.section.budget.subtitle")
                )

                Spacer(minLength: 16)

                CurrencyPressPicker(selectedCurrency: $selectedCurrency)
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(selectedCurrency.rawValue)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.86))

                Text("\(selectedBudget)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            CustomSlider(value: $budget, range: budgetRange)

            HStack {
                Text("\(selectedCurrency.rawValue)\(Int(budgetRange.lowerBound))")
                Spacer()
                Text("\(selectedCurrency.rawValue)\(Int(budgetRange.upperBound))")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.48))
        }
        .cardBackground()
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PickerSectionHeader(
                icon: "mappin.circle.fill",
                title: localization.text("datePicker.section.location.title"),
                subtitle: localization.text("datePicker.section.location.subtitle")
            )

            NavigationLink {
                LocationSelectionView(
                    selectedLocation: $selectedLocation,
                    selectedLocationRadius: $selectedLocationRadius,
                    selectedLatitude: $selectedLatitude,
                    selectedLongitude: $selectedLongitude
                )
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isLocationUnselected ? localization.text("datePicker.location.unselected") : selectedLocation)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(isLocationUnselected ? localization.text("datePicker.location.openMap") : localization.text("datePicker.location.radiusFormat", Int(selectedLocationRadius)))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.56))
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white.opacity(0.72))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Text(locationSummaryText)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.50))

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
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PickerSectionHeader(
                icon: "heart.circle.fill",
                title: localization.text("datePicker.section.mood.title"),
                subtitle: localization.text("datePicker.section.mood.subtitle")
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DateMood.allCases) { mood in
                        MoodChip(title: localization.moodName(mood), isSelected: selectedMood == mood) {
                            if selectedMood == mood {
                                selectedMood = nil
                            } else {
                                selectedMood = mood
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .cardBackground()
    }

    private var ideasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PickerSectionHeader(
                icon: "lightbulb.max.fill",
                title: localization.text("datePicker.section.ideas.title"),
                subtitle: localization.text("datePicker.section.ideas.subtitle")
            )

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)

                if userIdeas.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(localization.text("datePicker.ideas.placeholder"))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.38))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $userIdeas)
                    .scrollContentBackground(.hidden)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.92))
                    .focused($isIdeasFieldFocused)
                    .frame(minHeight: 104)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .frame(minHeight: 104)

            HStack {
                Label(localization.text("datePicker.ideas.charactersFormat", userIdeas.count), systemImage: "character.cursor.ibeam")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.46))

                Spacer()

                if !userIdeas.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(localization.text("common.optional"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.50))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                }
            }
        }
        .cardBackground()
    }

    private var bottomCTA: some View {
        VStack(spacing: 10) {
            Button {
                startDateGeneration()
            } label: {
                HStack(spacing: 12) {
                    Text(localization.text("datePicker.cta.generate"))
                        .font(.headline.weight(.semibold))

                    Image(systemName: "arrow.right")
                        .font(.headline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundStyle(.black.opacity(isReadyToGenerate ? 0.92 : 0.45))
                .background(
                    (isReadyToGenerate ? Color.white : Color.white.opacity(0.26)),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(isReadyToGenerate ? 0.22 : 0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(isReadyToGenerate ? 0.18 : 0.0), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(PressScaleStyle())
            .disabled(!isReadyToGenerate)

            Text(readinessText)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.54))
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = proxy.size.width >= 768 ? 32.0 : 20.0

            ZStack {
                BackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerSection
                        budgetSection
                        locationSection
                        moodSection
                        ideasSection
                    }
                    .frame(maxWidth: 620)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 146)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isIdeasFieldFocused = false
            }
            .safeAreaInset(edge: .bottom) {
                bottomCTA
                    .frame(maxWidth: 620)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
            }
            .onAppear {
                if !hasInitializedBudgetState {
                    budget = defaultBudget(for: selectedCurrency)
                    selectedBudget = Int(budget)
                    hasInitializedBudgetState = true
                }
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
            .onChange(of: isGeneratingPlan) { _, newValue in
                if !newValue, generatedPlan != nil {
                    showGeneratedPlan = true
                }
            }
            .fullScreenCover(isPresented: $isGeneratingPlan) {
                DateGenerationLoadingView()
            }
            .fullScreenCover(isPresented: $showGeneratedPlan, onDismiss: {
                generatedPlan = nil
            }) {
                generatedPlanDestination
            }
            .alert(localization.text("datePicker.error.title"), isPresented: generationErrorBinding) {
                Button(localization.text("common.ok"), role: .cancel) { }
            } message: {
                Text(generationErrorMessage ?? localization.text("common.unknownError"))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        OptionsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.88))
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button(localization.text("common.done")) {
                        isIdeasFieldFocused = false
                    }
                    .font(.subheadline.weight(.semibold))
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.text("datePicker.title"))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.80))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(localization.text("datePicker.heading"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(localization.text("datePicker.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    summaryPill(icon: "banknote.fill", text: "\(selectedCurrency.rawValue)\(selectedBudget)")
                    summaryPill(icon: "mappin.and.ellipse", text: isLocationUnselected ? localization.text("datePicker.header.noAreaYet") : selectedLocation)
                    summaryPill(icon: "heart.text.square.fill", text: selectedMood.map(localization.moodName) ?? localization.text("datePicker.header.noMoodYet"))
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func summaryPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.76))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var generationErrorBinding: Binding<Bool> {
        Binding(
            get: { generationErrorMessage != nil },
            set: { if !$0 { generationErrorMessage = nil } }
        )
    }

    @ViewBuilder
    private var generatedPlanDestination: some View {
        if let generatedPlan {
            DateGenerationPlanView(plan: generatedPlan)
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                ProgressView()
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

    private func startDateGeneration() {
        guard let requestData = buildRequestData() else { return }

        generationErrorMessage = nil
        isGeneratingPlan = true

        Task {
            let startedAt = Date()

            do {
                let results = try await mapSearchService.searchPlaces(for: requestData)

                await MainActor.run {
                    places = results
                    print(requestData.debugDescription)
                    print("Found \(results.count) places")
                    for (index, place) in results.enumerated() {
                        print("\(index + 1). \(place.name) | \(place.category) | \(Int(place.distanceFromCenter))m | \(place.address)")
                    }
                }

                let plan = try await dateService.generateDatePlan(request: requestData, places: results)

                let elapsed = Date().timeIntervalSince(startedAt)
                if elapsed < 2 {
                    let remaining = 2 - elapsed
                    try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                }

                await MainActor.run {
                    generatedPlan = plan
                    isGeneratingPlan = false
                }
            } catch {
                let elapsed = Date().timeIntervalSince(startedAt)
                if elapsed < 2 {
                    let remaining = 2 - elapsed
                    try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                }

                await MainActor.run {
                    generationErrorMessage = error.localizedDescription
                    isGeneratingPlan = false
                        }
                    }
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

    private func buildRequestData() -> DateRequestData? {
        guard
            let latitude = selectedLatitude,
            let longitude = selectedLongitude,
            let mood = selectedMood,
            !isLocationUnselected
        else {
            return nil
        }

        return DateRequestData(
            budget: selectedBudget,
            currency: selectedCurrency,
            locationName: selectedLocation,
            latitude: latitude,
            longitude: longitude,
            radius: selectedLocationRadius,
            mood: mood,
            ideas: userIdeas
        )
    }
}

#Preview {
    NavigationStack {
        DatePickerView(debugMock: true)
            .environmentObject(LocalizationManager.preview)
    }
}
