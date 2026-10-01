import SwiftUI

@main
struct SakuraPlannerApp: App {
    init() {
        NotificationHelper.requestPermission()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
