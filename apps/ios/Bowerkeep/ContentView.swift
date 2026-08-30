import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack.fill")
                .font(.largeTitle)
                .accessibilityHidden(true)
            Text("Bowerkeep")
                .font(.title)
                .fontWeight(.semibold)
            Text("Every card in its place")
                .foregroundStyle(.secondary)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView()
}
