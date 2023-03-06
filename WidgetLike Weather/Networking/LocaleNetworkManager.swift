//
//  LocaleNetworkManager.swift
//  WidgetLike Weather
//
//  Created by Artem on 06.03.2023.
//

import Foundation


class LocaleNetworkManager {

    let urlString = Bundle.main.path(forResource: "citylist", ofType: "json")
    
    func fetchData(completion: @escaping(Result<[WelcomeElement], Error>) -> Void) {
        
         print(urlString)
        let url = URL(filePath: urlString!)
        
       
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                            completion(.failure(error))
                            return
                        }
            guard let data = data else {
                           completion(.failure(ResultError.missingData))
                           return
                       }
            do {
                let result = try JSONDecoder().decode([WelcomeElement].self, from: data)
                            completion(.success(result))
                
                        } catch {
                            completion(.failure(error))
                        }
        }.resume()
    }
    
}
