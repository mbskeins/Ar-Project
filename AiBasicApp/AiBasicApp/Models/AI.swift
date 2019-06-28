

import UIKit

class AI {
    
    var id: String
    var lang: String
    var score: Double
    var intent: Intent
    
    required init(id: String, lang: String, score: Double) {
        self.id = id
        self.lang = lang
        self.score = score
        self.intent = Intent(intentName: "")
    }
    
}

