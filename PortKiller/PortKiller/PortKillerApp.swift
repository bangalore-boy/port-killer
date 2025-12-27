import SwiftUI

@main
struct PortKillerApp: App {
    var body: some Scene {
        MenuBarExtra("Port Killer", systemImage: "network") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
