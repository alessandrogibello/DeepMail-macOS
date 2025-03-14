# AutoreplyPageView Documentation

## Overview
`AutoreplyPageView` is a SwiftUI view component that provides an interface for generating automated email responses. It's designed for macOS and includes email content input, specification entry, and response generation functionality.

## Features
- Email content input with line limit
- Specifications input with line limit
- Response generation capability
- Copy to clipboard functionality
- Reset/refresh capability
- Dark mode support

## Components

### State Variables
```swift
@State private var emailContent: String         // Stores the input email content
@State private var specificationsComment: String // Stores the specification requirements
@State private var generatedResponse: String    // Stores the generated response
```

### String Extension
```swift
extension String {
    var numberOfLines: Int {
        return self.components(separatedBy: "\n").count
    }
}
```
Adds functionality to count the number of lines in a string.

### Input Limitations
The view implements two custom bindings:
- `limitedEmailContent`: Restricts email content to 50 lines
- `limitedSpecifications`: Restricts specifications to 10 lines

### Main Sections
1. **Email Content Section**
   - TextEditor for email input
   - Line count display
   - Maximum 50 lines

2. **Specifications Section**
   - TextEditor for requirements input
   - Line count display
   - Maximum 10 lines

3. **Generated Response Section**
   - Read-only TextEditor
   - Displays the generated response

### Buttons
- **Generate Response**: Triggers response generation (backend integration pending)
- **Refresh**: Resets all fields to empty state
- **Copy Response**: Copies generated response to system clipboard

## Layout
- Minimum window width: 900 pixels
- Minimum window height: 885 pixels
- Scrollable content
- Responsive design with flexible width and height

## Usage
```swift
AutoreplyPageView()
```

## TODO
- Implement backend integration
- Add Python script communication
- Handle response generation logic

## Requirements
- macOS platform
- SwiftUI framework
- Access to NSPasteboard for clipboard operations
