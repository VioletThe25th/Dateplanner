//
//  DateplannerApp.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/19.
//

import SwiftUI

@main
struct DateplannerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {
    @AppStorage("hasSeenWelcomeScreen") private var hasSeenWelcomeScreen = false
    @State private var launchDestination: LaunchDestination?

    var body: some View {
        Group {
            switch launchDestination {
            case .welcome:
                ContentView {
                    launchDestination = .planner
                }
            case .planner:
                NavigationStack {
                    DatePickerView()
                }
                .preferredColorScheme(.dark)
            case nil:
                Color.black
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            guard launchDestination == nil else { return }

            if hasSeenWelcomeScreen {
                launchDestination = .planner
            } else {
                launchDestination = .welcome
                hasSeenWelcomeScreen = true
            }
        }
    }
}

private enum LaunchDestination {
    case welcome
    case planner
}
