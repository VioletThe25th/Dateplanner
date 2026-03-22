
import SwiftUI
import Combine
import CoreLocation
import MapKit

final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .query]
    }
    
    func updateQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            results = []
            return
        }
        
        completer.queryFragment = trimmedQuery
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }
}

final class LocationSelectionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var suggestedAreas: [String] = ["Near me", "Loading nearby areas..."]
    @Published var hasLocationAccess = false
    @Published var currentAreaName: String? = nil
    @Published var isLoadingLocation = false
    
    private let locationManager = CLLocationManager()
    private var loadingTimeoutTask: Task<Void, Never>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            isLoadingLocation = true
            suggestedAreas = ["Near me"]
            locationManager.requestWhenInUseAuthorization()
            startLoadingTimeout()
        case .authorizedWhenInUse, .authorizedAlways:
            hasLocationAccess = true
            isLoadingLocation = true
            suggestedAreas = ["Near me"]
            locationManager.requestLocation()
            startLoadingTimeout()
        case .denied, .restricted:
            hasLocationAccess = false
            isLoadingLocation = false
            currentAreaName = nil
            suggestedAreas = ["Near me", "Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"]
        @unknown default:
            hasLocationAccess = false
            isLoadingLocation = false
            currentAreaName = nil
            suggestedAreas = ["Near me", "Tokyo"]
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            hasLocationAccess = true
            isLoadingLocation = true
            suggestedAreas = ["Near me"]
            manager.requestLocation()
            startLoadingTimeout()
        case .denied, .restricted:
            hasLocationAccess = false
            isLoadingLocation = false
            currentAreaName = nil
            suggestedAreas = ["Near me", "Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"]
        case .notDetermined:
            hasLocationAccess = false
            isLoadingLocation = false
            currentAreaName = nil
            suggestedAreas = ["Near me"]
        @unknown default:
            hasLocationAccess = false
            isLoadingLocation = false
            currentAreaName = nil
            suggestedAreas = ["Near me", "Tokyo"]
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                guard let request = MKReverseGeocodingRequest(location: location) else {
                    self.loadingTimeoutTask?.cancel()
                    self.isLoadingLocation = false
                    self.currentAreaName = nil
                    self.suggestedAreas = ["Near me", "Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"]
                    return
                }
                
                let mapItems = try await request.mapItems
                
                guard let mapItem = mapItems.first else {
                    self.loadingTimeoutTask?.cancel()
                    self.isLoadingLocation = false
                    self.currentAreaName = nil
                    self.suggestedAreas = ["Near me", "Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"]
                    return
                }
                
                var areas: [String] = ["Near me"]
                
                func add(_ value: String?) {
                    guard let value, !value.isEmpty, !areas.contains(value) else { return }
                    areas.append(value)
                }
                
                add(mapItem.address?.shortAddress)
                add(mapItem.addressRepresentations?.cityWithContext)
                add(mapItem.address?.fullAddress)
                
                if areas.count == 1 {
                    areas.append(contentsOf: ["Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"])
                }
                
                self.loadingTimeoutTask?.cancel()
                self.isLoadingLocation = false
                self.suggestedAreas = areas
                self.currentAreaName = areas.first(where: { $0 != "Near me" })
            } catch {
                self.loadingTimeoutTask?.cancel()
                self.isLoadingLocation = false
                self.currentAreaName = nil
                self.suggestedAreas = ["Near me", "Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"]
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loadingTimeoutTask?.cancel()
        hasLocationAccess = false
        isLoadingLocation = false
        currentAreaName = nil
        suggestedAreas = ["Near me", "Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"]
    }
    
    private func startLoadingTimeout() {
        loadingTimeoutTask?.cancel()
        
        loadingTimeoutTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(4))
            
            guard let self, self.isLoadingLocation else { return }
            
            self.isLoadingLocation = false
            self.currentAreaName = nil
            self.suggestedAreas = ["Near me", "Tokyo", "Shibuya, Tokyo", "Shinjuku, Tokyo"]
        }
    }
}

