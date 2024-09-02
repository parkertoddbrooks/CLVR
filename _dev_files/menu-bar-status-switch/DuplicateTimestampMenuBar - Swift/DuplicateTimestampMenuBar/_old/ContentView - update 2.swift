import SwiftUI

struct ContentView: View {
    @State private var isEnabled = false
    @State private var isFlashing = false
    @State private var isHovering = false
    
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
            
            Button(action: flashAndQuit) {
                Text("Quit")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(isFlashing ? Color.blue : (isHovering ? Color.blue : Color.clear))
                    .foregroundColor(isFlashing || isHovering ? .white : .primary)
                    .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                isHovering = hovering
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
        .frame(width: 240)
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .cornerRadius(6)
    }
    
    private func flashAndQuit() {
        let flashDuration = 0.1
        let flashCount = 2

        func flash(count: Int) {
            if count < flashCount * 2 {
                withAnimation(.easeInOut(duration: flashDuration)) {
                    isFlashing.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
                    flash(count: count + 1)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
                    NSApplication.shared.terminate(nil)
                }
            }
        }

        isFlashing = true
        flash(count: 1)
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

#Preview {
    ContentView()
}