//
//  DetailViewController.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/13/23.
//

import UIKit

protocol DetailViewProtocol: AnyObject {
    func seccess()
}

class DetailViewController: UIViewController {

    var presenter: DetailPresenterProtocol!

    private lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = presenter.getImage()
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = presenter.getResult().title
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = presenter.getResult().description?.trimHTMLTags()
        label.numberOfLines = 0
        label.textAlignment = .justified
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(image)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
    }

    private func setupConstraints() {
        image.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(400)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(image.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
}

// MARK: - DetailViewProtocol

extension DetailViewController: DetailViewProtocol {
    func seccess() {
        self.image.image = presenter.getImage()
        self.image.setNeedsDisplay()
    }
}