struct LocationSelectionView: View {
    @Binding var selectedLocation: String
    @Binding var selectedLocationRadius: CLLocationDistance
    @Binding var selectedLatitude: Double?
    @Binding var selectedLongitude: Double?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LocationSelectionViewModel()
    @StateObject private var searchService = LocationSearchService()
    @State private var searchText: String = ""
    @State private var pendingSelection: String = ""
    @State private var selectionSource: String = ""
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var searchRadius: CLLocationDistance = 1500
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 10/255, green: 14/255, blue: 24/255),
                    Color(red: 20/255, green: 28/255, blue: 45/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            Map(position: $mapCameraPosition) {
                if let selectedCoordinate {
                    MapCircle(center: selectedCoordinate, radius: searchRadius)
                        .foregroundStyle(.blue.opacity(0.14))
                        .stroke(.blue.opacity(0.55), lineWidth: 2)
                    
                    Marker("Selected area", coordinate: selectedCoordinate)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color.black.opacity(0.38),
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.72))
                        
                        TextField("Search for a place (Shibuya, Tokyo...)", text: $searchText)
                            .foregroundStyle(.white)
                            .onChange(of: searchText) { _, newValue in
                                searchService.updateQuery(newValue)
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
                    
                    if !pendingSelection.isEmpty || !selectedLocation.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: selectionSource == "search" ? "magnifyingglass.circle.fill" : "mappin.circle.fill")
                                .foregroundStyle(.white.opacity(0.92))
                            
                            Text(pendingSelection.isEmpty ? selectedLocation : pendingSelection)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.92))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)

                // Suggestions/search results directly under search/selection area
                Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Suggested areas" : "Search results")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            if searchService.results.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.white.opacity(0.7))
                                    Text("No results yet")
                                        .foregroundStyle(.white.opacity(0.72))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            } else {
                                ForEach(searchService.results, id: \.self) { result in
                                    let subtitle = result.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
                                    let selectionLabel = subtitle.isEmpty ? result.title : "\(result.title), \(subtitle)"
                                    
                                    Button {
                                        pendingSelection = selectionLabel
                                        selectionSource = "search"
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.title)
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                            
                                            if !subtitle.isEmpty {
                                                Text(subtitle)
                                                    .font(.caption)
                                                    .foregroundStyle(.white.opacity(0.68))
                                                    .lineLimit(1)
                                            }
                                        }
                                        .frame(width: 220, alignment: .leading)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .fill(pendingSelection == selectionLabel ? Color.white.opacity(0.22) : Color.white.opacity(0.10))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .stroke(Color.white.opacity(pendingSelection == selectionLabel ? 0.22 : 0.10), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.suggestedAreas.filter { $0 != "Near me" && $0 != "Loading nearby areas..." }, id: \.self) { area in
                                Button {
                                    pendingSelection = area
                                    selectionSource = "suggested"
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: pendingSelection == area ? "checkmark.circle.fill" : "mappin.circle.fill")
                                            .foregroundStyle(.white.opacity(0.92))
                                        
                                        Text(area)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(pendingSelection == area ? Color.white.opacity(0.22) : Color.white.opacity(0.10))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.white.opacity(pendingSelection == area ? 0.22 : 0.10), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
            }
            VStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 12) {
                    if (!selectedLocation.isEmpty && selectedLocation != "Choose an area") || (!pendingSelection.isEmpty && pendingSelection != "Choose an area") {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Search radius")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.78))
                                
                                Spacer()
                                
                                Text("\(Int(searchRadius)) m")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.92))
                            }
                            
                            Slider(value: $searchRadius, in: 200...2000, step: 50)
                                .tint(.blue)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    
                    Button {
                        guard !pendingSelection.isEmpty else { return }
                        selectedLocation = pendingSelection
                        selectedLocationRadius = searchRadius
                        selectedLatitude = selectedCoordinate?.latitude
                        selectedLongitude = selectedCoordinate?.longitude
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.right")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.black.opacity(pendingSelection.isEmpty ? 0.42 : 0.92))
                            .frame(width: 54, height: 54)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(pendingSelection.isEmpty ? 0.22 : 0.82))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(pendingSelection.isEmpty ? 0.10 : 0.22), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(pendingSelection.isEmpty ? 0.0 : 0.18), radius: 18, x: 0, y: 10)
                    }
                    .disabled(pendingSelection.isEmpty)
                    .scaleEffect(pendingSelection.isEmpty ? 0.98 : 1)
                    .animation(.easeInOut(duration: 0.2), value: pendingSelection)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.requestLocation()
            pendingSelection = selectedLocation
            if selectedLocationRadius > 0 {
                searchRadius = selectedLocationRadius
            }
            updateMapPreview(for: selectedLocation)
        }
        .onChange(of: pendingSelection) { _, newValue in
            updateMapPreview(for: newValue)
        }
    }
    
    private func updateMapPreview(for query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            selectedCoordinate = nil
            mapCameraPosition = .automatic
            return
        }
        
        Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = trimmedQuery
            
            do {
                let response = try await MKLocalSearch(request: request).start()
                guard let item = response.mapItems.first else { return }
                
                await MainActor.run {
                    let coordinate = item.location.coordinate
                    
                    withAnimation(.easeInOut(duration: 0.45)) {
                        selectedCoordinate = coordinate
                        mapCameraPosition = .region(
                            MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            )
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedCoordinate = nil
                        mapCameraPosition = .automatic
                    }
                }
            }
        }
    }
}
#Preview {
    NavigationStack {
        LocationSelectionView(
            selectedLocation: .constant("Shibuya, Tokyo"),
            selectedLocationRadius: .constant(1500),
            selectedLatitude: .constant(35.6595),
            selectedLongitude: .constant(139.7005)
        )
    }
}
