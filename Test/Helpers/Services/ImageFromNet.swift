//
//  ImageFromNet.swift
//  Test
//
//  Created by Владислав Ковальский on 26.01.2023.
//

import Foundation
import UIKit

class ImageFromNet {
    class func getImageFromNet(url: URL, completion: @escaping (UIImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            completion(image)
        }.resume()
    }
}
