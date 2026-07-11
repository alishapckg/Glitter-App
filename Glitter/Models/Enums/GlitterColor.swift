import Foundation
import CoreGraphics

enum GlitterColor: String, CaseIterable, Identifiable {
  case white, pink, gold, rainbow
  var id: String { rawValue }
  
  var cgColor: CGColor? {
    switch self {
    case .white:   return CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    case .pink:    return CGColor(red: 1.00, green: 0.67, blue: 0.86, alpha: 1)
    case .gold:    return CGColor(red: 0.96, green: 0.82, blue: 0.59, alpha: 1)
    case .rainbow: return nil // resolved per-particle in GlitterZoneEffect
    }
  }
}
