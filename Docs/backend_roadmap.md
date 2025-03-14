# Technical Roadmap for a SwiftUI + Python macOS App

This document outlines a comprehensive, technical roadmap to build a macOS application that leverages a bundled Python process to parse and process PDFs and Excel files, constructs queries for an LLM via APIs, and then responds accurately to email inputs. The solution is designed to provide a robust inter-process communication layer between a SwiftUI-based frontend and a Python-based backend.

---

## 1. Project Overview & Architecture

- **Objective:**  
  Develop a macOS application that:
  - Accepts email texts and user suggestions.
  - Parses external documents (PDFs for condo rules and Excel files for contacts).
  - Constructs and sends queries to an LLM API.
  - Displays the LLM-generated response in the app.

- **High-Level Architecture:**  
  - **Frontend:** SwiftUI macOS app.
  - **Backend:** Bundled Python process (using PyInstaller or PyOxidizer) handling file parsing, data pre-processing, query composition, and LLM API interactions.
  - **Communication:**  
    - **Option A:** REST API using a lightweight framework (e.g., FastAPI) with `URLSession` in Swift.
    - **Option B:** Process-based IPC via Swift’s `Process` API communicating over standard I/O or a custom socket protocol.

---

## 2. Environment Setup & Project Structure

- **Repository Structure:**
/ProjectRoot /SwiftUIApp ├── AppDelegate.swift ├── ContentView.swift ├── Models/ └── Networking/ /PythonBackend ├── main.py ├── file_parser.py ├── llm_client.py └── requirements.txt

- **Tools & Dependencies:**
- **SwiftUI App:**  
  - Xcode, Swift Package Manager.
  - Swift’s `Process` API (if opting for process-based communication).
- **Python Backend:**  
  - Python 3.8+.
  - Libraries: `PyMuPDF` (for PDFs), `pandas` & `openpyxl` (for Excel), `FastAPI` (if REST is chosen), `requests` or `httpx` (for LLM API calls), and NLP libraries such as `nltk` or `spaCy` for text chunking.
- **Bundling:**  
  - PyInstaller or PyOxidizer to package Python with the macOS app.

---

## 3. SwiftUI Frontend – UI & Communication

- **UI Elements:**
- **Email Input Area:**  
  - A text field or multi-line text view for composing the email.
  - A separate suggestion box for additional user inputs.
- **File Selectors:**  
  - File chooser components to import PDF (condo rules) and Excel (contacts) files.
- **Status Indicators:**  
  - Progress bars or spinners for file processing and LLM API calls.
- **Results Display:**  
  - A dedicated view (or chat-like interface) to display the LLM-generated response.
- **Settings Panel:**  
  - For entering API keys, adjusting LLM parameters, and configuring file paths.

- **Inter-Process Communication:**  
- **REST API Approach:**  
  - Utilize `URLSession` to send JSON requests to a locally hosted FastAPI server running within the bundled Python process.
- **Process-Based Communication:**  
  - Use Swift’s `Process` API to spawn the Python executable and read/write to its STDIN/STDOUT streams.
  - Example (Swift):
    ```swift
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/path/to/python_backend_executable")
    
    let inputPipe = Pipe()
    let outputPipe = Pipe()
    process.standardInput = inputPipe
    process.standardOutput = outputPipe
    
    try process.run()
    
    // Write JSON command to the Python process
    let command = """
    {"emailText": "Hello, ...", "suggestions": "Need details on ..."}
    """
    if let data = command.data(using: .utf8) {
        inputPipe.fileHandleForWriting.write(data)
    }
    
    // Read response
    let responseData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if let response = String(data: responseData, encoding: .utf8) {
        print("Response: \(response)")
    }
    ```
    
---

## 4. Python Backend – File Parsing & Data Extraction

- **Excel File Processing:**
- Use `pandas` along with `openpyxl`:
  ```python
  import pandas as pd

  def parse_excel(file_path):
      df = pd.read_excel(file_path)
      # Convert DataFrame to dictionary or desired format
      return df.to_dict(orient='records')
  ```

- **PDF File Processing:**
- Use `PyMuPDF` (also known as `fitz`):
  ```python
  import fitz

  def parse_pdf(file_path):
      doc = fitz.open(file_path)
      text = ""
      for page in doc:
          text += page.get_text()
      return text
  ```

- **Text Chunking & Preprocessing:**
- Use NLP libraries to split large documents into chunks that fit within LLM token limits:
  ```python
  import nltk
  nltk.download('punkt')

  def chunk_text(text, max_tokens=500):
      sentences = nltk.tokenize.sent_tokenize(text)
      chunks, current_chunk = [], []
      token_count = 0

      for sentence in sentences:
          tokens = sentence.split()
          if token_count + len(tokens) > max_tokens:
              chunks.append(" ".join(current_chunk))
              current_chunk = []
              token_count = 0
          current_chunk.append(sentence)
          token_count += len(tokens)

      if current_chunk:
          chunks.append(" ".join(current_chunk))
      return chunks
  ```

---

## 5. Communication Protocol Between Swift and Python

