import Foundation

enum APIKey {
    static let `default`: String = {
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let data = FileManager.default.contents(atPath: filePath),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let value = plist["API_KEY"] as? String else {
            print("Error: Unable to load API key.")
            return ""
        }
        if value.isEmpty || value.starts(with: "_") {
            print("Error: Invalid API key. Follow the instructions on the Gemini doc.")
            return ""
        }
        return value
    }()
}
