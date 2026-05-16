import SwiftUI

struct BrightnessSlider: View {
    @Binding var brightness: Double

    private let darkEnd   = Color(.sRGB, red: 0.039, green: 0.039, blue: 0.039)
    private let lightEnd  = Color(.sRGB, red: 0.961, green: 0.941, blue: 0.910)
    private let trackH: CGFloat = 36

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let thumbX = brightness * w

            ZStack(alignment: .leading) {
                // Gradient track
                LinearGradient(colors: [darkEnd, lightEnd], startPoint: .leading, endPoint: .trailing)
                    .frame(height: trackH)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                // Thumb — bright line with glow
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.white)
                    .frame(width: 3, height: trackH + 12)
                    .shadow(color: .white.opacity(0.6), radius: 6, x: 0, y: 0)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 0)
                    .offset(x: thumbX - 1.5, y: -6)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let raw = value.location.x / w
                        withAnimation(.interactiveSpring()) {
                            brightness = min(max(raw, 0), 1)
                        }
                    }
            )
        }
        .frame(height: trackH)
    }
}
