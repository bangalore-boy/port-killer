import Foundation
import Combine

/// Manages port scanning and process termination
@MainActor
class PortManager: ObservableObject {
    @Published var processes: [PortProcess] = []
    @Published var isScanning: Bool = false
    @Published var lastError: String?
    
    private var refreshTimer: Timer?
    
    init() {
        startAutoRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    /// Start auto-refresh timer (every 5 seconds)
    func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.scanAllPorts()
            }
        }
        // Initial scan
        Task {
            await scanAllPorts()
        }
    }
    
    /// Scan all listening TCP ports
    func scanAllPorts() async {
        isScanning = true
        lastError = nil
        
        do {
            let output = try await runCommand("/usr/sbin/lsof", arguments: ["-iTCP", "-sTCP:LISTEN", "-P", "-n"])
            processes = parseProcesses(from: output)
        } catch {
            lastError = error.localizedDescription
            processes = []
        }
        
        isScanning = false
    }
    
    /// Scan a specific port
    func scanPort(_ port: Int) async -> PortProcess? {
        do {
            let output = try await runCommand("/usr/sbin/lsof", arguments: ["-iTCP:\(port)", "-sTCP:LISTEN", "-P", "-n"])
            let found = parseProcesses(from: output)
            return found.first { $0.port == port }
        } catch {
            return nil
        }
    }
    
    /// Kill a process by PID
    func killProcess(_ process: PortProcess) async -> Bool {
        do {
            _ = try await runCommand("/bin/kill", arguments: ["-9", String(process.pid)])
            // Refresh after kill
            await scanAllPorts()
            return true
        } catch {
            lastError = "Failed to kill process: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Kill process on a specific port
    func killProcessOnPort(_ port: Int) async -> Bool {
        if let process = await scanPort(port) {
            return await killProcess(process)
        }
        return false
    }
    
    // MARK: - Private Methods
    
    private func runCommand(_ path: String, arguments: [String]) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let pipe = Pipe()
            
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = arguments
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                continuation.resume(returning: output)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func parseProcesses(from output: String) -> [PortProcess] {
        var result: [PortProcess] = []
        let lines = output.components(separatedBy: "\n")
        
        // Skip header line
        for line in lines.dropFirst() {
            guard !line.isEmpty else { continue }
            
            let components = line.split(separator: " ", omittingEmptySubsequences: true)
            guard components.count >= 9 else { continue }
            
            let processName = String(components[0])
            guard let pid = Int(components[1]) else { continue }
            
            // Parse port from the NAME column (last column, format: *:PORT or IP:PORT)
            let nameColumn = String(components.last ?? "")
            guard let port = extractPort(from: nameColumn) else { continue }
            
            // Get command (process name is usually sufficient)
            let command = processName
            
            let process = PortProcess(
                port: port,
                pid: pid,
                processName: processName,
                command: command
            )
            
            // Avoid duplicates (same port and PID)
            if !result.contains(where: { $0.port == port && $0.pid == pid }) {
                result.append(process)
            }
        }
        
        return result.sorted { $0.port < $1.port }
    }
    
    private func extractPort(from nameColumn: String) -> Int? {
        // Format: *:PORT or IP:PORT or [::]:PORT
        let parts = nameColumn.components(separatedBy: ":")
        guard let lastPart = parts.last else { return nil }
        return Int(lastPart)
    }
}
