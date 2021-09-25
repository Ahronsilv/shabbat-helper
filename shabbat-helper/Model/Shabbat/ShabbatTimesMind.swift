//
//  ShabbatTimesMind.swift
//  jewish-helper
//
//  Created by Haim Aharon Zilberman on 23/09/2021.
//

import Foundation
import SwiftyJSON
import Alamofire

private struct Parameters : Encodable {
    let cfg : String
    let geo : String
    let M   : String
    let m   : Int
    let latitude : Float
    let longitude : Float
    let tzid : String
    let lg : String
}

struct ShabbatTimesMind {
    var delegate: ShabbatTimesDelegate?
    
    private func processData(json : JSON) {
        if let arrItems = json["items"].array {
            var st = ShabbatTimes()
            
            for item in arrItems {
                if item["category"].stringValue == "candles" {
                    let shabbatItem = ShabbatItem(title: item["title"].stringValue, date: item["date"].stringValue, category: item["category"].stringValue, subcat: item["subcat"].stringValue, title_orig: item["title_orig"].stringValue, hebrew: item["hebrew"].stringValue)
                    st.items.append(shabbatItem)
                }
            }
            if let safeDelegate = delegate {
                safeDelegate.didReceiveResults(with: st)
            }
        }
    }
    
    func updateData(lat: Float, long: Float, timesoneId: String) {
        let pars = Parameters(cfg: "json", geo: "pos", M: "off", m: 0, latitude: lat, longitude: long, tzid: timesoneId, lg: "h")
        
        AF.request("https://www.hebcal.com/shabbat"
                   ,method: .get
                   ,parameters: pars
                   ,encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            if let safeValue = response.value {
                processData(json: JSON(safeValue))
            }
        }
    }
}
