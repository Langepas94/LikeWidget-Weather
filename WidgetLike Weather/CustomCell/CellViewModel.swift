//
//  CellViewModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 04.04.2023.
//

import Foundation

protocol CellUpdatingProtocol {
    var updateData: ((CellDataModel)->Void)? { get set }
    func startFetch()
}

