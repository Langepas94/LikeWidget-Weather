//
//  DataService.swift
//  WidgetLike Weather
//
//  Created by Artem on 04.04.2023.
//

import Foundation
import UIKit

class DataIterator {
    
    var timer: Timer?
    
    static var shared = DataIterator()
    let network = NetworkManager()

    func updatingData(closure: @escaping([CellCityViewModel])-> Void) {
        let result = DatabaseService.shared.updateFavoritesModels { result in
            closure(result)
        }
    }
    
    func preload(closure: @escaping([CellCityViewModel])-> Void)  {
        
        let result = DatabaseService.shared.allFavoritesModels()
        closure(result)
    }
    
    func filtering(degree: String, closure: @escaping([CellCityViewModel])-> Void)  {
        
        let result = DatabaseService.shared.filteringFavorites(degree: degree)
        closure(result)
    }
    
    var str: String = "" {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("timeChanged"), object: nil)
        }
    }
    
    init() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    @objc func updateTime() {
       
        let date = Date()

        let dateFormatterHour = DateFormatter()
        dateFormatterHour.dateFormat = "HH"
        let hourString = dateFormatterHour.string(from: date)
        let formattedHourString = String(format: "%02d", Int(hourString)!)
        
        let dateFormatterMinute = DateFormatter()
        dateFormatterMinute.dateFormat = "mm"
        let minuteString = dateFormatterMinute.string(from: date)
        let formattedMinuteString = String(format: "%02d", Int(minuteString)!)
        
        let timeString = "\(formattedHourString): \(formattedMinuteString)"
        
        NotificationCenter.default.post(name: Notification.Name("time"), object: nil)
    }
}

