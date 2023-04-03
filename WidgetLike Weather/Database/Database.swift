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
}

class Database {
    static let shared = Database()
    
    
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
    
    
    
    public func addToFavorite(city: String) {
        do {
            let id = Expression<Int>("id")
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
    
    //    public func removeFromFavorite(index: Int) -> Future<Void, Error> {
    //        Future { promise in
    //            do {
    //                let path = NSSearchPathForDirectoriesInDomains(
    //                    .documentDirectory, .userDomainMask, true
    //                ).first!
    //
    //                let name = Expression<String>("City")
    //                let db = try Connection("\(path)/cities.db")
    //                let table = Table(CityTables.favorites.rawValue)
    ////                let deletingCity = table.filter(name.index == index)
    ////                let deletingCity = table.filter()
    //                let deleteStatementString = "DELETE FROM Favorites WHERE id = \(index);"
    //
    //                try db.run(deleteStatementString)
    //                promise(.success(()))
    //            } catch {
    //                promise(.failure(error))
    //                print(error)
    //            }
    //
    //        }
    //
    //    }
    
    public func deleteFavorite(_ index: Int?) -> Future<Void, Error> {
        Future { promise in
            DispatchQueue.global().async {
                do {
                    
                    let path = NSSearchPathForDirectoriesInDomains(
                        .documentDirectory, .userDomainMask, true
                    ).first!
                    
                    let name = Expression<String>("City")
                    let db = try Connection("\(path)/cities.db")
                    let table = Table(CityTables.favorites.rawValue)
                    
                    let deletingCity = table.filter(rowid == 2)
                    
                    try db.run(deletingCity.delete())
                    print("mem \(deletingCity)")
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
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
