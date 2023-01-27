//
//  PhotosViewController.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import UIKit

class PhotosViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        let fullSize = (view.frame.width - 3 * 10)/2
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: fullSize, height: fullSize)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return flowLayout
    }()
    
    private let continueButton = CustomNextButton()
    
    private var selectedImagesUrlsArray: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APICaller.shared.search(isFirstStart: true, collectionToReload: collectionView)
        setupUI()
    }
    
}

private extension PhotosViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        setupNavigationBar()
        setupCollectionView()
        setupContinueButton()
    }
    
    func setShadowColor(_ color: UIColor) {
    }
    
    func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationItem.title = "Find photos"
        navigationItem.searchController = createSearchConroller()
        navigationBar.layer.cornerRadius = 10
        navigationBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        navigationBar.backgroundColor = .white
        navigationBar.layer.masksToBounds = false
        navigationBar.isTranslucent = true
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOpacity = 0.3
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigationBar.layer.shadowRadius = 6
        
    }
    
    func createSearchConroller() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = .black.withAlphaComponent(0.04)
        searchBar.searchTextField.textAlignment = .left
        searchBar.showsCancelButton = false
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.setPositionAdjustment(UIOffset(horizontal: 138, vertical: 0),
                                        for: .search)
        searchBar.setImage(#imageLiteral(resourceName: "searchImg"),
                           for: .search,
                           state: .normal)
        
        self.definesPresentationContext = true
        
        return searchController
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func setupContinueButton() {
        continueButton.configurateSelf(color: .black, action: #selector(continueButtonAction), target: self)
        continueButton.isHidden = true
        
        view.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 10),
            continueButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -10),
            continueButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -40),
            continueButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    @objc
    func continueButtonAction() {
        let chooseEffectVC = ChooseEffectViewController()
        chooseEffectVC.getImagesURLs(urls: selectedImagesUrlsArray)
        navigationController?.pushViewController(chooseEffectVC, animated: true)
    }
}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        APICaller.shared.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        guard let url = URL(string: APICaller.shared.results[indexPath.row].urls.regular) else { return cell }
        cell.configurateCellWithImage(url: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else {
            return
        }
        guard let url = URL(string: APICaller.shared.results[indexPath.row].urls.regular) else { return }
        
        if selectedImagesUrlsArray.contains(where: { $0 == url }) {
            cell.deselectCell()
            selectedImagesUrlsArray.removeAll(where: { $0 == url })
        } else if selectedImagesUrlsArray.count < 2 {
            selectedImagesUrlsArray.append(url)
            cell.selectCell()
        } else {
            selectedImagesUrlsArray.removeFirst()
            selectedImagesUrlsArray.append(url)
            cell.selectCell()
        }
        
        if selectedImagesUrlsArray.count == 2 {
            continueButton.isHidden = false
        } else {
            continueButton.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard selectedImagesUrlsArray.count >= 2 else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else {
            return
        }
        guard let url = URL(string: APICaller.shared.results[indexPath.row].urls.regular) else { return }
        selectedImagesUrlsArray.count < 2 ? continueButton.isHidden = true : nil
        if selectedImagesUrlsArray.contains(where: { $0 == url }) {
            selectedImagesUrlsArray.removeAll(where: { $0 == url })
        }
        cell.deselectCell()
    }
    
}

extension PhotosViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            APICaller.shared.search(isFirstStart: true, collectionToReload: collectionView)
        } else {
            guard let searchText = searchBar.text else { return }
            APICaller.shared.search(searchText: searchText, collectionToReload: collectionView)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        APICaller.shared.search(searchText: searchText, collectionToReload: collectionView)
    }
    
}
