import SwiftUI

struct ProcessingView: View {
  @EnvironmentObject var projectState: ProjectState
  
  var body: some View {
    VStack(spacing: 24) {
      Spacer()
      
      switch projectState.phase {
      case .processing:
        ProgressView(value: projectState.renderProgress)
          .frame(width: 320)
        Text(projectState.renderStatusText)
          .font(.callout)
          .foregroundStyle(.secondary)
        Text("\(Int(projectState.renderProgress * 100))%")
          .font(.title3.monospacedDigit())
        
      case .done(let outputURL):
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 56))
          .foregroundStyle(.green)
        Text("Done!")
          .font(.title.bold())
        Text(outputURL.lastPathComponent)
          .font(.callout)
          .foregroundStyle(.secondary)
        
        HStack(spacing: 12) {
          Button("Show in Finder") {
            NSWorkspace.shared.activateFileViewerSelecting([outputURL])
          }
          Button("Start Over") {
            projectState.reset()
          }
          .buttonStyle(.borderedProminent)
          .tint(.pink)
        }
        
      default:
        EmptyView()
      }
      
      if let error = projectState.renderError {
        Text(error)
          .font(.callout)
          .foregroundStyle(.red)
        Button("Back to Editing") {
          projectState.phase = .editing
        }
      }
      
      Spacer()
    }
    .padding(40)
  }
}
