import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
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
            .offset(x: 50)
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
        }
    }
}
