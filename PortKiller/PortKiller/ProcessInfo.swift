import Foundation

/// Represents a process listening on a specific port
struct PortProcess: Identifiable, Hashable {
    let id = UUID()
    let port: Int
    let pid: Int
    let processName: String
    let command: String
    
    var displayName: String {
        if processName.isEmpty {
            return "PID \(pid)"
        }
        return processName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(port)
        hasher.combine(pid)
    }
    
    static func == (lhs: PortProcess, rhs: PortProcess) -> Bool {
        lhs.port == rhs.port && lhs.pid == rhs.pid
    }
}

/// Common development ports to monitor
enum CommonPorts {
    static let all: [Int] = [
        3000,  // React, Node.js
        3001,  // React alternate
        4200,  // Angular
        5000,  // Flask, ASP.NET
        5173,  // Vite
        5174,  // Vite alternate
        8000,  // Django, Python
        8080,  // Tomcat, Spring
        8081,  // Alternate HTTP
        8888,  // Jupyter
        9000,  // PHP-FPM
        9090,  // Prometheus
    ]
}
