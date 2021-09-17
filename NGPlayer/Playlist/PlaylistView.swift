//
//  ContentView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlaylistView: View {
	@ObservedObject var viewmodel = PlaylistViewModel()
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
			VStack(spacing: 0) {
				ScrollViewReader { proxy in
					ScrollView {
						LazyVStack {
							Spacer()
								.frame(height: safeAreaInsets.top)
							
							ForEach(viewmodel.songs.indices, id: \.self) { i in
								let song = viewmodel.songs[i]
								PlaylistItemView(song: song, isHighlighted: i == viewmodel.currentIndex)
									.padding(.leading, safeAreaInsets.leading)
									.padding(.trailing, safeAreaInsets.trailing)
									.onTapGesture {
										withAnimation {
											self.viewmodel.play(index: i)
										}
									}
									.id(i)
							}
							
						}
						
					}
					.onChange(of: viewmodel.currentIndex, perform: { value in
						withAnimation(.easeInOut(duration: 0.1)) {
							proxy.scrollTo(viewmodel.currentIndex)
						}
					})
				}
				
				PlayerControlsView(
					onPlay: {
						viewmodel.resume()
					},
					onPause: {
						viewmodel.pause()
					},
					onNext: {
						withAnimation {
							viewmodel.playNex()
						}
					},
					onPrevious: {
						withAnimation {
							viewmodel.playPrev()
						}
					},
					isPlaying: $viewmodel.isPlaying)
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
