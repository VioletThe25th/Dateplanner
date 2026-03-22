import SwiftUI

extension View {
    func cardBackground() -> some View {
        self
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
}
