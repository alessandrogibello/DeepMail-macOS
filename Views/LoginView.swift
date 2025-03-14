import SwiftUI
import AppKit


// Model with Equatable conformance
struct EmailProvider: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color
    
    // Implementing Equatable
    static func == (lhs: EmailProvider, rhs: EmailProvider) -> Bool {
        return lhs.id == rhs.id
    }
}

struct EmailLoginView: View {
    @State private var selectedProvider: EmailProvider?
    @State private var showingManualConfig = false
    @Environment(\.dismiss) var dismiss
    
    private let providers: [EmailProvider] = [
        EmailProvider(id: "gmail", name: "Gmail", color: Color("#3B85F5")),
        EmailProvider(id: "outlook", name: "Outlook", color: Color("#3B85F5")),
        EmailProvider(id: "icloud", name: "iCloud", color: Color("#3B85F5"))
    ]
    
    private func openAutoreplyView() {
        if let window = NSApplication.shared.windows.first {
            window.close()
            
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 885),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            newWindow.center()
            newWindow.contentView = NSHostingView(rootView: AutoreplyPageView())
            newWindow.makeKeyAndOrderFront(nil)
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Connect Your Email")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 20)
                
                Text("Choose your email provider to get started")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Provider selection
            VStack(spacing: 16) {
                Text("Select Provider")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    // Gmail row
                    ProviderButtonFullWidth(
                        provider: providers[0],
                        selectedProvider: $selectedProvider,
                        logoName: "gmail-logo"
                    )
                    
                    // Outlook row
                    ProviderButtonFullWidth(
                        provider: providers[1],
                        selectedProvider: $selectedProvider,
                        logoName: "outlook-logo"
                    )
                    
                    // iCloud row
                    ProviderButtonFullWidth(
                        provider: providers[2],
                        selectedProvider: $selectedProvider,
                        logoName: "icloud-logo"
                    )
                }
                .padding(.horizontal)
                
            }
            
            // Alternative options
            VStack(spacing: 16) {
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                Text("Other Options")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Button(action: {
                    showingManualConfig = true
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                        Text("Manual Configuration")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                
                // CP Mode button
                Button(action: openAutoreplyView) {
                    HStack {
                        Image(systemName: "keyboard")
                            .foregroundColor(.white)
                        Text("CP Mode")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
            
            Spacer(minLength: 20)
            
            // Bottom action buttons
            HStack {
                Button("Cancel") {
                    // Handle cancel action
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
                
                Button("Continue") {
                    // Handle continue with selected provider
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedProvider == nil)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .padding()
        .frame(width: 500, height: 650)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingManualConfig) {
            ManualConfigView()
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.styleMask.remove(.resizable)
            }
        }
        .onChange(of: selectedProvider) { _, _ in
            // Play subtle feedback when selection changes
            #if canImport(AppKit)
            NSSound.beep()
            #endif
        }
    }
}

struct ProviderButtonFullWidth: View {
    let provider: EmailProvider
    @Binding var selectedProvider: EmailProvider?
    let logoName: String
    
    var body: some View {
        Button(action: {
            selectedProvider = provider
        }) {
            HStack {
                // Logo area
                HStack(spacing: 12) {
                    Image(logoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text(provider.name)
                        .font(.headline)
                        .foregroundColor(Color(NSColor.labelColor))
                }
                
                Spacer()
                
                // Selection indicator
                if selectedProvider?.id == provider.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedProvider?.id == provider.id ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ManualConfigView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var serverType: String = "IMAP"
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var incomingServer: String = ""
    @State private var incomingPort: String = ""
    @State private var outgoingServer: String = ""
    @State private var outgoingPort: String = ""
    @State private var useSSL: Bool = true
    @State private var authenticationType: String = "Password"
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with close button
            HStack {
                Text("Manual Email Configuration")
                    .font(.system(size: 24, weight: .bold))
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 20)
            .padding(.horizontal)
            
            // Form content in a scrollview for adaptability
            ScrollView {
                VStack(spacing: 16) {
                    // Account info section
                    GroupBox(label: Text("Account Information").bold()) {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Email Address", text: $emailAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Authentication", selection: $authenticationType) {
                                Text("Password").tag("Password")
                                Text("OAuth").tag("OAuth")
                                Text("API Key").tag("API Key")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Server type selector
                    GroupBox(label: Text("Server Type").bold()) {
                        Picker("Server Type", selection: $serverType) {
                            Text("IMAP").tag("IMAP")
                            Text("POP3").tag("POP3")
                            Text("Exchange").tag("Exchange")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Incoming server settings
                    GroupBox(label: Text("Incoming Server").bold()) {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Server Address", text: $incomingServer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                TextField("Port", text: $incomingPort)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                
                                Spacer()
                                
                                Toggle("Use SSL", isOn: $useSSL)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Outgoing server settings
                    GroupBox(label: Text("Outgoing Server (SMTP)").bold()) {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Server Address", text: $outgoingServer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                TextField("Port", text: $outgoingPort)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                
                                Spacer()
                                
                                Toggle("Same authentication as incoming", isOn: .constant(true))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Button section
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
                
                Button("Test Connection") {
                    // Handle test connection
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Save Configuration") {
                    // Handle save action
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .padding()
        .frame(width: 400, height: 500)
        .onAppear {
            // Set default ports based on server type and SSL settings
            if serverType == "IMAP" {
                incomingPort = useSSL ? "993" : "143"
            } else {
                incomingPort = useSSL ? "995" : "110"
            }
            outgoingPort = useSSL ? "465" : "587"
        }
        .onChange(of: serverType) { _, newValue in
            // Update port when server type changes
            if newValue == "IMAP" {
                incomingPort = useSSL ? "993" : "143"
            } else {
                incomingPort = useSSL ? "995" : "110"
            }
        }
        .onChange(of: useSSL) { _, newValue in
            // Update port when SSL setting changes
            if serverType == "IMAP" {
                incomingPort = newValue ? "993" : "143"
            } else {
                incomingPort = newValue ? "995" : "110"
            }
            outgoingPort = newValue ? "465" : "587"
        }
    }
}

// Custom button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct EmailLoginView_Previews: PreviewProvider {
    static var previews: some View {
        EmailLoginView()
    }
}
