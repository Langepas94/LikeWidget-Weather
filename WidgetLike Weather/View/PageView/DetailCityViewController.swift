//
//  PageViewController.swift
//  WidgetLike Weather
//
//  Created by Artem on 07.04.2023.
//

import UIKit

class DetailCityViewController: UIViewController {

    private let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.translatesAutoresizingMaskIntoConstraints = false
        page.pageIndicatorTintColor = .gray
        page.currentPageIndicatorTintColor = .black
        page.hidesForSinglePage = true
        return page
    }()
    
    var mainView: [DetailCitySomeView] = []
    
    var cityItemModel: [CellCityViewModel]? {
        didSet {
            configure()
        }
    }
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .white
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = true
        return scroll
    }()
    
    var currentPageNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: #selector(segmentScroll), for: .valueChanged)
        
        addPages(count: DatabaseService.shared.favoriteCount())
        
        setupUI()

        scrollView.delegate = self
        
        pageControl.numberOfPages = mainView.count
        
        pageControl.currentPage = currentPageNumber
        configure()
        var frame = mainView[currentPageNumber].frame
      
        scrollView.setContentOffset(CGPoint(x: frame.origin.x, y: 0), animated: true)
    }
    @objc func segmentScroll() {
        let indexOfTouch = pageControl.currentPage
        
        
        var frame = mainView[indexOfTouch].frame
      
        scrollView.setContentOffset(CGPoint(x: frame.origin.x, y: 0), animated: true)
        
    }
    func addPages(count: Int) {
        for _ in 1...count {
            mainView.append(DetailCitySomeView())
        }
    }
    
    func configure() {
        
        var result = cityItemModel?.enumerated()
        for (index, city) in mainView.enumerated() {
            city.configure(item: cityItemModel![index])
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in mainView {
            view.frame.size.height = scrollView.bounds.height
        }
    }

}

extension DetailCityViewController {
    func setupUI() {
        
        view.backgroundColor = .white
        view.addSubview(pageControl)
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(mainView.count), height: view.frame.height - 200 )
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaInsets.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height - 200)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView.snp.centerX)
            make.top.equalTo(scrollView.snp.bottom).offset(30)
        }
        
        var padding: CGFloat = 0
        for view in mainView {
            view.frame = CGRect(x: 0 + padding, y: 0, width: CGFloat(UIScreen.main.bounds.width), height: 0)
            scrollView.addSubview(view)
            padding += UIScreen.main.bounds.width
        }
        
    }
}

extension DetailCityViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
    }
}
