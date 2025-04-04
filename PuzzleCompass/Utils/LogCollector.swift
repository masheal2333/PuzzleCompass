import Foundation
import SwiftUI
import os.log
import ObjectiveC

/// Log type
enum LogType: String, Codable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case camera = "CAMERA"
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .camera: return "📷"
        }
    }
    
    var color: Color {
        switch self {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .red
        case .camera: return .purple
        }
    }
}

/// Log entry structure
struct LogEntry: Identifiable, Codable {
    var id = UUID()
    let timestamp: Date
    let message: String
    let type: LogType
    let category: String
    let file: String
    let function: String
    let line: Int
    
    // Coding key definition
    enum CodingKeys: String, CodingKey {
        case timestamp, message, type, category, file, function, line
    }
    
    // For display purposes, formatted timestamp
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}

/// Global log collector, used for analyzing camera issues
class LogCollector: ObservableObject {
    // Singleton instance
    static let shared = LogCollector()
    
    // Stored logs
    @Published var logs: [LogEntry] = []
    
    // Whether to enable debug view
    @Published var showDebugView = false
    
    // Log file URL
    private var logFileURL: URL?
    
    // File operation queue
    private let fileQueue = DispatchQueue(label: "com.puzzlecompass.logfile", qos: .utility)
    
    // Date formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    // Maximum log count
    private var maxEntries = 500
    
