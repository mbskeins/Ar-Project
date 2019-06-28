

import UIKit

class WeatherIntent {
    
    var condition : String?
    var outfit : String?
    
    init(_ parameters: NSDictionary) {
        serialize(parameters)
    }
    
    // MARK : serialize object
    func serialize(_ parameters: NSDictionary) {
        if let condition = parameters["condition"] as? String {
            self.condition = condition
        }
        if let outfit = parameters["outfit"] as? String {
            self.outfit = outfit
        }
    }
    
}
