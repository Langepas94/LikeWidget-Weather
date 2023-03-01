//
//  ViewController.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - elements of view
    private lazy var mainCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collection.dataSource = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.cellId)
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    var testMassiv = ["London", "Langepas", "Moscow", "Ufa", "York", "Volgograd"]
    private var network = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    // MARK: - createCompositionalLayout()
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

       return UICollectionViewCompositionalLayout(section: mainLayoutSection())
    }
    // MARK: - mainLayoutSection()
    private func mainLayoutSection() -> NSCollectionLayoutSection {

       let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.5),
        heightDimension: .fractionalWidth(0.5))

       let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 0, leading: 0, bottom: 15, trailing: 15)

       let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
    heightDimension: .estimated(500))

       let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

       let section = NSCollectionLayoutSection(group: group)
     section.contentInsets.leading = 15

//       section.boundarySupplementaryItems = [
//    NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension:
//    .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment:
//    .topLeading)
//    ]

     return section
    }
    
}
// MARK: - setupUI func
extension ViewController {
    func setupUI() {
        mainCollection.backgroundColor = .backColor
        view.addSubview(mainCollection)
        
        mainCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource()
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        testMassiv.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var index = testMassiv[indexPath.row]
        let cell = mainCollection.dequeueReusableCell(withReuseIdentifier: WeatherCell.cellId, for: indexPath) as! WeatherCell
        
        
        DispatchQueue.main.async {
            
              
//            cell.configure(city: index , degrees: "20")
            
            cell.layer.shadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            cell.layer.shadowOffset = CGSize(width: 100, height: 100)
            cell.layer.shadowOpacity = 1
            
            
                self.network.fetchData(requestType: .city(city: index)) { [weak self] result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            cell.configure(city: (data.city?.name)!, degrees: String( (data.list![0].main?.temp)!))
                        }
                    case .failure(_):
                        print("mem")
                    }
                }
            
        }
        
        return cell
    }
    
    
}
