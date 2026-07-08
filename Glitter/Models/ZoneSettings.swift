import Foundation
import CoreGraphics
import SwiftUI
import Combine

// MARK: - Y2K color palette (mirrors COLOR_SWATCHES from the Python version)

enum Y2KColor: String, CaseIterable, Identifiable {
  case none, pink, lilac, mint, blue, gold, custom
  
  var id: String { rawValue }
  
  /// nil means "no tint / no filter applied".
  var cgColor: CGColor? {
    switch self {
    case .none:   return nil
    case .pink:   return CGColor(red: 1.00, green: 0.51, blue: 0.78, alpha: 1)
    case .lilac:  return CGColor(red: 0.75, green: 0.55, blue: 0.88, alpha: 1)
    case .mint:   return CGColor(red: 0.69, green: 0.92, blue: 0.78, alpha: 1)
    case .blue:   return CGColor(red: 0.63, green: 0.82, blue: 1.00, alpha: 1)
    case .gold:   return CGColor(red: 0.94, green: 0.78, blue: 0.55, alpha: 1)
    case .custom: return nil // resolved via `customColor` on the owning settings struct
    }
  }
}

enum GlitterColor: String, CaseIterable, Identifiable {
  case white, pink, gold, rainbow
  var id: String { rawValue }
}

// MARK: - Per-zone settings

struct BlurZoneSettings {
  var enabled: Bool = true
  var strength: Double = 40        // 1-100
  var edgeSoftness: Double = 35    // 0-100
  var tint: Y2KColor = .pink
  var customTintColor: Color = .pink
  var mask = ZoneMask()
}

struct GlitterZoneSettings {
  var enabled: Bool = true
  var density: Double = 45         // 1-100
  var glow: Double = 60            // 1-100
  var color: GlitterColor = .gold
  var mask = ZoneMask()
}

struct GlassZoneSettings {
  var enabled: Bool = true
  var strength: Double = 55        // 1-100
  var opacity: Double = 55         // 0-100
  var mask = ZoneMask()
}

struct DustSettings {
  var enabled: Bool = true
  var intensity: Double = 35       // 0-100
}

struct ColorFilterSettings {
  var color: Y2KColor = .pink
  var customColor: Color = .pink
  var intensity: Double = 25       // 0-100
}

/// Bundles every step's settings, mirroring `Y2KZonesApp.settings()`
/// from the Python version.
struct ZoneSettings {
  var blur = BlurZoneSettings()
  var glitter = GlitterZoneSettings()
  var glass = GlassZoneSettings()
  var dust = DustSettings()
  var filter = ColorFilterSettings()
}

// MARK: - Painted mask storage

/// Holds the freehand-painted mask for one zone. Backed by a CGContext
/// bitmap so `MaskPainter` can draw into it with brush strokes, and
/// `EffectsPipeline` can read it out as a CGImage/CIImage for masking.
final class ZoneMask: ObservableObject {
  @Published private(set) var image: CGImage?
  
  private var context: CGContext?
  private var size: CGSize = .zero
  
  /// Call once the video's frame size is known (e.g. right after import).
  func prepare(size: CGSize) {
    guard size != self.size else { return }
    self.size = size
    let colorSpace = CGColorSpaceCreateDeviceGray()
    context = CGContext(
      data: nil,
      width: Int(size.width),
      height: Int(size.height),
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.none.rawValue
    )
    context?.setFillColor(gray: 0, alpha: 1)
    context?.fill(CGRect(origin: .zero, size: size))
    commit()
  }
  
  /// Paints a filled circle (a single brush dab) at `point` with the
  /// given radius. `PaintCanvasView` calls this continuously while
  /// dragging, same as `cv2.circle` in the Python version.
  func paintDab(at point: CGPoint, radius: CGFloat) {
    guard let context else { return }
    context.setFillColor(gray: 1, alpha: 1)
    let rect = CGRect(x: point.x - radius, y: point.y - radius,
                      width: radius * 2, height: radius * 2)
    context.fillEllipse(in: rect)
    commit()
  }
  
  /// Clears the mask back to empty (all black / no zone painted).
  func clear() {
    guard let context else { return }
    context.setFillColor(gray: 0, alpha: 1)
    context.fill(CGRect(origin: .zero, size: size))
    commit()
  }
  
  var isEmpty: Bool { image == nil }
  
  private func commit() {
    image = context?.makeImage()
  }
}
