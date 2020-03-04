//
//  CastViewModel.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 07/12/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import Combine

final class CastViewModel: ObservableObject {
    // input
    @Published var movieId: Int = 642372
    // output
    @Published var casts = [MovieCast]()
    
    init(movieId: Int ) {
        self.movieId = movieId
        $movieId
            .flatMap { (movieId) -> AnyPublisher<[MovieCast], Never> in
                MovieAPI.shared.fetchCredits(for:movieId)
        }
        .assign(to: \.casts, on: self)
        .store(in: &self.cancellableSet)
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
    
}
