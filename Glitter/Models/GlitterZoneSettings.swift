import Foundation

struct GlitterZoneSettings {
  var enabled: Bool = true
  var density: Double = 45         // 1-100
  var glow: Double = 60            // 1-100
  var color: GlitterColor = .gold
  var mask = ZoneMask()
}
