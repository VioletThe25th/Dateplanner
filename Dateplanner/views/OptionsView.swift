//
//  OptionsView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/20.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var isLanguageExpanded = false
    @State private var isCurrencyExpanded = false
    @State private var isLaunchExpanded = false

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    headerSection
                    languageSection
                    currencySection
                    launchSection
                }
                .frame(maxWidth: 620)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.text("options.title"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(localization.text("options.subtitle"))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var languageSection: some View {
        ExpandableOptionSection(
            icon: "globe",
            title: localization.text("options.language.title"),
            subtitle: localization.text("options.language.subtitle"),
            value: localization.language.nativeName,
            isExpanded: $isLanguageExpanded
        ) {
            VStack(spacing: 12) {
                currentLanguageCard

                ForEach(AppLanguage.allCases) { language in
                    languageCard(for: language)
                }
            }
        }
    }

    private var currencySection: some View {
        ExpandableOptionSection(
            icon: "banknote",
            title: localization.text("options.currency.title"),
            subtitle: localization.text("options.currency.subtitle"),
            value: "\(currencyManager.currency.symbol) \(currencyManager.currency.code)",
            isExpanded: $isCurrencyExpanded
        ) {
            VStack(spacing: 12) {
                currentCurrencyCard

                ForEach(CurrencyOption.allCases) { currency in
                    currencyCard(for: currency)
                }
            }
        }
    }

    private var launchSection: some View {
        ExpandableOptionSection(
            icon: "sparkles",
            title: localization.text("options.launch.title"),
            subtitle: localization.text("options.launch.subtitle"),
            isExpanded: $isLaunchExpanded
        ) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.88))

                Text(localization.text("options.launch.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private var currentLanguageCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(localization.text("options.language.current"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))

                Text(localization.language.nativeName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)

            Text(localization.language.languageCodeLabel)
                .font(.caption.weight(.bold))
                .foregroundStyle(.black.opacity(0.90))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white)
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func languageCard(for language: AppLanguage) -> some View {
        let isSelected = localization.language == language

        return Button {
            localization.setLanguage(language)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.08))
                        .frame(width: 38, height: 38)

                    Image(systemName: isSelected ? "checkmark" : "globe")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.92) : Color.white.opacity(0.88))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(language.nativeName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(language.languageCodeLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.14) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.16 : 0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var currentCurrencyCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "banknote")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(localization.text("options.currency.current"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))

                Text(currencyManager.currency.displayName(localeIdentifier: localization.language.localeIdentifier))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)

            Text("\(currencyManager.currency.symbol) \(currencyManager.currency.code)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.black.opacity(0.90))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white)
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func currencyCard(for currency: CurrencyOption) -> some View {
        let isSelected = currencyManager.currency == currency

        return Button {
            currencyManager.setCurrency(currency)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.08))
                        .frame(width: 38, height: 38)

                    Text(currency.symbol)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.92) : Color.white.opacity(0.88))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(currency.displayName(localeIdentifier: localization.language.localeIdentifier))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(currency.code)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.14) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.16 : 0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ExpandableOptionSection<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String?
    @Binding var isExpanded: Bool
    let content: Content

    init(
        icon: String,
        title: String,
        subtitle: String,
        value: String? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self._isExpanded = isExpanded
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: icon)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.90))
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.08))
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Text(title)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)

                            if let value, !value.isEmpty {
                                Text(value)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white.opacity(0.72))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(Color.white.opacity(0.08))
                                    )
                            }
                        }

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.60))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.70))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            if isExpanded {
                content
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .cardBackground()
    }
}

#Preview {
    NavigationStack {
        OptionsView()
            .environmentObject(LocalizationManager.preview)
            .environmentObject(CurrencyManager.preview)
    }
}
