import Foundation
import CoreGraphics

enum Y2KColor: String, CaseIterable, Identifiable {
  case none, pink, lilac, mint, blue, gold, custom
  
  var id: String { rawValue }
  
  /// nil means "no tint / no filter applied". For `.custom`, the owning
  /// settings struct's `customColor`/`customTintColor` is used instead.
  var cgColor: CGColor? {
    switch self {
    case .none:   return nil
    case .pink:   return CGColor(red: 1.00, green: 0.51, blue: 0.78, alpha: 1)
    case .lilac:  return CGColor(red: 0.75, green: 0.55, blue: 0.88, alpha: 1)
    case .mint:   return CGColor(red: 0.69, green: 0.92, blue: 0.78, alpha: 1)
    case .blue:   return CGColor(red: 0.63, green: 0.82, blue: 1.00, alpha: 1)
    case .gold:   return CGColor(red: 0.94, green: 0.78, blue: 0.55, alpha: 1)
    case .custom: return nil
    }
  }
}
