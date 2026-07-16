import SwiftUI
import Combine
import Observation

@main
struct GlitterApp: App {
  @StateObject private var projectState = ProjectState()
  
  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(projectState)
        .frame(minWidth: 900, minHeight: 600)
    }
    .windowStyle(.titleBar)
    .windowToolbarStyle(.unified)
  }
}
