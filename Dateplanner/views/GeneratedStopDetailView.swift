//
//  GeneratedStopDetailView.swift
//  Dateplanner
//
//  Created by Codex on 2026/03/24.
//

import SwiftUI
import MapKit

struct GeneratedStopDetailView: View {
    let stop: GeneratedDateStop

    @Environment(\.openURL) private var openURL
    @State private var mapPosition: MapCameraPosition

    init(stop: GeneratedDateStop) {
        self.stop = stop

        let coordinate = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )
        _mapPosition = State(initialValue: .region(region))
    }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
    }

    private var hasValidCoordinate: Bool {
        CLLocationCoordinate2DIsValid(coordinate) && (stop.latitude != 0 || stop.longitude != 0)
    }

    private var categoryText: String? {
        guard let category = stop.category, !category.isEmpty else { return nil }
        return displayName(for: category)
    }

    private var priceText: String {
        if let estimatedPrice = stop.estimatedPrice {
            return "¥\(estimatedPrice)"
        } else {
            return "Flexible"
        }
    }

    private var addressText: String {
        if let address = stop.address, !address.isEmpty {
            return address
        } else {
            return "Address unavailable"
        }
    }

    private var bodyContent: some View {
        GeometryReader { proxy in
            let horizontalPadding = proxy.size.width >= 768 ? 32.0 : 20.0

            ZStack {
                BackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        heroSection

                        editorialCard
                        locationSection
                        quickFactsSection
                        reasonSection
                    }
                    .frame(maxWidth: 620)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
    }

    var body: some View {
        bodyContent
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
    }

    private var heroSection: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .bottomLeading) {
                heroImage(width: width, height: height)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.02),
                        Color.black.opacity(0.20),
                        Color.black.opacity(0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: width, height: height)

                RadialGradient(
                    colors: [Color.cyan.opacity(0.22), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 170
                )
                .frame(width: width, height: height)

                RadialGradient(
                    colors: [Color.pink.opacity(0.18), Color.clear],
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: 190
                )
                .frame(width: width, height: height)

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        HStack(spacing: 8) {
                            heroTag(icon: "sparkles", text: categoryText ?? "Selected stop")
                            heroTag(icon: "yensign.circle.fill", text: priceText)
                        }

                        Spacer(minLength: 12)

                        Text("Stop \(max(stop.order, 1))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.black.opacity(0.92))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white)
                            )
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(stop.name)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(stop.description)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.74))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(24)
            }
            .frame(width: width, height: height)
        }
        .frame(height: 370)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.20), radius: 20, x: 0, y: 12)
        .frame(maxWidth: .infinity)
    }

    private func heroImage(width: CGFloat, height: CGFloat) -> some View {
        Group {
            if let imageURL = stop.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage(width: width, height: height)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                    case .failure:
                        placeholderImage(width: width, height: height)
                    @unknown default:
                        placeholderImage(width: width, height: height)
                    }
                }
            } else {
                placeholderImage(width: width, height: height)
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }

    private func placeholderImage(width: CGFloat, height: CGFloat) -> some View {
        let gradient = gradientColors(for: stop.category?.lowercased() ?? "")

        return ZStack {
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 94, height: 94)
                .blur(radius: 0.4)

            Image(systemName: iconName(for: stop.category?.lowercased() ?? ""))
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
        }
        .frame(width: width, height: height)
    }

    private var editorialCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stop Spotlight")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.76))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 10) {
                Text("A place chosen to keep the date feeling natural, balanced, and memorable.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Label(addressText, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.64))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 12)
    }

    private var quickFactsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Quick Facts")

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    factCard(
                        title: "Category",
                        value: categoryText ?? "Custom",
                        icon: iconName(for: stop.category?.lowercased() ?? "")
                    )
                    factCard(
                        title: "Estimated",
                        value: priceText,
                        icon: "banknote.fill"
                    )
                }

                if hasValidCoordinate {
                    factWideCard(
                        title: "Coordinates",
                        value: "\(String(format: "%.5f", stop.latitude)), \(String(format: "%.5f", stop.longitude))",
                        icon: "location.circle.fill"
                    )
                }
            }
        }
        .cardBackground()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func factCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.48))

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func factWideCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Why It Works")

            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.42))

                Text(stop.reason)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Location Preview")

            if hasValidCoordinate {
                ZStack(alignment: .bottomLeading) {
                    Map(position: $mapPosition) {
                        Marker(stop.name, coordinate: coordinate)
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .environment(\.colorScheme, .dark)
                    .allowsHitTesting(false)
                    .frame(height: 260)

                    HStack(spacing: 8) {
                        Image(systemName: "map.fill")
                        Text("Tap to open in Maps")
                            .lineLimit(1)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.94))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(16)
                }
                .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .onTapGesture {
                    openInAppleMaps()
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

                HStack(spacing: 6) {
                    Text("Prefer Google Maps?")
                        .foregroundStyle(.white.opacity(0.50))

                    Button {
                        openInGoogleMaps()
                    } label: {
                        Text("Open there")
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    .buttonStyle(.plain)
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 180)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "map.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.72))

                            Text("Location preview unavailable")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.56))
                        }
                    }
            }
        }
        .cardBackground()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
    }

    private func heroTag(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.94))
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func openInAppleMaps() {
        let baseURL = "http://maps.apple.com/"

        if hasValidCoordinate {
            let encodedName = stop.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "\(baseURL)?ll=\(stop.latitude),\(stop.longitude)&q=\(encodedName)") else {
                return
            }

            openURL(url)
            return
        }

        let query = [stop.name, stop.address].compactMap { $0 }.joined(separator: ", ")
        guard
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "\(baseURL)?q=\(encodedQuery)")
        else {
            return
        }

        openURL(url)
    }

    private func openInGoogleMaps() {
        let query = hasValidCoordinate
        ? "\(stop.latitude),\(stop.longitude)"
        : [stop.name, stop.address].compactMap { $0 }.joined(separator: ", ")

        guard
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedQuery)")
        else {
            return
        }

        openURL(url)
    }

    private func displayName(for category: String) -> String {
        category
            .split(separator: " ")
            .map { word in
                word.prefix(1).uppercased() + word.dropFirst().lowercased()
            }
            .joined(separator: " ")
    }

    private func iconName(for category: String) -> String {
        let value = category.lowercased()

        if value.contains("aquarium") {
            return "fish.fill"
        } else if value.contains("romantic restaurant") || value.contains("restaurant") || value.contains("izakaya") || value.contains("ramen") || value.contains("sushi") {
            return "fork.knife"
        } else if value.contains("cafe") || value.contains("coffee") {
            return "cup.and.saucer.fill"
        } else if value.contains("bar") || value.contains("wine") || value.contains("pub") {
            return "wineglass.fill"
        } else if value.contains("museum") {
            return "building.columns.fill"
        } else if value.contains("karaoke") {
            return "music.mic"
        } else if value.contains("park") || value.contains("hiking") {
            return "leaf.fill"
        } else if value.contains("bookstore") {
            return "book.fill"
        } else if value.contains("ice cream") {
            return "snowflake"
        } else if value.contains("cinema") {
            return "film.fill"
        } else if value.contains("arcade") || value.contains("bowling") || value.contains("activity") {
            return "sparkles"
        } else if value.contains("amusement park") {
            return "ferris.wheel"
        } else if value.contains("zoo") {
            return "tortoise.fill"
        } else if value.contains("casino") {
            return "suit.spade.fill"
        } else {
            return "mappin.circle.fill"
        }
    }

    private func gradientColors(for category: String) -> [Color] {
        let value = category.lowercased()

        if value.contains("aquarium") {
            return [Color.cyan.opacity(0.95), Color.blue.opacity(0.75)]
        } else if value.contains("romantic restaurant") || value.contains("restaurant") || value.contains("izakaya") || value.contains("sushi") || value.contains("ramen") {
            return [Color.orange.opacity(0.95), Color.red.opacity(0.70)]
        } else if value.contains("cafe") || value.contains("coffee") {
            return [Color.brown.opacity(0.85), Color.orange.opacity(0.55)]
        } else if value.contains("bar") || value.contains("wine") || value.contains("pub") {
            return [Color.purple.opacity(0.85), Color.pink.opacity(0.65)]
        } else if value.contains("museum") {
            return [Color.indigo.opacity(0.85), Color.blue.opacity(0.62)]
        } else if value.contains("park") || value.contains("hiking") {
            return [Color.green.opacity(0.85), Color.mint.opacity(0.62)]
        } else if value.contains("bookstore") {
            return [Color.teal.opacity(0.78), Color.indigo.opacity(0.58)]
        } else if value.contains("ice cream") {
            return [Color.pink.opacity(0.88), Color.orange.opacity(0.58)]
        } else if value.contains("cinema") {
            return [Color.indigo.opacity(0.90), Color.purple.opacity(0.68)]
        } else if value.contains("arcade") || value.contains("bowling") || value.contains("activity") {
            return [Color.blue.opacity(0.78), Color.purple.opacity(0.58)]
        } else if value.contains("amusement park") {
            return [Color.pink.opacity(0.90), Color.purple.opacity(0.66)]
        } else if value.contains("zoo") {
            return [Color.green.opacity(0.82), Color.yellow.opacity(0.52)]
        } else if value.contains("casino") {
            return [Color.red.opacity(0.82), Color.black.opacity(0.72)]
        } else {
            return [Color.blue.opacity(0.78), Color.purple.opacity(0.58)]
        }
    }
}

#Preview {
    NavigationStack {
        GeneratedStopDetailView(
            stop: GeneratedDateStop(
                name: "Aquarium Tokyo",
                description: "Start with a calm visit to enjoy an enchanting underwater world.",
                order: 1,
                reason: "A gentle first stop that makes the date feel special right away and gives the evening a memorable opening.",
                imageURL: nil,
                category: "aquarium",
                address: "Shibuya, Tokyo",
                latitude: 35.66,
                longitude: 139.70,
                estimatedPrice: 400
            )
        )
    }
}
