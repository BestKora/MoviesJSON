//
//  ContentView.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 02/12/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var moviesViewModel = MoviesViewModel ()
    var body: some View {
        NavigationView {
            VStack {
             Picker("", selection: $moviesViewModel.indexEndpoint){
                    Text("nowPlaying").tag(0)
                    Text("popular").tag(1)
                    Text("upcoming").tag(2)
                    Text("topRated").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                MoviesList(movies: moviesViewModel.movies)
            }
            .navigationBarTitle("Movies")
        } // Navigation
    } // body
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

