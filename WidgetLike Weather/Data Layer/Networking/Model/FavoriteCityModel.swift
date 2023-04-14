//
//  FAvoriteCityModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 20.03.2023.
//

import Foundation


class FavoriteCity {

    var name: String
    var degrees: Double?
    
    internal init(name: String, degrees: Double? = nil) {
        self.name = name
        self.degrees = degrees
    }
}
