

import UIKit
import Alamofire

class AIRequest {
    
    var query: String
    var lang: String
    var sessionId: String
    
    init(query: String, lang: String) {
        self.query = query
        self.lang = lang
        self.sessionId = "WB-" + Date().ticks.description
    }
    
    func getHeaders() -> HTTPHeaders {
        let clientAccessToken = "629b921375144d69916e9f4e3b3c1b9a"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + clientAccessToken,
            ]
        return headers
    }
    
    func toParameters() -> Parameters {
        
        let parameters: Parameters = [
            "query": query,
            "lang": lang,
            "sessionId": sessionId
        ]
        
        return parameters
    }
    
}

