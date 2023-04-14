//
//  FilterSharing.swift
//  WidgetLike Weather
//
//  Created by Artem on 16.03.2023.
//

import Foundation

class FilterDegreesService {
    
    private var filteredNum: String = "0"  {
        willSet {
            self.filteredNum = newValue
        }
    }
    
    static let shared = FilterDegreesService()
    
    private init () {}
    
    public func pasteToFilteredNum(num: String) {
        var result = Int(num)!
        result = min(100, max(-100, result))
        self.filteredNum = String(result)
    }
    
    public func getFromFilteredNum() -> String {
        return self.filteredNum
    }
    
    public func increaseOne() -> String {
        var result = Int(filteredNum)! + Int(1)
        result = min(result, 100)
        let string = String(result)
        self.filteredNum = string
        print("increaseOne \(result)")
        return self.filteredNum
    }
    
    public func decreaseOne() -> String {
        var result = Int(filteredNum)! - Int(1)
        result = max(-100, result)
        let string = String(result)
        self.filteredNum = string
        return self.filteredNum
    }
    
    public func clearFilter() -> String {
        self.filteredNum = "0"
        return self.filteredNum
    }
    
}
