//
//  DetailView.swift
//  MoviesJSON
//
//  Created by Tatiana Kornilova on 04/12/2019.
//  Copyright © 2019 Tatiana Kornilova. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    var movie: Movie
    var body: some View {
        VStack{
            MoviePosterImage(imageLoader: ImageLoaderCache.shared.loaderFor(
                movie: movie),posterSize: .big)
            Text(formatter.string(from: movie.releaseDate))
            .font(.subheadline)
            .foregroundColor(Color.blue)
            Text("\( movie.overview)")
            .lineLimit(6)
            CastsList(castsViewModel: CastViewModel(movieId: movie.id))
        } //VStack
            .padding(20)
            .navigationBarTitle(Text(movie.title), displayMode: .inline)
    }
}

let calendar = Calendar.current
let components = DateComponents(calendar: calendar, year: 1984, month: 1, day: 23)

let sampleMovie = Movie(id: 311, title: "Once Upon a Time in America",
                        overview: "A former Prohibition-era Jewish gangster returns to the Lower East Side of Manhattan over thirty years later, where he once again must confront the ghosts and regrets of his old life", posterPath:
    "/x733R4ISI0RbKeHhVkXdTMFmTFr.jpg", releaseDate: calendar.date(from: components)!)


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(movie: sampleMovie)
    }
}


