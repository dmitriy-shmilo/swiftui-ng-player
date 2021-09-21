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
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	@Environment(\.currentPlayerHeight)
	private var currentPlayerHeight
	
	var body: some View {
		VStack {
			ScrollView {
				VStack {
					Spacer()
						.frame(height: safeAreaInsets.top)

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
					
					Spacer()
						.frame(height: currentPlayerHeight)
				}
				.padding(.leading, safeAreaInsets.leading)
				.padding(.trailing, safeAreaInsets.trailing)
			}
		}
		.ignoresSafeArea()
		.background(Color.background.ignoresSafeArea())
		.navigationBarHidden(true)
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
