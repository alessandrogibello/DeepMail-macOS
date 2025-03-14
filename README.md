# DeepMail

## Overview
DeepMail is a macOS application that automates email responses using an AI-driven pipeline. This repository contains:
- SwiftUI & AppKit-based front-end
- Python-based backend for PDF chunking, API calls

## Front-End
- SwiftUI for layout & data handling
- AppKit for lower-level macOS interactions

## Backend
- Python runtime for API processing and file parsing
- PyMuPDF for PDF, pandas/openpyxl for spreadsheets
- Communicates via Swift’s Process-based IPC

### Features & Architecture
- AI-driven email creation & vector database indexing
- Document chunking for efficient LLM usage
- Automated file selection based on content


## Packaging & Distribution
- Single App Bundle with embedded Python

## Current Status
**Completed:**
- Front-end UI

**In Progress:**
- Bug fix in backend integration


## License
All rights reserved.