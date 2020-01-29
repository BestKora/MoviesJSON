//
//  ContentViewSearch.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 10/01/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ContentViewSearch: View {
  @ObservedObject var moviesModel = MoviesSearchViewModel ()
   var body: some View {
      NavigationView {
          VStack {
             SearchView(searchTerm: $moviesModel.name)
            
             MoviesList(movies: moviesModel.movies)
          } // VStack
         .navigationBarTitle("Movies")
    } // Navigation
      } // body
  }

struct ContentViewSearch_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewSearch()
    }
}
