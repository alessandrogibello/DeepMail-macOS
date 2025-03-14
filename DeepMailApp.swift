import SwiftUI
import AppKit

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NotificationCenter.default.post(name: NSNotification.Name("AppWindowWillClose"), object: nil)
    }
    
    func setupWindow(_ window: NSWindow) {
        // Set fixed window size
        let fixedSize = NSSize(width: 500, height: 650)
        window.setContentSize(fixedSize)
        window.center()
        
        // Prevent resizing and fullscreen
        window.styleMask.remove(.resizable)
        window.styleMask.remove(.fullScreen)
        window.styleMask.remove(.miniaturizable)

        
        // Set background color
        window.backgroundColor = NSColor.windowBackgroundColor
    }
}

@main
struct DemoAppApp: App {
    private let windowDelegate = WindowDelegate()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                EmailLoginView()
            }
            .onAppear {
                setupWindow()
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
    
    private func setupWindow() {
        // Wait briefly to ensure window is created
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApplication.shared.windows.first {
                window.delegate = windowDelegate
                windowDelegate.setupWindow(window)
            }
        }
    }
}
