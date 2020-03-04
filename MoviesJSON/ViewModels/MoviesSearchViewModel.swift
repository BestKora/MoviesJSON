//
//  MoviesSearchViewModel.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 10/01/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Combine
import Foundation

final class MoviesSearchViewModel: ObservableObject {
    // input
    @Published var name: String = ""
    // output
    @Published var movies = [Movie]()
    
    init() {
        $name
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { name -> AnyPublisher<[Movie], Never> in
                Future<[Movie], Never> { (promise) in
                    if 2...30 ~= name.count {
                     MovieAPI.shared.fetchMovies(from:.search(searchString: name))
                        .sink( receiveValue: {value in promise(.success(value))})
                        .store(in: &self.cancellableSet)
                    } else {
                        promise(.success([Movie]()))
                    }
                }
                .eraseToAnyPublisher()
        }
        .assign(to: \.movies, on: self)
        .store(in: &self.cancellableSet)
        
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
}

