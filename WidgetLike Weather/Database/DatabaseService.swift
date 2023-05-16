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

class DatabaseService {
    static let shared = DatabaseService()
    
    var network = NetworkManager()
    
    let db: Connection = {
        let path = Bundle.main.bundlePath
        // if u want use document directory or put your own database
//        let path = NSSearchPathForDirectoriesInDomains(
//            .documentDirectory, .userDomainMask, true
//        ).first!

        do {
            return try Connection("\(path)/cities.db")

            
        } catch {
            fatalError()
        }
    }()
    
    public var favoriteWorker = PassthroughSubject<String, Never>()
    public func getCityFromDBtoStringArray(chars: String) -> [String]  {
        
        var resultArray: [String] = []
        do {
            
            let isFavorite = Expression<Bool>("isFavorite")
            let name = Expression<String>("City")
            let table = Table(CityTables.base.rawValue)
            
            let result = table.filter(name.like("\(chars)%"))
            
            for city in try db.prepare(result) {
                resultArray.append(city[name])
            }
            
        } catch {
            
        }
        return resultArray
    }
    
    public func addToFavorite(city: CellDataForViewModel) {
        
        do {
            let id = Expression<Int>("id")
            
            let name = Expression<String>("City")
            let degrees = Expression<String>("degrees")
            let icon = Expression<String>("icon")
            let descriptionDegrees = Expression<String>("descriptionDegrees")
            let timeZone = Expression<Int>("timeZone")
            let table = Table(CityTables.favorites.rawValue)
            
            try db.run(table.insert(name <- city.cityName ?? "", degrees <- String(city.degrees ?? 0), icon <- city.icon ?? "", descriptionDegrees <- city.descriptionDegrees ?? "", timeZone <- city.timeZone ?? 0))
        } catch {
            print(error)
        }
    }
    
    public func favoriteCount() -> Int {
        var result = 0
        
        do {
            let name = Expression<String>("City")
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
            
            let name = Expression<String>("City")
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
            let name = Expression<String>("City")
            let degrees = Expression<String>("degrees")
            let icon = Expression<String>("icon")
            let descriptionDegrees = Expression<String>("descriptionDegrees")
            let timeZone = Expression<Int>("timeZone")
            let table = Table(CityTables.favorites.rawValue)
            
            
            for city in try db.prepare(table) {
                let viewModelItem = CellCityViewModel(item: CellDataForViewModel(cityName: city[name], degrees: Int(city[degrees]), icon: city[icon], descriptionDegrees: city[descriptionDegrees], timeZone: city[timeZone]))
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
            let name = Expression<String>("City")
            let degrees = Expression<String>("degrees")
            let icon = Expression<String>("icon")
            let descriptionDegrees = Expression<String>("descriptionDegrees")
            let timeZone = Expression<Int>("timeZone")
            let table = Table(CityTables.favorites.rawValue)
            
            for city in try db.prepare(table) {
               
                self.network.fetchData(requestType: .city(city: city[name])) { [weak self] result in
                    switch result {
                    case .success(let data):
                        let viewModelItem = CellCityViewModel(item: CellDataForViewModel(currentData: data)!)
                        let nameCity = viewModelItem.cityName
                        let formatter = NumberFormatter()
                        formatter.minimumFractionDigits = 0
                        formatter.maximumFractionDigits = 1
                        let degreessCity =  viewModelItem.degrees
                        let iconCity = viewModelItem.icon
                        let descriptionDegreesCity = viewModelItem.description
                        let timeZoneCity = viewModelItem.timezone
                        
                        let filt = table.filter( name.like("\(city[name])%") )
                        try? self?.db.run(filt.update(degrees <- String(degreessCity), name <- nameCity, icon <- iconCity, descriptionDegrees <- descriptionDegreesCity, timeZone <- timeZoneCity ))
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
    
    public func filteringFavorites(degree: String) -> [CellCityViewModel] {
        var result: [CellCityViewModel] = []
        do {
            let table = Table(CityTables.favorites.rawValue)
            let destinationTable = Table(CityTables.filtered.rawValue)
            let name = Expression<String>("City")
            let degrees = Expression<String>("degrees")
            let icon = Expression<String>("icon")
            let descriptionDegrees = Expression<String>("descriptionDegrees")
            let timeZone = Expression<Int>("timeZone")
            
            let filter = table.filter(degrees >= degree)
            
            for i in try db.prepare(filter) {
                let viewModelItem = CellCityViewModel(item: CellDataForViewModel(cityName: i[name], degrees: Int(i[degrees]), icon: i[icon], descriptionDegrees: i[descriptionDegrees], timeZone: i[timeZone]))
                result.append(viewModelItem)
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        return result
    }
    
    public func removeFromFavorite(city: String)  {
        
        do {
            let table = Table(CityTables.favorites.rawValue)
            let id = Expression<Int>("id")
            let name = Expression<String>("City")
            let deletingCity = table.filter(name.like("\(city)%"))
            
            try db.run(deletingCity.delete())
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    init(network: NetworkManager = NetworkManager(), favoriteWorker: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()) {
        self.network = network
        self.favoriteWorker = favoriteWorker
        
        do {
//            let path = NSSearchPathForDirectoriesInDomains(
//                .documentDirectory, .userDomainMask, true
//            ).first!
            
            let path = Bundle.main.bundlePath

            let table = Table(CityTables.base.rawValue)
        } catch {
            
        }
    }
}

