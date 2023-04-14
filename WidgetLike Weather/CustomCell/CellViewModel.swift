//
//  CellViewModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 04.04.2023.
//

import Foundation

class CellCityViewModel {
    
    
    private let cityItem: CellDataForViewModel
    
    var cityName: String {
        return cityItem.cityName ?? ""
    }
    
    var degrees: Int {
        return cityItem.degrees ?? 0
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
    
    init(item: CellDataForViewModel) {
        self.cityItem = item
    }
    
}
