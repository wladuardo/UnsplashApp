//
//  UIImageViewExtention.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import Foundation
import UIKit

class CustomImageView: UIImageView {
    
    static var cache = NSCache<AnyObject, UIImage>()
    private var url: URL?
    
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        self.url = url
        
        if let cachedImage = CustomImageView.cache.object(forKey: url as AnyObject) {
            self.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() { [weak self] in
                    self?.image = image
                    guard let unwImage = self?.image else { return }
                    CustomImageView.cache.setObject(unwImage, forKey: url as AnyObject)
                }
            }.resume()
        }
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
