import SwiftUI

/// Top-level router: shows the import screen until a video is loaded,
/// then hands off to the step-by-step wizard.
struct RootView: View {
  @EnvironmentObject var projectState: ProjectState
  
  var body: some View {
    Group {
      switch projectState.phase {
      case .importing:
        ImportView()
      case .editing:
        Text("wizard")
      case .processing, .done:
        Text("processing")
      }
    }
    .animation(.easeInOut(duration: 0.25), value: projectState.phase)
  }
}
