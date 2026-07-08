import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import Combine

/// Lightweight wrapper around the loaded video: the AVAsset plus the
/// metadata the rest of the app needs (size, fps, first frame preview).
struct VideoAsset {
  let url: URL
  let asset: AVAsset
  let naturalSize: CGSize
  let frameRate: Float
  let firstFrame: CGImage
}

/// Whole-app state, injected as an environment object. Grows over time
/// (wizard step, per-zone settings, etc.) - kept minimal here since this
/// file only needs to own the loaded video.
@MainActor
final class ProjectState: ObservableObject {
  @Published var videoAsset: VideoAsset?
  @Published var settings = ZoneSettings()
  @Published var importError: String?
  
  func loadVideo(from url: URL) {
    importError = nil
    Task {
      do {
        let asset = AVURLAsset(url: url)
        let tracks = try await asset.loadTracks(withMediaType: .video)
        guard let track = tracks.first else {
          importError = "This file has no video track."
          return
        }
        
        let naturalSize = try await track.load(.naturalSize)
        let transform = try await track.load(.preferredTransform)
        let displaySize = naturalSize.applying(transform)
        let size = CGSize(width: abs(displaySize.width), height: abs(displaySize.height))
        let frameRate = try await track.load(.nominalFrameRate)
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let firstFrame = try generator.copyCGImage(at: .zero, actualTime: nil)
        
        let videoAsset = VideoAsset(
          url: url,
          asset: asset,
          naturalSize: size,
          frameRate: frameRate,
          firstFrame: firstFrame
        )
        
        settings = ZoneSettings()
        settings.blur.mask.prepare(size: size)
        settings.glitter.mask.prepare(size: size)
        settings.glass.mask.prepare(size: size)
        
        self.videoAsset = videoAsset
      } catch {
        importError = "Could not open this video: \(error.localizedDescription)"
      }
    }
  }
}

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
