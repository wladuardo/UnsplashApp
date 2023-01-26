//
//  APICaller.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import Foundation
import UIKit

class APICaller {
    
    static let shared = APICaller()
    private var token = "kvfu_YYTOHSELVt9qI2lAbHboUKkSyg0oxUlzmHx1Mo"
    var results = [Result]()
    private init() {}
    
    func search(searchText: String? = nil, isFirstStart: Bool = false,
                collectionToReload: UICollectionView? = nil, page: Int = 1) {
        var url: URL?
        if let unwSearchText = searchText {
            url = URL(string: "https://api.unsplash.com/search/photos?query=\(unwSearchText)")
        }
        
        if isFirstStart {
            url = URL(string: "https://api.unsplash.com/photos?page=\(page)")
        }
        guard let unwUrl = url else { return }
        
        var request = URLRequest(url: unwUrl)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [self] (data, response, error) in
            guard let data = data else { return }
            do {
                if isFirstStart {
                    let result = try JSONDecoder().decode([Result].self, from: data)
                    results.removeAll()
                    self.results.append(contentsOf: result)
                    
                    if collectionToReload != nil {
                        DispatchQueue.main.async {
                            collectionToReload?.reloadData()
                        }
                    }
                } else {
                    let result = try JSONDecoder().decode(Results.self, from: data)
                    results.removeAll()
                    self.results.append(contentsOf: result.results)
                    
                    if collectionToReload != nil {
                        DispatchQueue.main.async {
                            collectionToReload?.reloadData()
                        }
                    }
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
}
