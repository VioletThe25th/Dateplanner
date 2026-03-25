
//
//  DateGenerationLoadingView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import SwiftUI

struct DateGenerationLoadingView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @State private var isOrbiting = false
    @State private var isPulsing = false
    @State private var isShimmering = false
    @State private var animateCards = false

    private var loadingSteps: [(title: String, subtitle: String, icon: String)] {
        [
            (localization.text("loading.step.finding.title"), localization.text("loading.step.finding.subtitle"), "mappin.and.ellipse"),
            (localization.text("loading.step.matching.title"), localization.text("loading.step.matching.subtitle"), "heart.circle"),
            (localization.text("loading.step.building.title"), localization.text("loading.step.building.subtitle"), "sparkles")
        ]
    }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 28) {
                Spacer()

                headerSection
                animatedHero
                progressSection
                stepsSection

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startAnimations()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(localization.text("content.appTitle"))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            Text(localization.text("loading.title"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text(localization.text("loading.subtitle"))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.66))
                .frame(maxWidth: 320)
        }
    }

    private var animatedHero: some View {
        ZStack {
            Circle()
                .fill(Color.cyan.opacity(0.14))
                .frame(width: 240, height: 240)
                .blur(radius: 22)
                .scaleEffect(isPulsing ? 1.05 : 0.92)

            Circle()
                .fill(Color.pink.opacity(0.10))
                .frame(width: 180, height: 180)
                .blur(radius: 18)
                .scaleEffect(isPulsing ? 0.94 : 1.08)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 1.2, dash: [5, 10])
                )
                .frame(width: 220, height: 220)

            orbitDots(radius: 110)
                .rotationEffect(.degrees(isOrbiting ? 360 : 0))

            orbitDots(radius: 78, dotSize: 10, colors: [Color.pink.opacity(0.95), Color.orange.opacity(0.75)])
                .rotationEffect(.degrees(isOrbiting ? -360 : 0))

            centerCore
        }
        .frame(height: 280)
    }

    private var centerCore: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .background(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.ultraThinMaterial)
                )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.95), Color.blue.opacity(0.78)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 74, height: 74)
                        .shadow(color: Color.cyan.opacity(0.42), radius: 18, x: 0, y: 10)

                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 10) {
                    detailPill(icon: "mappin.circle.fill", text: localization.text("loading.detail.nearby"))
                    detailPill(icon: "sparkles", text: localization.text("loading.detail.ai"))
                    detailPill(icon: "point.topleft.down.curvedto.point.bottomright.up.fill", text: localization.text("loading.detail.flow"))
                }
            }
            .padding(22)
        }
        .frame(width: 210, height: 170)
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 12)
    }

    private var progressSection: some View {
        VStack(spacing: 10) {
            GeometryReader { proxy in
                let width = proxy.size.width

                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))

                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.cyan.opacity(0.25),
                                    Color.white.opacity(0.92),
                                    Color.pink.opacity(0.35),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width * 0.42)
                        .offset(x: isShimmering ? width : -width * 0.42)
                        .blur(radius: 0.2)
                }
            }
            .frame(height: 8)
            .clipShape(Capsule(style: .continuous))

            Text(localization.text("loading.progress"))
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.58))
        }
        .frame(maxWidth: 320)
    }

    private var stepsSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(loadingSteps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 42, height: 42)

                        Image(systemName: step.icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.88))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(step.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.62))
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Circle()
                        .fill(Color.cyan.opacity(0.92))
                        .frame(width: 8, height: 8)
                        .shadow(color: Color.cyan.opacity(0.48), radius: 8, x: 0, y: 0)
                        .scaleEffect(animateCards ? 1.0 : 0.7)
                        .opacity(animateCards ? 1.0 : 0.45)
                        .animation(
                            .easeInOut(duration: 1.15)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.24),
                            value: animateCards
                        )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 8)
                .scaleEffect(animateCards ? 1.0 : 0.985)
                .opacity(animateCards ? 1.0 : 0.82)
                .animation(
                    .easeInOut(duration: 1.15)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.24),
                    value: animateCards
                )
            }
        }
        .frame(maxWidth: 420)
    }

    private func orbitDots(
        radius: CGFloat,
        dotSize: CGFloat = 12,
        colors: [Color] = [Color.cyan.opacity(0.95), Color.blue.opacity(0.75)]
    ) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: dotSize, height: dotSize)
                    .shadow(color: colors.first?.opacity(0.45) ?? .clear, radius: 8, x: 0, y: 0)
                    .offset(y: -radius)
                    .rotationEffect(.degrees(Double(index) * 120))
            }
        }
        .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: isOrbiting)
    }

    private func detailPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.78))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func startAnimations() {
        guard !isOrbiting else { return }

        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            isOrbiting = true
        }

        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            isPulsing = true
        }

        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
            isShimmering = true
        }

        withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
            animateCards = true
        }
    }
}

#Preview {
    DateGenerationLoadingView()
}
