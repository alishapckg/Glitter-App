import Foundation
import AVFoundation

/// Lightweight wrapper around the loaded video: the AVAsset plus the
/// metadata the rest of the app needs (size, fps, first frame preview).
struct VideoAsset {
  let url: URL
  let asset: AVAsset
  let naturalSize: CGSize
  let frameRate: Float
  let firstFrame: CGImage
}
