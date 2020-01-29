//
//  MovieRepository.swift
//  MovieKit
//
//  Created by Alfian Losari on 11/24/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import Foundation
import Combine
import UIKit

enum Endpoint {
    
       case topRated, upcoming, nowPlaying, popular
       case search (searchString: String)
       case credits (movieId: Int)
    
       var baseURL:URL {URL(string: "https://api.themoviedb.org/3")!}
       
       func path() -> String {
           switch self {
           case .popular:
               return "movie/popular"
           case .topRated:
               return "movie/top_rated"
           case .upcoming:
               return "movie/upcoming"
           case .nowPlaying:
               return "movie/now_playing"
           case .search (_):
               return "/search/movie"
           case let .credits (movieId):
               return "movie/\(String(movieId))/credits"
           }
       }
    
    var absoluteURL: URL? {
        let queryURL = baseURL.appendingPathComponent(self.path())
        let components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)
        guard var urlComponents = components else {
            return nil
        }
        switch self {
        case .search (let name):
            urlComponents.queryItems = [URLQueryItem(name: "query", value: name),
                                        URLQueryItem(name: "api_key", value: APIConstants.apiKey),
                                        URLQueryItem(name: "language", value: "en"),
                                        URLQueryItem(name: "region", value: "US"),
                                        URLQueryItem(name: "page", value: "1")
                                    ]
        default:
             urlComponents.queryItems = [URLQueryItem(name: "api_key", value: APIConstants.apiKey),
                                         URLQueryItem(name: "language", value: "en"),
                                         URLQueryItem(name: "region", value: "US"),
                                         URLQueryItem(name: "page", value: "1")
                                     ]
        }
        return urlComponents.url
    }
   
    init? (index: Int) {
           switch index {
           case 0: self = .nowPlaying
           case 1: self = .popular
           case 2: self = .upcoming
           case 3: self = .topRated
           default: return nil
           }
       }
   }

struct APIConstants {
    /// TMDB API key url: https://themoviedb.org
    static let apiKey: String = "1d9b898a212ea52e283351e521e17871"
    
    static let jsonDecoder: JSONDecoder = {
           let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
           let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy-mm-dd"
               jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            return jsonDecoder
          }()
}

class MovieAPI {
    public static let shared = MovieAPI()
 /*
     // Асинхронная выборка на основе URL
    func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
                  URLSession.shared.dataTaskPublisher(for: url)             // 1
                   .map { $0.data}                                          // 2
                   .decode(type: T.self, decoder: APIConstants.jsonDecoder) // 3
                   .receive(on: RunLoop.main)                               // 4
                   .eraseToAnyPublisher()                                   // 5
       }
  */
    
