//
//  MoviesViewModel.swift
//  CombineFetchAPI
//
//  Created by Tatiana Kornilova on 28/10/2019.
//

import Combine

final class MoviesViewModelErr: ObservableObject {
    var movieAPI = MovieAPI.shared
    // input
    @Published var indexEndpoint: Int = 2
    // output
    @Published var movies = [Movie]()
    @Published var moviesError: MovieError?
    
    init() {
        
        $indexEndpoint
        .setFailureType(to: MovieError.self)
        .flatMap { (indexEndpoint) ->
                            AnyPublisher<[Movie], MovieError> in
            self.movieAPI.fetchMoviesErr(from:
                                Endpoint( index: indexEndpoint)!)
        }
        .sink(receiveCompletion:  {[unowned self] (completion) in
            if case let .failure(error) = completion {
                self.moviesError = error
            }},
              receiveValue: { [unowned self] in
                self.movies = $0
        })
            .store(in: &self.cancellableSet)
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
    
}
