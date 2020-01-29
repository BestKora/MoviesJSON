import Foundation

struct MoviesResponse: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [Movie]
}

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate : Date
}

//------------

struct MovieCreditResponse: Codable {
    let cast: [MovieCast]
    let crew: [MovieCrew]
}

struct MovieCast: Identifiable, Codable {
    let id: Int
    let character: String
    let name: String
    let profilePath: String?
}

struct MovieCrew: Identifiable,Codable {
    let id: Int
    let department: String
    let job: String
    let name: String
}

