import SwiftUI

struct MenuBarView: View {
    @StateObject private var portManager = PortManager()
    @State private var customPort: String = ""
    @State private var showingCustomPortResult: Bool = false
    @State private var customPortProcess: PortProcess?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            headerSection
            
            Divider()
                .padding(.vertical, 4)
            
            // Active Ports Section
            activePortsSection
            
            Divider()
                .padding(.vertical, 4)
            
            // Custom Port Section
            customPortSection
            
            Divider()
                .padding(.vertical, 4)
            
            // Footer
            footerSection
        }
        .padding(8)
        .frame(width: 300)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "network")
                .foregroundColor(.blue)
            Text("Port Killer")
                .font(.headline)
            Spacer()
            ProgressView()
                .scaleEffect(0.6)
                .frame(width: 16, height: 16)
                .opacity(portManager.isScanning ? 1 : 0)
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Active Ports
    
    private var activePortsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Active Ports")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    Task {
                        await portManager.scanAllPorts()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }
            
            if portManager.processes.isEmpty {
                Text("No processes found on open ports")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(portManager.processes) { process in
                            ProcessRow(process: process) {
                                Task {
                                    await portManager.killProcess(process)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            
            if let error = portManager.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Custom Port
    
    private var customPortSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Custom Port")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Enter port (e.g., 3000)", text: $customPort)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                    .onSubmit {
                        checkCustomPort()
                    }
                    .onChange(of: customPort) { newValue in
                        if newValue.isEmpty {
                            showingCustomPortResult = false
                            customPortProcess = nil
                        }
                    }
                
                Button("Check") {
                    checkCustomPort()
                }
                .disabled(customPort.isEmpty)
                
                Button("Kill") {
                    killCustomPort()
                }
                .disabled(customPort.isEmpty)
                .foregroundColor(.red)
            }
            
            if showingCustomPortResult {
                if let process = customPortProcess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                        Text("Port \(process.port): \(process.displayName) (PID \(process.pid))")
                            .font(.caption)
                    }
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Port is free")
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    // MARK: - Footer
    
    private var footerSection: some View {
        HStack {
            Text("Auto-refresh: 5s")
                .font(.caption2)
                .foregroundColor(.secondary)
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Actions
    
    private func checkCustomPort() {
        guard let port = Int(customPort) else { return }
        Task {
            customPortProcess = await portManager.scanPort(port)
            showingCustomPortResult = true
        }
    }
    
    private func killCustomPort() {
        guard let port = Int(customPort) else { return }
        Task {
            _ = await portManager.killProcessOnPort(port)
            customPortProcess = nil
            showingCustomPortResult = true
        }
    }
}

// MARK: - Process Row

struct ProcessRow: View {
    let process: PortProcess
    let onKill: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(":\(process.port)")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(process.displayName)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Text("PID: \(process.pid)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onKill) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .help("Kill process")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isHovering ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    MenuBarView()
}
