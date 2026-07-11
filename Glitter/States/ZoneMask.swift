import Foundation
import SwiftUI
import Combine

/// Holds the freehand-painted mask for one zone. Backed by a CGContext
/// bitmap so `MaskPainter` can draw brush strokes into it, and
/// `EffectsPipeline` can read it out as a CGImage/CIImage for masking.
///
/// Class (not struct) on purpose: painting is many small in-place mutations
/// of the same bitmap; value semantics would force a full-image copy per
/// brush dab, which is both slow and unnecessary here.
final class ZoneMask: ObservableObject {
  @Published private(set) var image: CGImage?
  
  private var context: CGContext?
  private var size: CGSize = .zero
  private var lastPaintPoint: CGPoint?
  
  /// Call once the video's frame size is known (e.g. right after import).
  func prepare(size: CGSize) {
    guard size != self.size, size.width > 0, size.height > 0 else { return }
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
  
  /// Begins a new stroke (mouse/trackpad down) at `point`.
  func beginStroke(at point: CGPoint, radius: CGFloat) {
    lastPaintPoint = point
    paintDab(at: point, radius: radius)
  }
  
  /// Continues the current stroke to `point`, filling the segment between
  /// the last point and this one so fast drags don't leave gaps - same
  /// role as the `cv2.line` call between dabs in the Python version.
  func continueStroke(to point: CGPoint, radius: CGFloat) {
    guard let context else { return }
    if let last = lastPaintPoint {
      context.setLineWidth(radius * 2)
      context.setLineCap(.round)
      context.setStrokeColor(gray: 1, alpha: 1)
      context.beginPath()
      context.move(to: last)
      context.addLine(to: point)
      context.strokePath()
    }
    paintDab(at: point, radius: radius)
    lastPaintPoint = point
  }
  
  func endStroke() {
    lastPaintPoint = nil
  }
  
  /// Paints a single filled circle (one brush dab) at `point`.
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
