//
//  HomeView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import SwiftUI

struct HomeView: View {

	@StateObject
	private var viewModel = HomeViewModel()
	
	var body: some View {
		ScrollView {
			VStack {
				HomeItemViewCarousel(
					title: "quick picks",
					items: [
						AudioCategory.featured,
						AudioCategory.latest,
						AudioCategory.popular
					]
				)
				
				HomeItemViewCarousel(
					title: "genres",
					items: [
						AudioCategory.genre(genre: .jazz),
						AudioCategory.genre(genre: .punk),
						AudioCategory.genre(genre: .techno)
					]
				)
			}
		}
		.background(Color.background.ignoresSafeArea())
		.navigationTitle("NGPlayer")
		.onAppear {
			viewModel.load()
		}
		.environmentObject(viewModel)
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
			.environmentObject(HomeViewModel())
	}
}
