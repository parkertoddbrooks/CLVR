import SwiftUI

struct ContentView: View {
    @State private var isEnabled = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Duplicate + Timestamp")
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .toggleStyle(MacOSToggleStyle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            Divider()
            
            Button(action: {}) {
                Text("Quit")
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(MacOSMenuButtonStyle(action: {
                NSApplication.shared.terminate(nil)
            }))
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
        .frame(width: 240)
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .cornerRadius(6)
    }
}

struct MacOSToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 15)
                .fill(configuration.isOn ? Color.accentColor : Color(white: 0.7))
                .frame(width: 38, height: 22)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        .frame(width: 20, height: 20)
                        .offset(x: configuration.isOn ? 8 : -8)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: configuration.isOn)
    }
}

struct MacOSMenuButtonStyle: ButtonStyle {
    let action: () -> Void
    @State private var isHovering = false
    @State private var isFlashing = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isFlashing || isHovering ? Color.accentColor : Color.clear)
            )
            .foregroundColor(isFlashing || isHovering ? .white : .primary)
            .onHover { hovering in
                isHovering = hovering
            }
            .onTapGesture {
                flashAndQuit()
            }
    }
    
    private func flashAndQuit() {
        let flashDuration = 0.05
        let flashCount = 3
        
        for i in 0..<(flashCount * 2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * flashDuration) {
                isFlashing.toggle()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(flashCount * 2) * flashDuration) {
            self.action()
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
