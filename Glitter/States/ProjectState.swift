import Foundation
import SwiftUI
import Combine

enum AppPhase: Equatable {
  case importing
  case editing
  case processing
  case done(outputURL: URL)
  
  static func == (lhs: AppPhase, rhs: AppPhase) -> Bool {
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

/// Whole-app state, injected as an environment object. Owns the loaded
/// video, the current wizard step, all zone settings, and render progress.
@MainActor
final class ProjectState: ObservableObject {
  @Published var phase: AppPhase = .importing
  @Published var videoAsset: VideoAsset?
  @Published var settings = ZoneSettings()
  @Published var importError: String?
  
  @Published var wizardStep: Int = 1   // 1...5, mirrors the Python steps
  @Published var renderProgress: Double = 0   // 0...1
  @Published var renderStatusText: String = ""
  @Published var renderError: String?
  
  func loadVideo(from url: URL) {
    importError = nil
    Task {
      do {
        let asset = try await VideoAsset.load(from: url)
        
        var freshSettings = ZoneSettings()
        freshSettings.blur.mask.prepare(size: asset.naturalSize)
        freshSettings.glitter.mask.prepare(size: asset.naturalSize)
        freshSettings.glass.mask.prepare(size: asset.naturalSize)
        
        self.settings = freshSettings
        self.videoAsset = asset
        self.wizardStep = 1
        self.phase = .editing
      } catch {
        self.importError = error.localizedDescription
      }
    }
  }
  
  func reset() {
    videoAsset = nil
    settings = ZoneSettings()
    importError = nil
    wizardStep = 1
    renderProgress = 0
    renderStatusText = ""
    renderError = nil
    phase = .importing
  }
  
  func startProcessing() {
    guard let videoAsset else { return }
    phase = .processing
    renderProgress = 0
    renderError = nil
    
    Task {
//      do {
//        let outputURL = try Self.defaultOutputURL(for: videoAsset.url)
//        let pipeline = EffectsPipeline(settings: settings)
//        try await VideoProcessor.process(
//          asset: videoAsset,
//          pipeline: pipeline,
//          outputURL: outputURL
//        ) { [weak self] progress, status in
//          Task { @MainActor in
//            self?.renderProgress = progress
//            self?.renderStatusText = status
//          }
//        }
//        self.phase = .done(outputURL: outputURL)
//      } catch {
//        self.renderError = error.localizedDescription
//        self.phase = .editing
//      }
    }
  }
  
  private static func defaultOutputURL(for inputURL: URL) throws -> URL {
    let base = inputURL.deletingPathExtension().lastPathComponent
    let directory = inputURL.deletingLastPathComponent()
    return directory.appendingPathComponent("\(base)_y2k.mp4")
  }
}