    // Асинхронная выборка на основе URL с сообщениями от сервера
    func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
               URLSession.shared.dataTaskPublisher(for: url)             // 1
               .tryMap { (data, response) -> Data in                     // 2
                   guard let httpResponse = response as? HTTPURLResponse,
                        200...299 ~= httpResponse.statusCode else {
                   throw MovieError.responseError(
                        ((response as? HTTPURLResponse)?.statusCode ?? 500,
                            String(data: data, encoding: .utf8) ?? ""))
                        }
                   return data
               }
                .decode(type: T.self, decoder: APIConstants.jsonDecoder)  // 3
                .receive(on: RunLoop.main)                                // 4
                .eraseToAnyPublisher()                                    // 5
    }

    // Выборка данных Модели <T> из файла в Bundle
       func fetch<T: Decodable>(_ nameJSON: String) -> AnyPublisher<T, Error> {
                 Just (nameJSON)                                            // 1
                 .flatMap { (nameJSON) -> AnyPublisher<Data, Never> in      // 2
                     let path = Bundle.main.path(forResource:nameJSON,
                                                          ofType: "json")!
                     let data = FileManager.default.contents(atPath: path)!
                     return Just(data)
                     .eraseToAnyPublisher()
                   }
                   .decode(type: T.self, decoder: APIConstants.jsonDecoder)  // 3
                   .receive(on: RunLoop.main)                                // 4
                   .eraseToAnyPublisher()                                    // 5
       }
    
    // Выборка коллекции фильмов
    func fetchMovies(from endpoint: Endpoint)
                                    -> AnyPublisher<[Movie], Never> {
        guard let url = endpoint.absoluteURL else {
                    return Just([Movie]()).eraseToAnyPublisher() // 0
        }
        return fetch(url)                                        // 1
            .map { (response: MoviesResponse) -> [Movie] in      // 2
                            response.results }
               .replaceError(with: [Movie]())                    // 3
               .eraseToAnyPublisher()                            // 4
    }

   // Выборка актёрского состава
     func fetchCredits(for movieId: Int)
                                -> AnyPublisher<[MovieCast], Never> {
        guard let url =
                Endpoint.credits(movieId: movieId).absoluteURL else {
            return Just([MovieCast]()).eraseToAnyPublisher()      // 0
        }
        return
          fetch(url)                                              // 1
           .map { (response: MovieCreditResponse) -> [MovieCast] in // 2
                 response.cast}
           .replaceError(with: [MovieCast]())                     // 3
           .eraseToAnyPublisher()                                 // 4
    }
 
    // Выборка коллекции фильмов с сообщением об ошибке
    func fetchMoviesErr(from endpoint: Endpoint) ->
                                        AnyPublisher<[Movie], MovieError>{
        Future<[Movie], MovieError> { [unowned self] promise in
            guard let url = endpoint.absoluteURL  else {                     // 0
                return promise(
                    .failure(.urlError(URLError(.unsupportedURL))))
            }
            self.fetch(url)                                                  // 1
              .tryMap { (result: MoviesResponse) -> [Movie] in               // 2
                      result.results }
               .sink(
                receiveCompletion: { (completion) in                         // 3
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as MovieError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.genericError))
                        }
                    }
                },
                receiveValue: { promise(.success($0)) })                     // 4
             .store(in: &self.subscriptions)                                 // 5
        }
        .eraseToAnyPublisher()                                               // 6
    }
 
    private var subscriptions = Set<AnyCancellable>()
    deinit {
           for cancell in subscriptions {
               cancell.cancel()
           }
       }
  /*
     // Выборка коллекции фильмов
        func fetchMovies(from endpoint: Endpoint) -> AnyPublisher<[Movie], Never> {
              guard let url = endpoint.absoluteURL else {
                 return Just([Movie]()).eraseToAnyPublisher()
              }
            return
                URLSession.shared.dataTaskPublisher(for:url)                    // 1
                .map{$0.data}                                                   // 2
                .decode(type: MoviesResponse.self,                              // 3
                                            decoder: APIConstants.jsonDecoder)
                .map{$0.results}                                                // 4
                .replaceError(with: [])                                         // 5
                .receive(on: RunLoop.main)                                      // 6
                .eraseToAnyPublisher()                                          // 7
        }
    */
    /*
      // Выборка актёрского состава
       func fetchCredits(for movieId: Int) -> AnyPublisher<[MovieCast], Never> {
              guard let url = Endpoint.credits(movieId: movieId).absoluteURL else {
                   return Just([MovieCast]()).eraseToAnyPublisher()
               }
             return
               URLSession.shared.dataTaskPublisher(for:url)                    // 1
               .map{$0.data}                                                   // 2
               .decode(type: MovieCreditResponse.self,                         // 3
                                             decoder: APIConstants.jsonDecoder)
               .map{$0.cast}                                                   // 4
               .replaceError(with: [])                                         // 5
               .receive(on: RunLoop.main)                                      // 6
               .eraseToAnyPublisher()                                          // 7
       }
    */
    /*
       func fetchMoviesErr(from endpoint: Endpoint) ->
                                           AnyPublisher<[Movie], MovieError>{
           return Future<[Movie], MovieError> { [unowned self] promise in
               guard let url = endpoint.absoluteURL  else {
                   return promise(.failure(.urlError(                          // 0
                                                URLError(.unsupportedURL))))
               }
               
                URLSession.shared.dataTaskPublisher(for: url)                  // 1
                   .tryMap { (data, response) -> Data in                       // 2
                       guard let httpResponse = response as? HTTPURLResponse,
                            200...299 ~= httpResponse.statusCode else {
                       throw MovieError.responseError(
                            ((response as? HTTPURLResponse)?.statusCode ?? 500,
                                String(data: data, encoding: .utf8) ?? ""))
                            }
                       return data
                   }
                .decode(type: MoviesResponse.self,
                                              decoder: APIConstants.jsonDecoder) // 3
                .receive(on: RunLoop.main)                                       // 4
                  .sink(
                   receiveCompletion: { (completion) in                          // 5
                       if case let .failure(error) = completion {
                           switch error {
                           case let urlError as URLError:
                               promise(.failure(.urlError(urlError)))
                           case let decodingError as DecodingError:
                               promise(.failure(.decodingError(decodingError)))
                           case let apiError as MovieError:
                               promise(.failure(apiError))
                           default:
                               promise(.failure(.genericError))
                           }
                       }
                  },
                  receiveValue: { promise(.success($0.results)) })             // 6
                .store(in: &self.subscriptions)                                // 7
           }
           .eraseToAnyPublisher()                                              // 8
       }
 */
}

