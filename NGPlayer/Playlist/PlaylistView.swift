//
//  ContentView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlaylistView: View {
	
	let title: String
	@ObservedObject
	var viewmodel: PlaylistViewModel
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	@Environment(\.presentationMode)
	private var presentationMode
	
	var body: some View {
		
		ZStack(alignment: .top) {
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
								.frame(height: safeAreaInsets.top + 48)
							
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
								Divider()
									.padding(.horizontal)
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
			
			HStack {
				Button(action: {
					presentationMode.wrappedValue.dismiss()
				}) {
					Image(systemName: "chevron.left")
						.foregroundColor(.secondaryButtonForeground)
						.font(.system(size: 24))
						.padding()
				}
				Spacer()
				
				Text(title)
					.font(.system(size: 32, weight: .thin))
					.foregroundColor(.primaryFont)
				
				Spacer()
				
				Image(systemName: "chevron.left")
					.foregroundColor(.secondaryButtonForeground)
					.font(.system(size: 24))
					.padding()
					.opacity(0)
			}
			.frame(height: 48)
			.padding(.leading, safeAreaInsets.leading)
			.padding(.trailing, safeAreaInsets.trailing)
			.padding(.top, safeAreaInsets.top)
			.background(Color.secondaryBackground.opacity(0.75))
		}
		.ignoresSafeArea()
		.background(Color.background.ignoresSafeArea())
		.onAppear {
			viewmodel.load()
		}
		.navigationBarHidden(true)
	}
}

struct PlaylistView_Previews: PreviewProvider {
	static var previews: some View {
		PlaylistView(title: "Featured", viewmodel: PlaylistViewModel())
	}
}
