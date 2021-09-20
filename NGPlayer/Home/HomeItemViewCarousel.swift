//
//  HomeItemViewCarousel.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 20.09.2021.
//

import SwiftUI

struct HomeItemViewCarousel: View {
	let title: String
	let items: [AudioCategory]
	
	var body: some View {
		Group {
			HStack {
				Text(title)
					.font(.title3)
					.foregroundColor(.secondaryFont)
				Spacer()
			}
			.padding()
			
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(items, id:\.self) { item in
						NavigationLink(destination: CategoryPlaylistView(category: item)) {
							HomeItemView(item: item)
						}
					}
				}
				.padding(.horizontal)
			}
		}
	}
}

struct HomeItemViewCarousel_Previews: PreviewProvider {
	static var previews: some View {
		HomeItemViewCarousel(title: "quick picks", items: [
			AudioCategory.featured,
			AudioCategory.latest,
			AudioCategory.popular
		])
		.environmentObject(HomeViewModel())
	}
}
