import SwiftUI

struct ContentView: View {
    @State private var isEnabled = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Duplicate + Timestamp")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(.system(size: 13, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
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
        Group {
            ContentView()
                .frame(width: 250, height: 100)
                .preferredColorScheme(.light)
            ContentView()
                .frame(width: 250, height: 100)
                .preferredColorScheme(.dark)
        }
    }
}