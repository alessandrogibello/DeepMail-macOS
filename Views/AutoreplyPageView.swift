import SwiftUI


extension String {
    var numberOfLines: Int {
        return self.components(separatedBy: "\n").count
    }
}

struct AutoreplyPageView: View {
    @State private var emailContent = ""
    @State private var specificationsComment = ""
    @State private var generatedResponse = ""
    @Environment(\.colorScheme) var colorScheme

    private var limitedEmailContent: Binding<String> {
        Binding(
            get: { emailContent },
            set: { newValue in
                if newValue.numberOfLines <= 50 {
                    emailContent = newValue
                } else if let lastNewLine = newValue.range(of: "\n", options: .backwards) {
                    emailContent = String(newValue[..<lastNewLine.lowerBound])
                }
            }
        )
    }

    private var limitedSpecifications: Binding<String> {
        Binding(
            get: { specificationsComment },
            set: { newValue in
                if newValue.numberOfLines <= 10 {
                    specificationsComment = newValue
                } else if let lastNewLine = newValue.range(of: "\n", options: .backwards) {
                    specificationsComment = String(newValue[..<lastNewLine.lowerBound])
                }
            }
        )
    }
    
    private func resetAllFields() {
            emailContent = ""
            specificationsComment = ""
            generatedResponse = ""
        }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Email Content Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Email Content", systemImage: "envelope")
                                .font(.system(size: 15))
                            Spacer()
                            Text("\(emailContent.numberOfLines)/50 lines")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        TextEditor(text: limitedEmailContent) // Use the limited binding here
                            .font(.body)
                            .frame(minHeight: 200, maxHeight: .infinity)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .scrollContentBackground(.hidden)
                            .scrollIndicators(.automatic)
                    }
                }
                
                // Specifications Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Specifications", systemImage: "text.alignleft")
                                .font(.system(size: 15))
                            Spacer()
                            Text("\(specificationsComment.numberOfLines)/10 lines")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        TextEditor(text: limitedSpecifications)
                            .font(.body)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .scrollContentBackground(.hidden)
                            .scrollIndicators(.automatic)
                    }
                }
                
                
                
                // Generate Button
                Button(action: {
                    // TODO: Call Python backend script here
                }) {
                    Label("Generate Response", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // Generated Response Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Generated Response", systemImage: "text.bubble")
                            .font(.system(size: 15))
                            .padding(.bottom, 2)
                        
                        TextEditor(text: .constant(generatedResponse))
                            .font(.body)
                            .frame(minHeight: 200, maxHeight: .infinity)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(12)
                            .disabled(true)
                            .scrollContentBackground(.hidden)
                            .scrollIndicators(.automatic)
                    }
                }
                
                // Action Buttons Row
                HStack(spacing: 16) {
                    
                    // Refresh Button
                    Button(action: {
                        resetAllFields()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .disabled(generatedResponse.isEmpty)
                    
                    // Copy Button
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(generatedResponse, forType: .string)
                    }) {
                        Label("Copy Response", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .disabled(generatedResponse.isEmpty)
                }
            }
            .padding()
        }
        .frame(minWidth: 900, maxWidth: .infinity, minHeight: 885, maxHeight: .infinity) // Try to use ideal width and height
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct AutoreplyPageView_Previews: PreviewProvider {
    static var previews: some View {
        AutoreplyPageView()
    }
}


// TODO: Find a way to communicate between the frontend and the backend. (Maybe use a python script that is going to be called from the frontend). Also find a way to call the python script from the frontend.
