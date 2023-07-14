//
//  Service.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 4/26/23.
//

import Foundation

protocol NetworkServiceProtocol {
    func getSearchResults(searchExpression: String?, completion: @escaping (Result<Welcome, Error>) -> Void)
    func loadImageAsync(urlString: String?, completion: @escaping (Data?) -> Void)
}

class NetworkService: NetworkServiceProtocol {

    private var urlString = "https://api.tvmaze.com/search/shows?q="

    // сервис API запроса
    func getSearchResults(searchExpression: String?, completion: @escaping (Result<Welcome, Error>) -> Void) {

        guard let searchExpression = searchExpression,
              let url = URL(string: urlString + searchExpression) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in

            if let data = data, let decodeResult = self.parseDecoder(data: data) {
                completion(.success(decodeResult))
            } else {
                completion(.failure(error!))
            }
        }

        print("Запрос с параметром - \(searchExpression)")
        task.resume()
    }

    // сервис декодирования JSON в network model
    private func parseDecoder(data: Data) -> Welcome? {
        do {
            let decode = try JSONDecoder().decode(Welcome.self, from: data)
            return decode
        } catch {
            print("Ошибка декодирования - \(error.localizedDescription)")
            return nil
        }
    }

    // сервис загрузки картинки по url
    func loadImageAsync(urlString: String?, completion: @escaping (Data?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            guard let contentOfURL = try? Data(contentsOf: url) else {
                completion(nil)
                return
            }
            completion(contentOfURL)
        }
    }
}
