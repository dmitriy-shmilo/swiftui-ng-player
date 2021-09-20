//
//  ContentView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct CategoryPlaylistView: View {
	
	let category: AudioCategory
	
	@EnvironmentObject
	private var viewmodel: PlaylistViewModel
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	@Environment(\.presentationMode)
	private var presentationMode
	
	var body: some View {
		
		ZStack(alignment: .top) {
			if viewmodel.isFullLoading {
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
											viewmodel.play(index: i)
										}
									}
									.onAppear {
										if i == viewmodel.songs.count - 1 {
											viewmodel.loadMore(category: category)
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
						switch viewmodel.state {
						case .paused:
							viewmodel.resume()
						default:
							viewmodel.playNext()
						}
					},
					onPause: {
						viewmodel.pause()
					},
					onNext: {
						withAnimation {
							viewmodel.playNext()
						}
					},
					onPrevious: {
						withAnimation {
							viewmodel.playPrev()
						}
					},
					isPlaying: .constant(viewmodel.isPlaying))
			}
			
			navBarView
		}
		.ignoresSafeArea()
		.background(Color.background.ignoresSafeArea())
		.onAppear {
			viewmodel.load(category: category)
		}
		.navigationBarHidden(true)
	}
	
	private var navBarView: some View {
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
			
			Text(category.localizedLabel)
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
}

struct CategoryPlaylistView_Previews: PreviewProvider {
	static var previews: some View {
		CategoryPlaylistView(category: .featured)
			.environmentObject(PlaylistViewModel())
	}
}
