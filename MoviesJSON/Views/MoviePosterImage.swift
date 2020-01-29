//
//  MoviePosterImage.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 13/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import SwiftUI

struct MoviePosterImage: View {
    @ObservedObject var imageLoader: ImageLoader
    @State private var animate = false
    let posterSize: PosterStyle.Size
    
    var body: some View {
        ZStack {
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
                    .renderingMode(.original)
                    .posterStyle(size: posterSize)
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .posterStyle( size: posterSize)
                    .overlay(
                        Text(imageLoader.url != nil ? "Loading..." : "")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .rotationEffect(Angle(degrees: animate ? 60 : -60))
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                                    self.animate = true
                                }
                        }
                    )
            }
        }
    }
}

struct MoviePosterImage_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterImage(imageLoader: ImageLoader (url: URL(string: "https://image.tmdb.org/t/p/w500//pThyQovXQrw2m0s9x82twj48Jq4.jpg")), posterSize: PosterStyle.Size.big)
      
    }
}

