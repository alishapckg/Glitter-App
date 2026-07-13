import Foundation
import AVFoundation
import CoreGraphics

/// Lightweight wrapper around a loaded video: the AVAsset plus the
/// metadata the rest of the app needs (size, fps, first-frame preview).
struct VideoAsset {
  let url: URL
  let asset: AVAsset
  let naturalSize: CGSize
  let frameRate: Float
  let firstFrame: CGImage
  
  /// Loads a VideoAsset from disk, resolving orientation-aware size and
  /// grabbing the first frame for the wizard's paint canvas.
  static func load(from url: URL) async throws -> VideoAsset {
    let asset = AVURLAsset(url: url)
    let tracks = try await asset.loadTracks(withMediaType: .video)
    guard let track = tracks.first else {
      throw VideoAssetError.noVideoTrack
    }
    
    let naturalSize = try await track.load(.naturalSize)
    let transform = try await track.load(.preferredTransform)
    let displaySize = naturalSize.applying(transform)
    let size = CGSize(width: abs(displaySize.width), height: abs(displaySize.height))
    let frameRate = try await track.load(.nominalFrameRate)
    
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.requestedTimeToleranceBefore = .zero
    generator.requestedTimeToleranceAfter = .zero
    
    let firstFrame = try await withCheckedThrowingContinuation { continuation in
      generator.generateCGImageAsynchronously(for: .zero) { image, _, error in
        if let image {
          continuation.resume(returning: image)
        } else {
          continuation.resume(throwing: error ?? VideoAssetError.noFirstFrame)
        }
      }
    }
    
    return VideoAsset(url: url, asset: asset, naturalSize: size,
                      frameRate: frameRate, firstFrame: firstFrame)
  }
}
