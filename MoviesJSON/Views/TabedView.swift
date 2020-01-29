//
//  TabedView.swift
//  NewsApp With SwiftUI Framework
//
//  Created by Алексей Воронов on 15.06.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import SwiftUI

struct TabedView : View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image (systemName: "film.fill")
                    Text("Movies")
            }
            ContentViewSearch()
                .tabItem {
                    Image (systemName: "magnifyingglass")
                     Text("Search")
            }
            ContentViewF()
                .tabItem {
                    Image (systemName: "folder.fill")
                     Text("From File")
            }
             ContentViewErr()
                .tabItem {
                    Image (systemName: "hurricane")
                     Text("Movies with Errors")
            }
        }
        .accentColor(.blue)
    }
}

struct TabvedView_Previews: PreviewProvider {
    static var previews: some View {
        TabedView()
    }
}
