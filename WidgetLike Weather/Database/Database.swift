//
//  Database.swift
//  WidgetLike Weather
//
//  Created by Artem on 31.03.2023.
//

import Foundation
import SQLite
import Combine
import SQLite3

enum CityTables: String {
    case base = "tabla"
    case favorites = "Favorites"
    case filtered = "Filtering"
}

class Database {
    static let shared = Database()
    
    var network = NetworkManager()
    
    public var favoriteWorker = PassthroughSubject<String, Never>()
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
    
    
    
    public func addToFavorite(city: CellDataModel) {
        
       
        do {
            let id = Expression<Int>("id")
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let name = Expression<String>("City")
            let degrees = Expression<String>("degrees")
            let icon = Expression<String>("icon")
            let descriptionDegrees = Expression<String>("descriptionDegrees")
            let timeZone = Expression<Int>("timeZone")
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.favorites.rawValue)
            
            try db.run(table.insert(name <- city.cityName ?? "", degrees <- city.degrees ?? "", icon <- city.icon ?? "", descriptionDegrees <- city.descriptionDegrees ?? "", timeZone <- city.timeZone ?? 0))
       
            
            
        } catch {
            print(error)
        }
    }
    
    public func favoriteCount() -> Int {
        var result = 0
        
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let name = Expression<String>("City")
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.favorites.rawValue)
            
            result =  try db.scalar(table.select(name.count))
            return result
            
        } catch {
            print(error)
        }
        
        return result
    }
    
    public func allFavorites() -> [String] {
        var result: [String] = []
        
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let name = Expression<String>("City")
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.favorites.rawValue)
            
            
            for city in try db.prepare(table) {
                result.append(city[name])
            }
            
        } catch {
            print(error)
        }
        
        return result
    }
    
    public func allFavoritesModels() -> [CellCityViewModel] {
        var result: [CellCityViewModel] = []
        
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let name = Expression<String>("City")
            let degrees = Expression<String>("degrees")
            let icon = Expression<String>("icon")
            let descriptionDegrees = Expression<String>("descriptionDegrees")
            let timeZone = Expression<Int>("timeZone")
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.favorites.rawValue)
            
            
            for city in try db.prepare(table) {
                let viewModelItem = CellCityViewModel(item: CellDataModel(cityName: city[name], degrees: city[degrees], icon: city[icon], descriptionDegrees: city[descriptionDegrees], timeZone: city[timeZone]))
                result.append(viewModelItem)
            }
            
        } catch {
            print(error)
        }
        
        return result
    }
    public func updateFavoritesModels(closure: @escaping([CellCityViewModel]) -> Void)  {
        var resultArray: [CellCityViewModel] = []
        
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let name = Expression<String>("City")
            let degrees = Expression<String>("degrees")
            let icon = Expression<String>("icon")
            let descriptionDegrees = Expression<String>("descriptionDegrees")
            let timeZone = Expression<Int>("timeZone")
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.favorites.rawValue)
            
            
            for city in try db.prepare(table) {
                print("mamacita \(city)")
                self.network.fetchData(requestType: .city(city: city[name])) { [weak self] result in
                    switch result {
                    case .success(let data):
                        let viewModelItem = CellCityViewModel(item: CellDataModel(currentData: data)!)
                        let nameCity = viewModelItem.cityName
                        let degreessCity = viewModelItem.degrees
                        let iconCity = viewModelItem.icon
                        let descriptionDegreesCity = viewModelItem.description
                        let timeZoneCity = viewModelItem.timezone
                        
                        let filt = table.filter( name.like("\(city[name])%") )
                        try? db.run(filt.update(degrees <- degreessCity, name <- nameCity, icon <- iconCity, descriptionDegrees <- descriptionDegreesCity, timeZone <- timeZoneCity ))
                        closure(resultArray)
                        resultArray.append(viewModelItem)
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
                
           
            }
            
        } catch {
            print(error)
        }
        
        
    }
    
    public func filteringFavorites(degree: String) {
        
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let db = try Connection("\(path)/cities.db")
            let table = Table(CityTables.favorites.rawValue)
            let destinationTable = Table(CityTables.filtered.rawValue)
            let degrees = Expression<String>("degrees")
            
            let filter = table.filter(degrees >= degree)
            let all = Array(try db.prepare(filter))
//            print("mar \(all)")
            for i in try db.prepare(filter) {
                print("mar \(i)")
            }

           



            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func removeFromFavorite(city: String)  {
        
        do {
            
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            
            let db = try Connection("\(path)/cities.db")
            
            let table = Table(CityTables.favorites.rawValue)
            let id = Expression<Int>("id")
            let name = Expression<String>("City")
            let deletingCity = table.filter(name.like("\(city)%"))


            try db.run(deletingCity.delete())
            
         
            

            
//            for item in try db.prepare(filt) {
//                for i in 1...cint {
//                    let stringquery = "UPDATE Favorites SET id = ROW_NUMBER()OVER()RowNum;"
//                    try db.execute(stringquery)
//                }
//            }
//            for item in try db.prepare(filt) {
//                for i in 1...4 {
////                    print("mem - \(i)")
////                    print("mem - \(cint)")
////                    try db.run(filt.insert([id] <- mass[2]))
//                    try db.run(filt.update( item[id] <- i))
//
////                    print("memm - \(item[id])")
//
//                }
//
//            }
        
            
        } catch {
            
            print(error.localizedDescription)
        }
        
        
        
    }
}
