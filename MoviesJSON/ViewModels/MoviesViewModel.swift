//
//  MoviesViewModel.swift
//  CombineFetchAPI
//
//  Created by Tatiana Kornilova on 28/10/2019.
//

import Combine

final class MoviesViewModel: ObservableObject {
    // input
    @Published var indexEndpoint: Int = 2
    // output
    @Published var movies = [Movie]()
    
    init() {
          $indexEndpoint
           .flatMap { (indexEndpoint) -> AnyPublisher<[Movie], Never> in
                MovieAPI.shared.fetchMovies(from:
                                    Endpoint( index: indexEndpoint)!)
           }
         .assign(to: \.movies, on: self)
         .store(in: &self.cancellableSet)
   }
    
    private var cancellableSet: Set<AnyCancellable> = []
/*    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
 */
}

   

