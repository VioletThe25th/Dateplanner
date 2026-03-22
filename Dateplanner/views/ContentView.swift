//
//  ContentView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/19.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Plan the")
                    .font(.largeTitle)
                    .frame(alignment: .center)
                    .bold()
                    .foregroundStyle(.white)
                Text("perfect date")
                    .font(.largeTitle)
                    .frame(alignment: .center)
                    .bold()
                    .foregroundStyle(.white)
                Text("AI Build it for you in second")
                    .font(.default)
                    .foregroundStyle(.gray)
                Spacer()
                
                NavigationLink {
                    DatePickerView()
                } label: {
                    Text("Get Started")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .cornerRadius(25)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(PressScaleStyle())
                .padding(.horizontal, 30)
                
            }
            .padding()
            .background {
                GeometryReader { proxy in
                    let isLargeScreen = proxy.size.width >= 768
                    Image("96AEDA19-ED5D-4732-B56E-81037AFBF7EB")
                        .resizable()
                        .scaledToFill()
                        .offset(x: isLargeScreen ? 0 : -85)
                        .clipped()
                        .ignoresSafeArea()

                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                }
            }
        }
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
