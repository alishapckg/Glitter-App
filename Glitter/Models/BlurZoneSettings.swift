import Foundation
import SwiftUI

struct BlurZoneSettings {
  var enabled: Bool = true
  var strength: Double = 40        // 1-100
  var edgeSoftness: Double = 35    // 0-100
  var tint: Y2KColor = .pink
  var customTintColor: Color = .pink
  var mask = ZoneMask()
}
