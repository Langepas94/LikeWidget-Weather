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
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "id")
        return collection
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    // MARK: - createCompositionalLayout()
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in

         switch sectionNumber {

         case 0: return self.mainLayoutSection()
         default: return self.mainLayoutSection()
         }
       }
    }
    // MARK: - mainLayoutSection()
    private func mainLayoutSection() -> NSCollectionLayoutSection {

       let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
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
        view.backgroundColor = .backColor
        view.addSubview(mainCollection)
        
        mainCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource()
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollection.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
    
    
}