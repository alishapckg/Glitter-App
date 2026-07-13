import Foundation

enum VideoAssetError: LocalizedError {
  case noVideoTrack
  case noFirstFrame
  
  var errorDescription: String? {
    switch self {
    case .noVideoTrack: return "This file has no video track."
    case .noFirstFrame: return "Could not read the first frame of this video."
    }
  }
}
