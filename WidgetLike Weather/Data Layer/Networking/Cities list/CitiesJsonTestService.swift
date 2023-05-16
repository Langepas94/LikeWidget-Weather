//
//  CityJSONService.swift
//  WidgetLike Weather
//
//  Created by Артём Балашов on 10.03.2023.
//

import Foundation
import Combine

enum CityJSONError: Error {
    case error(String)
    
    var localizedDescription: String {
        switch self {
        case .error(let str):
            return str
        }
    }
}

class CitiesJsonTestService {
    
    var cities: [City] = []
    public var favorites: [String] = []
    public var favoritesAppender = PassthroughSubject<String, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    private var favoritesUrl: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("favorites")
            .appendingPathExtension("json")
    }
    
    static let shared = CitiesJsonTestService()
    private init() {
        loadFavorites()
            .sink { _ in
                
            } receiveValue: { names in
                self.favoritesAppender.send("")
            }
            
            .store(in: &cancellables)
    }
    
    
    let citiesQueue = DispatchQueue(label: "ru.widgetLike.citiesQueue", qos: .userInitiated)
    
    public func loadCities() -> Future<[String], Error> {
        Future { promise in
            self.citiesQueue.async {
                do {
                    guard let url = Bundle.main.url(forResource: "citylist", withExtension: "json") else {
                        throw CityJSONError.error("File not found")
                    }

                    let data = try Data(contentsOf: url)
                    let arr = try JSONDecoder().decode([City].self, from: data)
                    self.cities = arr

                    let names = arr.map({ $0.name }).compactMap({ $0 })
                    promise(.success(names))
                } catch {
                    promise(.failure(error))
                }
            }
            
            
        }
    }
    
    public func searchCities(query: String) -> Future<[String], Never> {
        Future { promise in
            self.citiesQueue.async {
                let arr: [String] = self.cities.reduce(into: []) { partialResult, next in
                    if let name = next.name,
                       name.contains(query) {
                        partialResult.append((next.country ?? "NO Country") + " | " + name)
                    }
                }
                promise(.success(arr))
            }
        }
    }
    
 
    
    public func loadFavorites() -> Future<[String], Error> {
        Future { promise in
            DispatchQueue.global().async {
                guard FileManager.default.fileExists(atPath: self.favoritesUrl.path()) else {
                    promise(.success([]))
                    
                    return
                }
                do {
                    
                    let data = try Data(contentsOf: self.favoritesUrl)
                    let arr = try JSONDecoder().decode([String].self, from: data)
                    self.favorites = arr
                    promise(.success(arr))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func saveFavorite(_ name: String) -> Future<Void, Error> {
        Future { promise in
            DispatchQueue.global().async {
                do {
                    self.favorites.append(name)
                    let data = try JSONEncoder().encode(self.favorites)
                    try data.write(to: self.favoritesUrl, options: .atomic)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    public func deleteFavorite(_ index: IndexPath?) -> Future<Void, Error> {
        Future { promise in
            DispatchQueue.global().async {
                do {
                    
                    guard let index = index else { return }
                    self.favorites.remove(at: index.row - 1)
                    let data = try JSONEncoder().encode(self.favorites)
                    try data.write(to: self.favoritesUrl, options: .atomic)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
}
