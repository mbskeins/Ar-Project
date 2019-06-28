
import UIKit

class AddressIntent {
    
    var city : String?
    var country : String?
    var street : String?
    var zipCode : String?
        
    init(_ parameters: NSDictionary) {
        serialize(parameters)
    }
    
    // MARK : serialize object
    func serialize(_ parameters: NSDictionary) {
        if let address = parameters["address"] as? NSDictionary {
            if let city = address["city"] as? String {
                self.city = city
            }
            if let country = address["country"] as? String {
                self.country = country
            }
            if let street = address["street-address"] as? String {
                self.street = street
            }
            if let zipCode = address["zip-code"] as? String {
                self.zipCode = zipCode
            }
        }
    }
    
}