    // Initialize
    private init() {
        // Initialize in a defensive mode
        do {
            try setupLogFile()
            // Defensive programming, even if log redirection fails, it won't affect the application
            redirectConsoleLogToDocuments()
        } catch {
            print("Log system initialization failed: \(error.localizedDescription)")
            // Ensure we have at least one usable log file URL
            if logFileURL == nil, 
               let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                logFileURL = docDir.appendingPathComponent("PuzzleCompass_fallback.log")
            }
        }
    }
    
    // Configure log collector
    func configure(maxEntries: Int = 500) throws {
        self.maxEntries = maxEntries
        try setupLogFile()
    }
    
    // Setup log file
    private func setupLogFile() throws {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
            
            if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = docDir.appendingPathComponent("PuzzleCompass_\(dateString).log")
                self.logFileURL = fileURL
                
                // Write file header
                let header = "---- PuzzleCompass Log Session Started \(Date()) ----\n"
                try appendToFile(header)
                
                print("Log file location: \(fileURL.path)")
            } else {
                print("Unable to access documents directory")
                throw NSError(domain: "LogCollector", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Unable to access documents directory"])
            }
        } catch {
            print("Error setting up log file: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Add log entry
    func log(level: LogType = .info, message: String, category: String = "App", file: String = #file, function: String = #function, line: Int = #line) throws {
        // Safety check
        guard !message.isEmpty else {
            print("Warning: Attempted to log empty message")
            return
        }
        
        // Get filename (without path)
        let fileName = (file as NSString).lastPathComponent
        
        // Console print
        print("\(level.emoji) [\(category)] \(message)")
        
        // Create log entry
        let entry = LogEntry(
            timestamp: Date(),
            message: message,
            type: level,
            category: category,
            file: fileName,
            function: function,
            line: line
        )
        
        // Add to in-memory log list
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logs.append(entry)
            
            // Limit log count
            if self.logs.count > self.maxEntries {
                self.logs.removeFirst(self.logs.count - self.maxEntries)
            }
        }
        
        // Process category specific logs
        try processCategorySpecificLog(message, level: level, category: category)
        
        // Save to file
        try saveLogToFile(entry)
    }
    
    // Save log to file
    private func saveLogToFile(_ entry: LogEntry) throws {
        // Format log string
        let timestamp = dateFormatter.string(from: entry.timestamp)
        let logString = "[\(timestamp)] [\(entry.type.rawValue)] [\(entry.category)] \(entry.message) [\(entry.file):\(entry.line) \(entry.function)]\n"
        
        // Write to file
        try appendToFile(logString)
    }
    
    // Append content to file
    private func appendToFile(_ text: String) throws {
        guard let fileURL = logFileURL else { return }
        
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        fileQueue.async {
            do {
                // Check if file exists
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    // Append to existing file
                    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        // Move to end of file
                        if #available(iOS 13.4, *) {
                            try fileHandle.seekToEnd()
                        } else {
                            fileHandle.seekToEndOfFile()
                        }
                        
                        // Write data
                        if let data = text.data(using: .utf8) {
                            if #available(iOS 13.4, *) {
                                try fileHandle.write(contentsOf: data)
                            } else {
                                fileHandle.write(data)
                            }
                        }
                        
                        // Close file
                        if #available(iOS 13.0, *) {
                            try fileHandle.close()
                        } else {
                            fileHandle.closeFile()
                        }
                    }
                } else {
                    // Create new file
                    try text.write(to: fileURL, atomically: true, encoding: .utf8)
                }
            } catch let catchError {
                // Capture error
                error = catchError
                print("Log file write error: \(catchError.localizedDescription)")
            }
            
            semaphore.signal()
        }
        
        // Wait for async operation to complete
        _ = semaphore.wait(timeout: .now() + 2.0)
        
        // If there was an error, throw it
        if let error = error {
            throw error
        }
    }
    
    // Redirect console log to file
    private func redirectConsoleLogToDocuments() {
        // Console output will be captured via print statements and added to logs
        // Due to SwiftUI and iOS limitations, we can't fully intercept system logs
    }
    
    /// Clear logs
    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
        
        // Also clear logs in file
        if self.logFileURL != nil {
            fileQueue.async { [self] in
                do {
                    // Write a new file header, overwriting the old file
                    let header = "---- PuzzleCompass Log Session Cleared \(Date()) ----\n"
                    try header.write(to: self.logFileURL!, atomically: true, encoding: .utf8)
                } catch {
                    print("Clear log file error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Export logs to file
    func exportLogs() -> URL? {
        // Directly return the URL of the current log file
        return logFileURL
    }
    
    /// Get all log entries
    func getEntries() -> [LogEntry] {
        return logs
    }
    
    /// Filter logs by type
    func filterLogs(type: LogType? = nil, category: String? = nil) -> [LogEntry] {
        var filtered = logs
        
        if let type = type {
            filtered = filtered.filter { $0.type == type }
        }
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    // Add category specific log processing
    private func processCategorySpecificLog(_ message: String, level: LogType, category: String) throws {
        switch category {
        case "Camera", "CameraVM", "CameraPreview", "CameraDebug":
            // Camera-specific logs are handled separately
            try processAndStoreCameraLog(message, level: level, category: category)
        default:
            // General log processing
            // Already handled by regular log storage logic
            break
        }
    }
    
    /// Process and store camera-specific logs
    private func processAndStoreCameraLog(_ message: String, level: LogType, category: String) throws {
        // Record to camera-specific log storage
        _ = try formatLogMessage(message, level: level, category: category)
        
        // If it's a high-priority log, also add to camera issue logs
        if level == .error || level == .warning {
            _ = Date().timeIntervalSince1970
            let entry = LogEntry(
                timestamp: Date(),
                message: "[\(category)] \(message)",
                type: level,
                category: category,
                file: "CameraLog",
                function: "processAndStoreCameraLog",
                line: 0
            )
            
            // Use synchronous queue instead of lock for better performance and security
            DispatchQueue.global(qos: .utility).sync { [weak self] in
                guard let self = self else { return }
                self.cameraIssueEntries.append(entry)
                
                // Limit issue log entries
                if self.cameraIssueEntries.count > self.maxCameraIssueEntries {
                    self.cameraIssueEntries.removeFirst()
                }
            }
            
            // If it's an error, send notification
            if level == .error {
                // Send camera error notification
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .cameraErrorDetected,
                        object: nil,
                        userInfo: ["message": message, "category": category]
                    )
                }
            }
        }
    }
    
    /// Get formatted log message
    private func formatLogMessage(_ message: String, level: LogType, category: String) throws -> String {
        let timestamp = dateFormatter.string(from: Date())
        let levelSymbol: String
        
        switch level {
        case .info:
            levelSymbol = "ℹ️"
        case .warning:
            levelSymbol = "⚠️"
        case .error:
            levelSymbol = "❌"
        case .debug:
            levelSymbol = "🔍"
        case .camera:
            levelSymbol = "📷"
        }
        
        // Format multiline log
        let messageLines = message.split(separator: "\n")
        if messageLines.count > 1 {
            var formattedMultiline = "\(timestamp) \(levelSymbol) [\(category)] 👇 Log Start 👇\n"
            
            for line in messageLines {
                formattedMultiline += "  ┃ \(line)\n"
            }
            
            formattedMultiline += "  ┗━━━━━━━━━ Log End ━━━━━━━━━"
            return formattedMultiline
        } else {
            return "\(timestamp) \(levelSymbol) [\(category)] \(message)"
        }
    }
    
    /// Get camera issue logs
    public func getCameraIssueEntries() -> [LogEntry] {
        var entries: [LogEntry] = []
        
        // Use synchronous queue to safely access data
        DispatchQueue.global(qos: .userInitiated).sync {
            entries = self.cameraIssueEntries
        }
        
        return entries
    }
    
    /// Clear camera issue logs
    public func clearCameraIssueEntries() {
        // Use synchronous queue to safely clear data
        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in
            guard let self = self else { return }
            self.cameraIssueEntries.removeAll()
        }
    }
    
    // Camera issue log capacity
    private let maxCameraIssueEntries = 100
    
    // Camera issue log storage
    private var cameraIssueEntries: [LogEntry] = []
    
    // Refresh logs before application termination
    func flushLogs() throws {
        // Add session end marker
        if let fileURL = logFileURL {
            let footer = "---- PuzzleCompass Log Session Ended \(Date()) ----\n\n"
            try appendToFile(footer)
        }
    }
}

// Add notification name extension
extension Notification.Name {
    static let cameraErrorDetected = Notification.Name("cameraErrorDetected")
}

/// Add a convenient UI component to view camera logs
struct CameraLogsView: View {
    @State private var logs: [LogEntry] = []
    @State private var errorLogs: [LogEntry] = []
    @State private var selectedTab = 0
    @State private var showShareSheet = false
    @State private var logFileURL: URL?
    
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack {
                Picker("Log type", selection: $selectedTab) {
                    Text("All logs").tag(0)
                    Text("Error logs").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Button(action: {
                    logFileURL = LogCollector.shared.exportLogs()
                    showShareSheet = logFileURL != nil
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            
            if selectedTab == 0 {
                LogListView(logs: logs)
            } else {
                LogListView(logs: errorLogs, isErrorView: true)
            }
        }
        .onAppear {
            refreshLogs()
        }
        .onReceive(timer) { _ in
            refreshLogs()
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = logFileURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func refreshLogs() {
        // Get latest logs
        let collector = LogCollector.shared
        logs = collector.getEntries().filter { 
            $0.category == "Camera" || 
            $0.category == "CameraVM" || 
            $0.category == "CameraPreview" || 
            $0.category == "CameraDebug"
        }
        
        // Get error logs
        errorLogs = collector.getCameraIssueEntries()
    }
}

struct LogListView: View {
    let logs: [LogEntry]
    var isErrorView: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(logs.reversed()) { log in
                    logEntryView(for: log)
                }
                
                if logs.isEmpty {
                    Text(isErrorView ? "No camera error logs" : "No camera logs")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func logEntryView(for entry: LogEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Log level icon
                logLevelIcon(for: entry.type)
                
                // Timestamp
                Text(entry.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Category label
                Text(entry.category)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(categoryColor(for: entry.category))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Spacer()
            }
            
            // Message content
            Text(entry.message)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
        }
        .padding(8)
        .background(backgroundColor(for: entry.type))
        .cornerRadius(8)
    }
    
    private func logLevelIcon(for level: LogType) -> some View {
        let iconName: String
        let color: Color
        
        switch level {
        case .info:
            iconName = "info.circle.fill"
            color = .blue
        case .warning:
            iconName = "exclamationmark.triangle.fill"
            color = .orange
        case .error:
            iconName = "xmark.circle.fill"
            color = .red
        case .debug:
            iconName = "magnifyingglass"
            color = .gray
        case .camera:
            iconName = "camera.fill"
            color = .purple
        }
        
        return Image(systemName: iconName)
            .foregroundColor(color)
    }
    
    private func backgroundColor(for level: LogType) -> Color {
        switch level {
        case .info:
            return Color.blue.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        case .debug:
            return Color.gray.opacity(0.1)
        case .camera:
            return Color.purple.opacity(0.1)
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Camera":
            return Color.purple
        case "CameraVM":
            return Color.indigo
        case "CameraPreview":
            return Color.blue
        case "CameraDebug":
            return Color.green
        default:
            return Color.gray
        }
    }
}

/// Share sheet
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Global log functions

/// Record information-level log
/// - Parameters:
///   - message: Log message
///   - category: Log category
///   - file: Source file
///   - function: Function name
///   - line: Line number
public func logInfo(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
    do {
        try LogCollector.shared.log(level: .info, message: message, category: category, file: file, function: function, line: line)
    } catch {
        print("Record information log failed: \(error.localizedDescription)")
    }
}

/// Record debug-level log
/// - Parameters:
///   - message: Log message
///   - category: Log category
///   - file: Source file
///   - function: Function name
///   - line: Line number
public func logDebug(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
    do {
        try LogCollector.shared.log(level: .debug, message: message, category: category, file: file, function: function, line: line)
    } catch {
        print("Record debug log failed: \(error.localizedDescription)")
    }
}

/// Record warning-level log
/// - Parameters:
///   - message: Log message
///   - category: Log category
///   - file: Source file
///   - function: Function name
///   - line: Line number
public func logWarning(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
    do {
        try LogCollector.shared.log(level: .warning, message: message, category: category, file: file, function: function, line: line)
    } catch {
        print("Record warning log failed: \(error.localizedDescription)")
    }
}

/// Record error-level log
/// - Parameters:
///   - message: Log message
///   - category: Log category
///   - file: Source file
///   - function: Function name
///   - line: Line number
public func logError(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
    do {
        try LogCollector.shared.log(level: .error, message: message, category: category, file: file, function: function, line: line)
    } catch {
        print("Record error log failed: \(error.localizedDescription)")
    }
}

/// Record camera-level log
/// - Parameters:
///   - message: Log message
///   - category: Log category
///   - file: Source file
///   - function: Function name
///   - line: Line number
public func logCamera(_ message: String, category: String = "Camera", file: String = #file, function: String = #function, line: Int = #line) {
    do {
        try LogCollector.shared.log(level: .camera, message: message, category: category, file: file, function: function, line: line)
    } catch {
        print("Record camera log failed: \(error.localizedDescription)")
    }
}

// MARK: - Extend SwiftUI view to use logs
extension View {
    func withLogger() -> some View {
        self.modifier(LoggerViewModifier())
    }
}

// Log decorator (injected into SwiftUI view hierarchy)
struct LoggerViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            
            #if DEBUG
            FloatingLogButton()
                .zIndex(999)
            #endif
        }
    }
}

/// Floating log button
struct FloatingLogButton: View {
    @State private var showLogViewer = false
    @State private var position = CGPoint(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 120)
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        Button(action: {
            showLogViewer = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .shadow(radius: 3)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
        }
        .position(
            x: position.x + dragOffset.width,
            y: position.y + dragOffset.height
        )
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    position = CGPoint(
                        x: position.x + value.translation.width,
                        y: position.y + value.translation.height
                    )
                }
        )
        .sheet(isPresented: $showLogViewer) {
            LogViewer()
        }
    }
}