- **REST API with FastAPI (if chosen):**
- **Python – FastAPI Setup:**
  ```python
  from fastapi import FastAPI, Request
  import uvicorn

  app = FastAPI()

  @app.post("/process_email")
  async def process_email(request: Request):
      data = await request.json()
      # Process the email, parse files, call LLM, etc.
      response = {"result": "Processed answer"}
      return response

  if __name__ == "__main__":
      uvicorn.run(app, host="127.0.0.1", port=8000)
  ```
- **Swift – Consuming the API:**
  ```swift
  guard let url = URL(string: "http://127.0.0.1:8000/process_email") else { return }
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  
  let jsonBody = ["emailText": "Hello...", "suggestions": "Please detail..."]
  request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: [])
  
  URLSession.shared.dataTask(with: request) { data, response, error in
      // Handle response
  }.resume()
  ```

- **Process-Based Communication:**
- As illustrated in Section 3, use pipes and JSON-based message formats to exchange data.

---

## 6. LLM API Integration & Query Composition

- **LLM API Call Strategy:**
- **Handling Large Inputs:**  
  - For documents that exceed token limits (e.g., 100-page PDF), use the following strategies:
    - **Chunking:**  
      - Split the document into smaller chunks.
    - **Summarization:**  
      - Optionally generate summaries for each chunk before composing the final query.
    - **Iterative Querying:**  
      - Send multiple API calls for different sections and then aggregate the responses.
- **Python Example:**
  ```python
  import requests

  API_URL = "https://api.example-llm.com/v1/query"
  API_KEY = "your_api_key_here"

  def query_llm(prompt):
      headers = {"Authorization": f"Bearer {API_KEY}"}
      payload = {"prompt": prompt, "max_tokens": 1500}
      response = requests.post(API_URL, json=payload, headers=headers)
      return response.json()

  def compose_and_send_query(email_text, suggestions, contact_data, pdf_chunks):
      # Build the prompt using all provided inputs
      prompt = f"Email: {email_text}\nSuggestions: {suggestions}\n"
      prompt += f"Contact Data: {contact_data}\n"
      for chunk in pdf_chunks:
          prompt += f"Condo Rule Chunk: {chunk}\n"
      return query_llm(prompt)
  ```

- **Error Handling & Retries:**
- Implement retry logic and check for token limitations or timeouts.
- Use exception handling to capture API errors.

---

## 7. Backend Business Logic & Data Aggregation

- **Integrating Parsed Data:**
- Merge Excel data, PDF chunks, and user inputs into a cohesive query.
- Utilize Python’s data structures (dictionaries, lists) and possibly data models (using `pydantic`) to ensure data integrity.
- **Prompt Optimization:**
- Experiment with prompt templates and test various prompt configurations to achieve accurate responses from the LLM.
- **Logging & Monitoring:**
- Use Python’s `logging` module to capture key events and errors.

---

## 8. SwiftUI – Advanced UI Considerations

- **Email Composition Interface:**
- A multi-line text editor with syntax highlighting or markdown support.
- A placeholder text to guide the user in composing email content.
- **File Management:**
- Drag-and-drop area for importing PDFs and Excel files.
- A file list view to display the selected files and their statuses.
- **Progress Feedback:**
- Activity indicators during long-running operations (file parsing, API calls).
- A detailed log or status view for debugging purposes.
- **Response Visualization:**
- A dedicated panel to show the LLM’s answer, potentially with options to view underlying data (e.g., original PDF chunk summaries).
- **Settings & Configurations:**
- Forms to enter and save API keys, adjust chunk sizes, or select processing options.
- Theme toggles (light/dark mode) in line with macOS aesthetics.

---

## 9. Testing, Logging, & Error Handling

- **Python Backend Testing:**
- Unit tests with [pytest](https://docs.pytest.org) for file parsing, chunking, and LLM query functions.
- Integration tests simulating end-to-end processing of sample files.
- **SwiftUI Testing:**
- UI tests using Xcode’s XCTest framework.
- Network and process integration tests to simulate backend communication.
- **Logging & Monitoring:**
- Use Python’s `logging` and Swift’s unified logging system.
- Configure error handlers and alert mechanisms for critical failures.

---

## 10. Packaging, Deployment, & Documentation

- **Bundling the Python Runtime:**
- Use [PyInstaller](https://www.pyinstaller.org) or [PyOxidizer](https://pyoxidizer.readthedocs.io) to package the Python backend as a standalone executable.
- **Deployment Process:**
- Create build scripts (e.g., using Makefiles or custom shell scripts) to automate the bundling of Swift and Python components.
- Set up CI/CD pipelines (GitHub Actions, GitLab CI) to run tests, build the app, and perform deployment tasks.
- **Documentation:**
- Maintain clear developer and user documentation covering:
  - Installation and setup.
  - API endpoints and inter-process communication.
  - File formats and parsing expectations.
  - Troubleshooting common issues.
- **Post-Deployment:**
- Beta testing with real users.
- Monitor app performance and error logs to iterate on improvements.
