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

struct DatePickerView: View {
    @State private var budget: Double = 5000
    @State private var selectedBudget: Int = 5000
    @State private var selectedLocation: String = "Choose an area"
    @State private var selectedLocationRadius: CLLocationDistance = 1500
    @State private var selectedLatitude: Double? = nil
    @State private var selectedLongitude: Double? = nil
    @State private var mapPreviewPosition: MapCameraPosition = .automatic
    
    @State private var selectedMood: DateMood? = nil
    @State private var userIdeas: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                /// Background
                LinearGradient(
                    colors: [Color(red: 12/255, green: 12/255, blue: 14/255),
                             Color(red: 22/255, green: 22/255, blue: 26/255)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                RadialGradient(
                    colors: [
                        Color.gray.opacity(0.1),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
                RadialGradient(
                    colors: [
                        Color.purple.opacity(0.1),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 200
                )
                .blur(radius: 35)
                .offset(x: 50   )
                .ignoresSafeArea()
                RadialGradient(
                    colors: [
                        Color.red.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
                .blur(radius: 35)
                .offset(x: -50)
                .ignoresSafeArea()
                RadialGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.clear
                    ],
                    center: .bottom,
                    startRadius: 0,
                    endRadius: 200
                )
                .blur(radius: 35)
                .offset(x: 50)
                .ignoresSafeArea()
                
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
                    
                    /// Budget view
                    VStack {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundStyle(Color.yellow.opacity(0.8))
                            Text("Budget")
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("¥\(selectedBudget)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                        
                        CustomSlider(value: $budget, range: 2000...10000)
                        
                        HStack {
                            Text("2000¥")
                            Spacer()
                            Text("10000¥")
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
                    )
                    
                    // localisation view
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
                        
                        ZStack {
                            if let lat = selectedLatitude, let lon = selectedLongitude {
                                Map(position: $mapPreviewPosition) {
                                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    
                                    MapCircle(center: coordinate, radius: selectedLocationRadius)
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
                        
                        /// insert Map here
                        
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
                    )
                    
                    
                }
                .onAppear {
                    selectedBudget = Int(budget)
                    updateMapPreviewCamera()
                }
                .onChange(of: budget) { _, newValue in
                    selectedBudget = Int(newValue)
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
    private func updateMapPreviewCamera() {
        guard let lat = selectedLatitude, let lon = selectedLongitude else {
            mapPreviewPosition = .automatic
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let radiusInKilometers = max(selectedLocationRadius / 1000, 0.2)
        let latitudeDelta = max(radiusInKilometers * 0.018 * 2.4, 0.01)
        let longitudeDelta = max(radiusInKilometers * 0.022 * 2.4, 0.01)
        
        withAnimation(.easeInOut(duration: 0.35)) {
            mapPreviewPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: latitudeDelta,
                        longitudeDelta: longitudeDelta
                    )
                )
            )
        }
    }
}

#Preview {
    DatePickerView()
}
