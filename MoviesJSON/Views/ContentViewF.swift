//
//  ContentViewF.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 27/01/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ContentViewF: View {
    @ObservedObject var moviesViewModel = MoviesViewModelF ()
    
    var body: some View {
          NavigationView {
                  MoviesList(movies: moviesViewModel.movies)
              .navigationBarTitle("Movies")
          } // Navigation
    } //body
}

struct ContentViewF_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewF()
    }
}
