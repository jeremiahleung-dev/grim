import CoreLocation
import Foundation

class WeatherService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((String?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func fetch(completion: @escaping (String?) -> Void) {
        self.completion = completion
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            completion(nil)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .notDetermined:
            break
        default:
            completion?(nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { completion?(nil); return }
        fetchOpenMeteo(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil)
    }

    private func fetchOpenMeteo(lat: Double, lon: Double) {
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weathercode&temperature_unit=fahrenheit&timezone=auto&forecast_days=1"
        guard let url = URL(string: urlStr) else { completion?(nil); return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let data = data,
                let json  = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let curr  = json["current"] as? [String: Any],
                let temp  = curr["temperature_2m"] as? Double,
                let code  = curr["weathercode"] as? Int
            else {
                DispatchQueue.main.async { self?.completion?(nil) }
                return
            }
            let description = "\(Self.condition(for: code)), \(Int(temp))°F"
            DispatchQueue.main.async { self?.completion?(description) }
        }.resume()
    }

    private static func condition(for code: Int) -> String {
        switch code {
        case 0:       return "Clear sky"
        case 1:       return "Mainly clear"
        case 2:       return "Partly cloudy"
        case 3:       return "Overcast"
        case 45, 48:  return "Foggy"
        case 51...55: return "Drizzle"
        case 61...65: return "Rain"
        case 71...75: return "Snow"
        case 80...82: return "Rain showers"
        case 95:      return "Thunderstorm"
        default:      return "Mixed conditions"
        }
    }
}
