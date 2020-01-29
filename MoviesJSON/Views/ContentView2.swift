//
//  ContentView1.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 11/12/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ContentView2: View {
    @ObservedObject var moviesViewModel = MoviesViewModel ()
    
    var body: some View {
        VStack {
            Picker("", selection: $moviesViewModel.indexEndpoint){
                Text("nowPlaying").tag(0)
                Text("popular").tag(1)
                Text("upcoming").tag(2)
                Text("topRated").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            List {
                ForEach(moviesViewModel.movies) { movie in
                    HStack{
                        MoviePosterImage(imageLoader: ImageLoaderCache.shared.loaderFor(
                            movie: movie),posterSize: .medium)
                        VStack {
                            Text("\(movie.title)").font(.title)
                            Text("\( movie.overview)")
                                .lineLimit(6)
                        } //Vstack
                    } //HStack
                } // ForEach
            } // List
        } // VStack
    } // body
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}

