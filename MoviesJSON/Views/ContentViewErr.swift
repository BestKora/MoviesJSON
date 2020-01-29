//
//  ContentViewErr.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 21/12/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct ContentViewErr: View {
    @ObservedObject var moviesViewModel = MoviesViewModelErr ()
    
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
            } // VStack
            .alert(item: self.$moviesViewModel.moviesError) { error in
              Alert(
                title: Text("Network error"),
                message: Text(error.localizedDescription).font(.subheadline),
                dismissButton: .default(Text("OK")) /*.cancel()*/
              )
            } // alert
            .navigationBarTitle("Movies")
        } // Navigation
    } // body
}

struct ContentViewErr_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewErr()
    }
}
