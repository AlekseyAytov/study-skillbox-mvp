//
//  ViewController.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 4/24/23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    private let service = Service()
    
    // результаты поиска
    private var searchResults: [ResultForDisplay] = []
    
    // словарь для хранения изображений с измененными размерами
    private var imagesCache: [IndexPath: UIImage] = [:]
    
    private var reuseCellIdentifier = "standartCell"
    
    private lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        return table
    }()
    
    private lazy var mainSearchBar: UISearchBar  = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = Constants.Titles.placeholder
        return searchBar
    }()
    
    private lazy var aboutInfo: UILabel = {
        let label = UILabel()
        label.text = Constants.Titles.info
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        return view
    }()

    private func setupViews() {
        view.addSubview(mainTableView)
        view.addSubview(mainSearchBar)
        view.addSubview(aboutInfo)
        mainSearchBar.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        aboutInfo.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalTo(mainSearchBar.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        mainSearchBar.snp.makeConstraints { make in
            make.bottom.equalTo(mainTableView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        mainTableView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.trailing.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(mainSearchBar.searchTextField.snp.leading).inset(17)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
}

// MARK: - TableView DataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseCell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier) ?? UITableViewCell()
        configure(cell: &reuseCell, for: indexPath)
        return reuseCell
    }
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        if searchResults.isEmpty {
            return
        } else {
            var configuration = cell.defaultContentConfiguration()
            
            var title = searchResults[indexPath.row].title
            if let startYear = searchResults[indexPath.row].start?.prefix(4) {
                title += " (\(startYear))"
            }
            
            configuration.text = "\(title)"
            
            let ganres = searchResults[indexPath.row].genres.joined(separator: ", ")
            configuration.secondaryText = "\(ganres)"
            
            if let image = imagesCache[indexPath] {
                configuration.image = image
            } else {
                // если изображения для текущего indexPath в словаре imagesCache нет, то загружаем изображение
                print("run service.loadImageAsync - \(indexPath)")
                service.loadImageAsync(urlString: searchResults[indexPath.row].image) {imageData in
                    
                    if let imageData = imageData {
                        // если загрузка изображения произошла, то заносим в словарь
                        self.imagesCache[indexPath] = UIImage(data: imageData)!.scalePreservingAspectRatio(targetSize: CGSize(width: 100, height: 100))
                    } else {
                        // если загрузка изображения НЕ произошла, то заносим в словарь No-Image-Placeholder
                        self.imagesCache[indexPath] = UIImage(named: "No-Image-Placeholder")
                    }
                    
                    DispatchQueue.main.async {
                        // для отображения изображения перезагружаем ячейку
                        self.mainTableView.reloadRows(at: [indexPath], with: .none)
                        print("ended service.loadImageAsync - \(indexPath)")
                    }
                }
            }
            
            // установка максимального размера картинки в ячейке
            var imageProperties = configuration.imageProperties
            imageProperties.maximumSize = CGSize(width: 100, height: 100)
            configuration.imageProperties = imageProperties
            
            cell.contentConfiguration = configuration
        }
    }
}

// MARK: - SearchBar Delegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        activityIndicator.startAnimating()
        // прячем левую вью searchTextField для отображения activityIndicator
        mainSearchBar.searchTextField.leftView?.isHidden = true
        // скрываем клавиатуру после нажатия
        searchBar.resignFirstResponder()
        
        // Обнуляем результаты предыдущего запроса
        searchResults = []
        imagesCache = [:]
        
        service.getSearchResults(searchExpression: searchBar.text) { jsonData, error in
            guard let data = jsonData,
                  let networkModel = self.service.parseDecoder(data: data) else {
                print("Search Results Error")
                return }
            print(networkModel)
            // преобразование networkModel в массив структур ResultForDisplay
            self.searchResults = Array(networkModel.map{ResultForDisplay(networkModel: $0)})
            
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.mainSearchBar.searchTextField.leftView?.isHidden = false
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        searchBar.showsCancelButton = false
        searchBar.text = nil
        activityIndicator.stopAnimating()
        mainSearchBar.searchTextField.leftView?.isHidden = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

// MARK: - UIImage extension

// расширения класса UIImage для изменения размера
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
