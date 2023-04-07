//
//  CellViewModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 04.04.2023.
//

import Foundation

class CellCityViewModel {
   
    
    private let cityItem: CellDataModel
    
    
    
    var cityName: String {
        return cityItem.cityName ?? ""
    }
    
    var degrees: String {
        return cityItem.degrees ?? ""
    }
    
    var description: String {
        return cityItem.descriptionDegrees ?? ""
    }
    
    var icon: String {
        return cityItem.icon ?? ""
    }
    
    var timezone: Int {
        return cityItem.timeZone ?? 0
    }
    
    var timeLabels: String?
    
    var timer: Timer?
    
    init(item: CellDataModel) {
        self.cityItem = item
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
       
        let date = Date()
        var timing = TimeZone(secondsFromGMT: timezone)
        let dateFormatterHour = DateFormatter()
        dateFormatterHour.timeZone = timing
        dateFormatterHour.dateFormat = "HH"
        let hourString = dateFormatterHour.string(from: date)
        let formattedHourString = String(format: "%02d", Int(hourString)!)
        
        let dateFormatterMinute = DateFormatter()
        dateFormatterMinute.timeZone = timing
        dateFormatterMinute.dateFormat = "mm"
        let minuteString = dateFormatterMinute.string(from: date)
        let formattedMinuteString = String(format: "%02d", Int(minuteString)!)
        
        
        
        self.timeLabels = "\(formattedHourString): \(formattedMinuteString)"
        NotificationCenter.default.post(name: Notification.Name("timeChange"), object: self)
        
        
//        if Int(hourString)! >= 18 || Int(hourString)! <= 5  {
//            self.mainView.backgroundColor = .systemFill
//        } else {
//            self.mainView.backgroundColor = .white
//        }
    }
    
}

