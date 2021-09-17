//
//  HomeView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import SwiftUI

struct CardView: View {
	
	let title: String
	@State private var image: UIImage?
	@EnvironmentObject private var imageProvider: ImageProvider
	
	var body: some View {
		ZStack(alignment:.bottom) {
			Spacer()
				.frame(width: 180, height: 180)
			
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFill()
			}
				
			Text(title)
				.font(.title2)
				.foregroundColor(.primaryFont)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 6)
				.background(Color.black.opacity(0.35))
		}
		.frame(width: 180, height: 180)
		.background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2378290296, green: 0.2470975518, blue: 0.264349848, alpha: 1)), Color(#colorLiteral(red: 0.2731795907, green: 0.2823192477, blue: 0.3039281964, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}
}

struct HomeView: View {
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
						NavigationLink(destination: PlaylistView(title: "Featured", viewmodel: PlaylistViewModel())) {
							CardView(title: "Featured")
						}
						
						NavigationLink(destination: PlaylistView(title: "Latest", viewmodel: PlaylistViewModel())) {
							CardView(title: "Latest")
						}
						
						NavigationLink(destination: PlaylistView(title: "Popular", viewmodel: PlaylistViewModel())) {
							CardView(title: "Popular")
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
						NavigationLink(destination: PlaylistView(title: "Techno", viewmodel: PlaylistViewModel())) {
							CardView(title: "Techno")
						}
						
						NavigationLink(destination: PlaylistView(title: "Punk", viewmodel: PlaylistViewModel())) {
							CardView(title: "Punk")
						}
						
						NavigationLink(destination: PlaylistView(title: "Jazz", viewmodel: PlaylistViewModel())) {
							CardView(title: "Jazz")
						}
					}
					.padding(.horizontal)
				}
			}
		}
		.background(Color.background.ignoresSafeArea())
		.navigationTitle("NGPlayer")
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
