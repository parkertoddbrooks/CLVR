import SwiftUI
import AppKit

struct ContentView: View {
    @State private var isEnabled = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Duplicate + Timestamp")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Spacer()
                NSSwitch($isEnabled)
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
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        .frame(width: 253)
    }
}

struct NSSwitch: NSViewRepresentable {
    @Binding var isOn: Bool

    func makeNSView(context: Context) -> NSSwitch {
        let switch = NSSwitch()
        switch.target = context.coordinator
        switch.action = #selector(Coordinator.toggleSwitch)
        return switch
    }

    func updateNSView(_ nsView: NSSwitch, context: Context) {
        nsView.state = isOn ? .on : .off
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: NSSwitch

        init(_ parent: NSSwitch) {
            self.parent = parent
        }

        @objc func toggleSwitch(_ sender: NSSwitch) {
            parent.isOn = sender.state == .on
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
        Group {
            ContentView()
                .frame(width: 253, height: 80)
                .preferredColorScheme(.light)
            ContentView()
                .frame(width: 253, height: 80)
                .preferredColorScheme(.dark)
        }
    }
}