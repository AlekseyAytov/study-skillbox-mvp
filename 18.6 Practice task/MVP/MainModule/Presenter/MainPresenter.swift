//
//  Presenter.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/12/23.
//

import UIKit

protocol MainPresenterProtocol {
    init(view: MainViewProtocol, networkService: NetworkServiceProtocol)
    func getSearchResults() -> [ResultForDisplay]
    func doSearchResult(searchExpression string: String?)
    func getImage(for indexPath: IndexPath) -> UIImage?
}

final class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    let networkService: NetworkServiceProtocol

    required init(view: MainViewProtocol, networkService: NetworkServiceProtocol) {
        self.view = view
        self.networkService = networkService
    }

    // результаты поиска
    private var searchResults: [ResultForDisplay] = []

    // словарь для хранения изображений с измененными размерами
    private var imagesCache: [IndexPath: UIImage] = [:]

    func getSearchResults() -> [ResultForDisplay] {
        return searchResults
    }

    func doSearchResult(searchExpression string: String?) {

        // Обнуляем результаты предыдущего запроса
        searchResults = []
        imagesCache = [:]

        networkService.getSearchResults(searchExpression: string) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    // преобразование networkModel в массив структур ResultForDisplay
                    self.searchResults = Array(data.map { ResultForDisplay(networkModel: $0) })
                    self.view?.seccess()
                case .failure(let error):
                    print(error.localizedDescription)
                    self.view?.failure()
                }
            }
        }
    }

    func getImage(for indexPath: IndexPath) -> UIImage? {
        if let image = imagesCache[indexPath] {
            return image
        } else {
            // если изображения для текущего indexPath в словаре imagesCache нет, то загружаем изображение
            print("run service.loadImageAsync - \(indexPath)")
            networkService.loadImageAsync(urlString: searchResults[indexPath.row].image) { imageData in
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        // если загрузка изображения произошла, то заносим в словарь
                        let image = UIImage(data: imageData)
                        self.imagesCache[indexPath] = image!.scalePreservingAspectRatio(
                            targetSize: CGSize(width: 100, height: 100))
                    } else {
                        // если загрузка изображения НЕ произошла, то заносим в словарь No-Image-Placeholder
                        self.imagesCache[indexPath] = UIImage(named: "No-Image-Placeholder")
                    }

                    print("ended service.loadImageAsync - \(indexPath)")
                    self.view?.imageLoadingSecces(for: indexPath)
                }
            }
        }
        return nil
    }
}
