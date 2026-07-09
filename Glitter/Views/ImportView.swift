import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import Combine


struct ImportView: View {
  @EnvironmentObject var projectState: ProjectState
  @State private var isDropTargeted = false
  @State private var showFilePicker = false
  
  var body: some View {
    VStack(spacing: 24) {
      Spacer()
      
      Image(systemName: "wand.and.stars")
        .font(.system(size: 56))
        .foregroundStyle(.pink.gradient)
      
      Text("y2k-zones")
        .font(.largeTitle.bold())
      
      Text("Drop a video here, or choose a file to get started.")
        .font(.title3)
        .foregroundStyle(.secondary)
      
      dropZone
      
      Button("Choose Video…") {
        showFilePicker = true
      }
      .buttonStyle(.borderedProminent)
      .tint(.pink)
      
      if let error = projectState.importError {
        Text(error)
          .font(.callout)
          .foregroundStyle(.red)
      }
      
      Spacer()
    }
    .padding(40)
    .fileImporter(
      isPresented: $showFilePicker,
      allowedContentTypes: [.movie, .video, .quickTimeMovie, .mpeg4Movie],
      allowsMultipleSelection: false
    ) { result in
      if case .success(let urls) = result, let url = urls.first {
        projectState.loadVideo(from: url)
      }
    }
  }
  
  private var dropZone: some View {
    RoundedRectangle(cornerRadius: 16)
      .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
      .foregroundStyle(isDropTargeted ? Color.pink : Color.secondary.opacity(0.4))
      .frame(width: 420, height: 220)
      .overlay {
        VStack(spacing: 8) {
          Image(systemName: "film")
            .font(.system(size: 32))
          Text(".mov, .mp4")
            .font(.caption)
        }
        .foregroundStyle(.secondary)
      }
      .onDrop(of: [.movie, .video, .quickTimeMovie, .mpeg4Movie],
              isTargeted: $isDropTargeted) { providers in
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: UTType.movie.identifier) { item, _ in
          if let url = item as? URL {
            DispatchQueue.main.async {
              projectState.loadVideo(from: url)
            }
          }
        }
        return true
      }
  }
}
