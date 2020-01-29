//
//  MoviesViewModel.swift
//  CombineFetchAPI
//
//  Created by Tatiana Kornilova on 28/10/2019.
//

import Combine
import Foundation

final class MoviesViewModelF: ObservableObject {
    // input
    @Published var nameJSON: String = "movies"
    // output
    @Published var movies = [Movie]()
  
    // With Generic
    init() {
           $nameJSON
             .flatMap { (name) -> AnyPublisher<[Movie], Never> in
                MovieAPI.shared.fetch (name)              // 1
                  .replaceError(with: [Movie]())          // 2
                  .eraseToAnyPublisher()
             }
             .assign(to: \.movies, on: self)              // 3
             .store(in: &self.cancellableSet)             // 4
       }
  
    private var cancellableSet: Set<AnyCancellable> = []
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
    /*
     // Without Generic
        init() {
            $nameJSON
                .flatMap { (nameJSON) -> AnyPublisher<Data, Never> in
                    let path = Bundle.main.path(forResource:nameJSON, ofType: "json")!
                    let data = FileManager.default.contents(atPath: path)!
                        return Just(data)
                    .eraseToAnyPublisher()
            }
            .decode(type: [Movie].self, decoder: APIConstants.jsonDecoder)
            .replaceError(with: [])
            .assign(to: \.movies, on: self)
            .store(in: &self.cancellableSet)
        }
*/
}

 
