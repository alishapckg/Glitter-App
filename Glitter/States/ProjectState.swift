import SwiftUI
import Observation
import Combine
import AVFoundation

enum AppPhase: Equatable {
  case importing, editing, processing, done(outputURL: URL)
  
  static func ==(lhs: AppPhase, rhs: AppPhase) -> Bool {
    switch (lhs, rhs) {
    case (.importing, .importing), (.editing, .editing), (.processing, .processing):
      return true
    case (.done(let a), .done(let b)):
      return a == b
    default:
      return false
    }
  }
}


/// Whole-app state, injected as an environment object. Grows over time
/// (wizard step, per-zone settings, etc.) - kept minimal here since this
/// file only needs to own the loaded video.
@MainActor
final class ProjectState: ObservableObject {
  @Published var phase: AppPhase = .importing
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
