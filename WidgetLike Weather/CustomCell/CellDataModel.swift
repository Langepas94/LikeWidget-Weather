//
//  CellDataModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 04.04.2023.
//

import Foundation
import UIKit

enum CellDataModel {
    case initial
    case loading(Data)
    case success(Data)
    case failure(Data)
    
    struct Data {
        let cityName: String?
        let degrees: String?
        let icon: String?
        let descriptionDegrees: String?
        let timeZone: Int?
    }
}
