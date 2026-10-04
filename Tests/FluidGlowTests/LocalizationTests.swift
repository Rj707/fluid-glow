import XCTest
@testable import FluidGlow

final class LocalizationTests: XCTestCase {
    let requiredLanguages = ["en", "es", "de", "fr", "ja", "pt-BR"]
    
    func testStringCatalogCompleteness() throws {
        let catalogPath = "/Users/saad/Documents/FluidGlow/Resources/Localizable.xcstrings"
        guard FileManager.default.fileExists(atPath: catalogPath),
              let data = FileManager.default.contents(atPath: catalogPath),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: [String: Any]] else {
            XCTFail("Localizable.xcstrings not found")
            return
        }
        
        let sampleKeys = [
            "Fluid Shaders", "Done", "Settings", "Sound Effects",
            "Haptic Feedback", "Clear Canvas", "VIP Pass", "Lifetime VIP Pass",
            "Restore Purchases", "Privacy Policy & Terms"
        ]
        
        for key in sampleKeys {
            guard let entry = strings[key],
                  let localizations = entry["localizations"] as? [String: [String: Any]] else {
                XCTFail("Missing catalog entry for key '\(key)'")
                continue
            }
            
            for lang in requiredLanguages where lang != "en" {
                guard let unit = localizations[lang]?["stringUnit"] as? [String: Any],
                      let value = unit["value"] as? String, !value.isEmpty else {
                    XCTFail("Missing '\(lang)' translation for key '\(key)'")
                    continue
                }
            }
        }
    }
}