/// Log viewer
struct LogViewer: View {
    @ObservedObject private var logCollector = LogCollector.shared
    @State private var selectedType: LogType? = nil
    @State private var searchText = ""
    @State private var showShareSheet = false
    @State private var exportURL: URL? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("Log Viewer")
                    .font(.headline)
                Spacer()
                Button(action: {
                    exportURL = logCollector.exportLogs()
                    showShareSheet = exportURL != nil
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .padding(.horizontal, 8)
                
                Button(action: {
                    logCollector.clearLogs()
                }) {
                    Image(systemName: "trash")
                }
                .padding(.horizontal, 8)
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            
            // Filter
            HStack {
                Button(action: {
                    selectedType = nil
                }) {
                    Text("All")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(selectedType == nil ? Color.blue : Color.secondary.opacity(0.3))
                        .foregroundColor(selectedType == nil ? .white : .primary)
                        .cornerRadius(8)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach([LogType.debug, .info, .warning, .error, .camera], id: \.self) { type in
                            Button(action: {
                                selectedType = type
                            }) {
                                HStack {
                                    Text(type.emoji)
                                    Text(type.rawValue)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedType == type ? type.color : Color.secondary.opacity(0.3))
                                .foregroundColor(selectedType == type ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Text("\(filteredLogs.count) logs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search", text: $searchText)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Log list
            List {
                ForEach(filteredLogs) { entry in
                    LogEntryRow(entry: entry)
                }
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    // Filter logs
    private var filteredLogs: [LogEntry] {
        var logs = logCollector.logs
        
        // Filter by level
        if let type = selectedType {
            logs = logs.filter { $0.type == type }
        }
        
        // Search filter
        if !searchText.isEmpty {
            logs = logs.filter {
                $0.message.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                $0.file.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return logs.reversed()
    }
}

struct LogEntryRow: View {
    let entry: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: iconName(for: entry.type))
                    .foregroundColor(entry.type.color)
                
                Text(entry.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("[\(entry.category)]")
                    .font(.caption)
                    .padding(.horizontal, 4)
                    .background(categoryColor(for: entry.category))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Spacer()
                
                Text("\(entry.file):\(entry.line)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(entry.message)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
        }
        .padding(.vertical, 4)
    }
    
    private func iconName(for type: LogType) -> String {
        switch type {
        case .debug: return "magnifyingglass"
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        case .camera: return "camera"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Camera", "CameraVM", "CameraPreview", "CameraDebug":
            return Color.purple
        case "Navigation":
            return Color.blue
        case "Network":
            return Color.green
        case "UI":
            return Color.orange
        default:
            return Color.gray
        }
    }
} 