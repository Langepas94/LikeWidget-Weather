//
//  NetworkManager.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//

import Foundation
import UIKit
import CoreLocation



enum ResultError: Error {
    case invalidUrl
    case missingData
}

class NetworkManager {
    
    enum RequestType {
        case city(city: String)
        case location(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
        case localeList
    }
    
    func fetchData(requestType: RequestType ,completion: @escaping(Result<WeatherDataModel, Error>) -> Void) {
        
        var urlString = ""
        
        switch requestType {
        case .city(let city):
            urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
        case .location(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&apikey=\(apiKey)&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
        case .localeList:
            guard let path = Bundle.main.path(forResource: "city.list", ofType: "json") else { return }
            
            urlString = "\(path)"
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(ResultError.invalidUrl))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(ResultError.missingData))
                return
            }
            do {
                let result = try JSONDecoder().decode(WeatherDataModel.self, from: data)
                completion(.success(result))
                
            } catch {
                completion(.failure(error))
                print(error)
            }
        }
        task.resume()
    }
}

