//
//  DetailPresenter.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/13/23.
//

import UIKit

protocol DetailPresenterProtocol {
    init(view: DetailViewProtocol, networkService: NetworkServiceProtocol, result: ResultForDisplay)
    func getImage() -> UIImage?
    func getResult() -> ResultForDisplay
}

final class DetailPresenter: DetailPresenterProtocol {
    weak var view: DetailViewProtocol!
    private var result: ResultForDisplay
    var networkService: NetworkServiceProtocol

    private var image: UIImage?

    init(view: DetailViewProtocol, networkService: NetworkServiceProtocol, result: ResultForDisplay) {
        self.view = view
        self.result = result
        self.networkService = networkService
    }

    func getResult() -> ResultForDisplay {
        return result
    }

    // метод возвращает картинку либо асинхронно её загружает и сохраняет в переменную,
    // при повторном использованиии метода возвращает загруженную картинку
    func getImage() -> UIImage? {
        if let image = self.image {
            return image
        } else {
            guard let urlString = self.result.image else {
                self.setPlaceholderImage()
                return self.image
            }
            print(urlString)

            networkService.loadImageAsync(urlString: urlString) { imageData in
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        self.image = UIImage(data: imageData)
                    } else {
                        self.setPlaceholderImage()
                    }
                    self.view?.seccess()
                }
            }
        }
        return self.image
    }

    private func setPlaceholderImage() {
        self.image = UIImage(named: "No-Image-Placeholder")
    }
}
