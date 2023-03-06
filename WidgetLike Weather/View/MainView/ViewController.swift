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
    private let searchController = UISearchController(searchResultsController: ResultVc())
    
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
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Widget Weather"
        
        searchController.searchBar.placeholder = "add your city"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
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
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
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
        
        // MARK: - neuromorph design
        let lightShadow = CALayer()
        lightShadow.frame = cell.bounds
        lightShadow.backgroundColor = UIColor.white.cgColor
        lightShadow.shadowColor = UIColor.white.withAlphaComponent(0.4).cgColor
        lightShadow.shadowRadius = 5
        lightShadow.cornerRadius = 20
        lightShadow.shadowOffset = CGSize(width: -5, height: -5)
        lightShadow.shadowOpacity = 1
        
        
        let darkShadow = CALayer()
        darkShadow.frame = cell.bounds
        darkShadow.backgroundColor = UIColor.white.cgColor
        darkShadow.shadowRadius = 5
        darkShadow.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        darkShadow.cornerRadius = 20
        darkShadow.shadowOffset = CGSize(width: 10, height: 10)
        darkShadow.shadowOpacity = 1
        
        cell.layer.insertSublayer(darkShadow, at: 0)
        cell.layer.insertSublayer(lightShadow, at: 0)
        
        DispatchQueue.main.async {
            
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

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

        
        let vc = searchController.searchResultsController as? ResultVc
        

        vc?.tableView.isHidden = true
        guard let text = searchController.searchBar.text else { return }
        

        
        
       
    }
}
