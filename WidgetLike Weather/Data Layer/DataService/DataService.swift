//
//  DataService.swift
//  WidgetLike Weather
//
//  Created by Artem on 04.04.2023.
//

import Foundation
import UIKit

// get networkFetch


class DataService {
    
    var timer: Timer?
    
    static var shared = DataService()
    let network = NetworkManager()

    func updatingData(closure: @escaping([CellCityViewModel])-> Void) {
        let result = Database.shared.updateFavoritesModels { result in
            closure(result)
        }
    }
    
    func preload(closure: @escaping([CellCityViewModel])-> Void)  {
        
        let result = Database.shared.allFavoritesModels()
        closure(result)
        
    }
    
    func filtering(degree: String, closure: @escaping([CellCityViewModel])-> Void)  {
        
        let result = Database.shared.filteringFavorites(degree: degree)
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

//        var timing = TimeZone(secondsFromGMT: timezone)
        let dateFormatterHour = DateFormatter()
//        dateFormatterHour.timeZone = timing
        dateFormatterHour.dateFormat = "HH"
        let hourString = dateFormatterHour.string(from: date)
        let formattedHourString = String(format: "%02d", Int(hourString)!)
        
        let dateFormatterMinute = DateFormatter()
//        dateFormatterMinute.timeZone = timing
        dateFormatterMinute.dateFormat = "mm"
        let minuteString = dateFormatterMinute.string(from: date)
        let formattedMinuteString = String(format: "%02d", Int(minuteString)!)
        
        let timeString = "\(formattedHourString): \(formattedMinuteString)"
//        let sendTime = ["time": date]
        
        NotificationCenter.default.post(name: Notification.Name("time"), object: nil)
       
           
        

        
        
        
        
//        NotificationCenter.default.post(name: Notification.Name("time"), object: nil, userInfo: sendTime)
//        var sendTime = ["time": date] {
//            didSet {
//                NotificationCenter.default.post(name: Notification.Name("time"), object: nil, userInfo: sendTime)
//                print(sendTime)
//            }
//        }
        
      
            
        
        
        
        
//        self.timeLabels = "\(formattedHourString): \(formattedMinuteString)"
//        NotificationCenter.default.post(name: Notification.Name("timeChange"), object: self)
        
        
//        if Int(hourString)! >= 18 || Int(hourString)! <= 5  {
//            self.mainView.backgroundColor = .systemFill
//        } else {
//            self.mainView.backgroundColor = .white
//        }
    }
    
}

