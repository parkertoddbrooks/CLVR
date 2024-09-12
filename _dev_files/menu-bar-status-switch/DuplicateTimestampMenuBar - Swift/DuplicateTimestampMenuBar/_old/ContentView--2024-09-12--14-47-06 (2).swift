import SwiftUI

struct ContentView: View {
    @State private var isEnabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Duplicate + Timestamp")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .toggleStyle(CustomToggleStyle())
                    .frame(width: 36, height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(.system(size: 13, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .padding(.vertical, 4)
            }
            .buttonStyle(MenuItemButtonStyle())
        }
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        .frame(width: 240)
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(configuration.isOn ? Color.blue : Color.gray.opacity(0.25))
                .frame(width: 36, height: 20)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: 1, x: 0, y: 1)
                        .frame(width: 18, height: 18)
                        .offset(x: configuration.isOn ? 8 : -8)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: configuration.isOn)
    }
}

struct MenuItemButtonStyle: ButtonStyle {
    @State private var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.blue.opacity(isHovering ? 1 : 0))
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 240, height: 100)
            .preferredColorScheme(.dark)
    }
}
