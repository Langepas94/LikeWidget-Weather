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
  
}

