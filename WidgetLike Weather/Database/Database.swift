//
//  Database.swift
//  WidgetLike Weather
//
//  Created by Artem on 31.03.2023.
//

import Foundation
import SQLite
import Combine

enum CityTables: String {
    case base = "tabla"
    case favorites = "Favorites"
}

class Database {
    static let shared = Database()
    
    public func getCityFromDBtoStringArray(chars: String) -> [String]  {
        
        var resultArray: [String] = []
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let isFavorite = Expression<Bool>("isFavorite")
            let name = Expression<String>("City")
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.base.rawValue)
            
            let result = table.filter(name.like("\(chars)%"))
            
            for city in try db.prepare(result) {
                resultArray.append(city[name])
            }
            
        } catch {
            
        }
        return resultArray
    }
    
 
    
    public func addToFavorite(city: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let name = Expression<String>("City")
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.favorites.rawValue)
            
            try db.run(table.insert(name <- city))
            
        } catch {
            print(error)
        }
    }
    
    public func removeFromFavorite(city: String) -> Future<Void, Error> {
        Future { promise in
            do {
                let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                ).first!
                
                let name = Expression<String>("City")
                let db = try Connection("\(path)/cities.db")
                let table = Table(CityTables.favorites.rawValue)
                let deletingCity = table.filter(name.like("\(city)"))
                try db.run(deletingCity.delete())
                promise(.success(()))
            } catch {
                promise(.failure(error))
                print(error)
            }
            
        }
        
    }
}
