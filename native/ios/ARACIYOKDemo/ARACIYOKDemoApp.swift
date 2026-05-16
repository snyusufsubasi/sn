import SwiftUI

@main
struct ARACIYOKDemoApp: App {
    @StateObject private var store = DemoStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
