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

/// Top-level router: shows the import screen until a video is loaded,
/// then hands off to the step-by-step wizard.
struct RootView: View {
  @EnvironmentObject var projectState: ProjectState
  
  var body: some View {
    Group {
      if projectState.videoAsset == nil {
        ImportView()
      } else {
        // WizardView() will replace this once the 5-step UI exists.
        Text("Video loaded - wizard goes here next.")
          .font(.title2)
          .foregroundStyle(.secondary)
      }
    }
    .animation(.easeInOut(duration: 0.25), value: projectState.videoAsset == nil)
  }
}
