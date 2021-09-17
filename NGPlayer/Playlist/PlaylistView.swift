//
//  ContentView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlaylistView: View {
	@ObservedObject var viewmodel = PlaylistViewModel()
	@State private var currentItem = 0
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	init(viewmodel: PlaylistViewModel = PlaylistViewModel()) {
		self.viewmodel = viewmodel
	}
	
	var body: some View {
		ZStack(alignment: .bottom) {
			if (viewmodel.isLoading) {
				VStack(alignment: .center) {
					Spacer()
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
					Spacer()
				}
			}
			ScrollView {
				LazyVStack {
					Spacer()
						.frame(height: safeAreaInsets.top)
					
					ForEach(viewmodel.songs.indices, id: \.self) { i in
						let song = viewmodel.songs[i]
						PlaylistItemView(song: song, isHighlighted: i == currentItem)
							.padding(.leading, safeAreaInsets.leading)
							.padding(.trailing, safeAreaInsets.trailing)
							.onTapGesture {
								withAnimation {
									self.currentItem = i
								}
							}
					}

					// TODO: un-magic this number
					Spacer()
						.frame(height: safeAreaInsets.bottom + 128)
				}
				PlayerControlsView(
					onPlay: {},
					onPause: {},
					onNext: {
						withAnimation {
							currentItem = min(currentItem + 1, viewmodel.songs.count)
						}
					},
					onPrevious: {
						withAnimation {
							currentItem = max(currentItem - 1, 0)
						}
					})
			}
		}
		.ignoresSafeArea()
		.background(Color.background.ignoresSafeArea())
		.onAppear {
			viewmodel.load()
		}
	}
}

struct PlaylistView_Previews: PreviewProvider {
	static var previews: some View {
		PlaylistView()
	}
}
