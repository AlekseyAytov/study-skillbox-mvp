//
//  Service.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 4/26/23.
//

import UIKit

class Service {
    
    private var urlString = "https://api.tvmaze.com/search/shows?q="
    
    // сервис загрузки картинки по url
    func loadImageAsync(urlString: String?, completion: @escaping (Data?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let contentOfURL = try? Data(contentsOf: url) else {
                print("Ошибка, не удалось загрузить изображение")
                completion(nil)
                return
            }
            completion(contentOfURL)
        }
    }
    
    // сервис API запроса
    func getSearchResults(searchExpression: String?, completion: @escaping (Data?, Error?) -> Void) {
        guard let searchExpression = searchExpression,
              let url = URL(string: urlString + searchExpression) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
        
        print("Запрос с параметром - \(searchExpression)")
        task.resume()
    }
    
    // сервис декодирования JSON в network model
    func parseDecoder(data: Data) -> Welcome? {
        guard let decode = try? JSONDecoder().decode(Welcome.self, from: data) else {
            print("Ошибка декодирования - \(data)")
            return nil
        }
        return decode
    }
}
