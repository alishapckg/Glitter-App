import Foundation

/// Bundles every step's settings, mirroring `Y2KZonesApp.settings()`
/// from the Python version.
struct ZoneSettings {
  var blur = BlurZoneSettings()
  var glitter = GlitterZoneSettings()
  var glass = GlassZoneSettings()
  var dust = DustSettings()
  var filter = ColorFilterSettings()
}
