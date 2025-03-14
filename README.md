# DeepMail README

This codebase provides a macOS application built with SwiftUI and AppKit to manage automated email replies. It integrates with a backend that dynamically selects and processes PDF and Excel files based on the content of incoming emails.

**Key Features**:  
1. **Vector Databases**: Used to store and quickly retrieve relevant information from large data sets in real-time.  
2. **PDF Chunking**: Breaks large PDF documents into smaller parts, allowing more accurate content analysis and faster responses.  
3. **Automated File Selection**: The system determines which PDFs and Excel files are relevant to the received email and processes their data automatically.  
4. **SwiftUI & AppKit Integration**: Interface built with SwiftUI, while AppKit handles overall window management and behavior.

Use this app as a foundation for designing, refining, and deploying an automated email solution with built-in data extraction, transformation, and response generation. The code is organized into SwiftUI views, window delegates, and entitlements configured for Apple’s sandbox environment.