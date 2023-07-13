//
//  Model.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 4/26/23.
//

import Foundation

// MARK: - Network Model

struct WelcomeElement: Codable {
    let score: Double
    let show: Show
}

struct Show: Codable {
    let id: Int
    let url: String
    let name: String
    let type: String
    let language: String?
    let genres: [String]
    let status: String
    let runtime, averageRuntime: Int?
    let premiered, ended: String?
    let officialSite: String?
    let schedule: Schedule
    let rating: Rating
    let weight: Int
    let network, webChannel: Network?
    let dvdCountry: String?
    let externals: Externals
    let image: Image?
    let summary: String?
    let updated: Int
    let links: Links

    enum CodingKeys: String, CodingKey {
        case id, url, name, type, language, genres, status, runtime, averageRuntime, premiered, ended, officialSite, schedule, rating, weight, network, webChannel, dvdCountry, externals, image, summary, updated
        case links = "_links"
    }
}

struct Externals: Codable {
    let tvrage, thetvdb: Int?
    let imdb: String?
}

struct Image: Codable {
    let medium, original: String
}

struct Links: Codable {
    let linksSelf: Link
    let previousepisode, nextepisode: Link?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case previousepisode, nextepisode
    }
}

struct Link: Codable {
    let href: String
}

struct Network: Codable {
    let id: Int
    let name: String
    let country: Country?
    let officialSite: String?
}

struct Country: Codable {
    let name, code, timezone: String
}

struct Rating: Codable {
    let average: Double?
}

struct Schedule: Codable {
    let time: String
    let days: [String]
}

typealias Welcome = [WelcomeElement]

// MARK: - Local Model

struct ResultForDisplay {
    var title: String
    var description: String?
    var image: String?
    var genres: [String]
    var start: String?
    
    init(networkModel: WelcomeElement) {
        self.title = networkModel.show.name
        self.description = networkModel.show.summary
        self.image = networkModel.show.image?.original
        self.genres = networkModel.show.genres
        self.start = networkModel.show.premiered
    }
}
