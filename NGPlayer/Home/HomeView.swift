//
//  HomeView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import SwiftUI

struct HomeView: View {
	let viewModel = HomeViewModel()
	
	var body: some View {
		ScrollView {
			VStack {
				HStack {
					Text("quick picks")
						.font(.title3)
						.foregroundColor(.secondaryFont)
					Spacer()
				}
				.padding()
				
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach([
							AudioCategory.featured,
							AudioCategory.latest,
							AudioCategory.popular
						], id:\.self) { item in
							NavigationLink(destination: CategoryPlaylistView(category: item, viewmodel: PlaylistViewModel())) {
								HomeItemView(item: item, viewModel: viewModel)
							}
						}
					}
					.padding(.horizontal)
				}
				
				HStack {
					Text("genres")
						.font(.title3)
						.foregroundColor(.secondaryFont)
					Spacer()
				}
				.padding()
				.padding(.top)
				
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach([
							AudioCategory.genre(genre: .jazz),
							AudioCategory.genre(genre: .punk),
							AudioCategory.genre(genre: .techno)
						], id:\.self) { item in
							NavigationLink(destination: CategoryPlaylistView(category: item, viewmodel: PlaylistViewModel())) {
								HomeItemView(item: item, viewModel: viewModel)
							}
						}
					}
					.padding(.horizontal)
				}
			}
		}
		.background(Color.background.ignoresSafeArea())
		.navigationTitle("NGPlayer")
		.onAppear {
			viewModel.load()
		}
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
