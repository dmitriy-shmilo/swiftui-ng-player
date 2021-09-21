//
//  ContentView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct CategoryPlaylistView: View {
	
	let category: AudioCategory
	let imageUrl: URL?
	
	@EnvironmentObject
	private var viewmodel: PlaylistViewModel
	
	@EnvironmentObject
	private var imageProvider: ImageProvider
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	@Environment(\.presentationMode)
	private var presentationMode
	
	@Environment(\.verticalSizeClass)
	private var verticalSizeClass
	
	@State
	private var image: UIImage?
	
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
				songListView
				
				PlayerControlsView(
					onPlay: {
						switch viewmodel.state {
						case .paused:
							let _ = viewmodel.resume()
						default:
							let _ = viewmodel.playNext()
						}
					},
					onPause: {
						viewmodel.pause()
					},
					onNext: {
						withAnimation {
							let _ = viewmodel.playNext()
						}
					},
					onPrevious: {
						withAnimation {
							let _ = viewmodel.playPrev()
						}
					},
					isPlaying: .constant(viewmodel.isPlaying))
			}
			.onReceive(imageProvider.image(for: imageUrl), perform: { image in
				self.image = image
			})

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
	
	private var songListView: some View {
		ScrollViewReader { proxy in
			ScrollView {
				// TODO: pass in art ID instead of a thumbnail URL
				if !viewmodel.isFullLoading, let image = image {
					coverImageView(image: image)
				}

				LazyVStack {
					ForEach(viewmodel.songs.indices, id: \.self) { i in
						let song = viewmodel.songs[i]
						PlaylistItemView(
							song: song,
							isHighlighted: i == viewmodel.currentIndex
						)
						.padding(.leading, safeAreaInsets.leading)
						.padding(.trailing, safeAreaInsets.trailing)
						.onTapGesture {
							withAnimation {
								let _ = viewmodel.play(index: i)
							}
						}
						.onAppear {
							if i == viewmodel.songs.count - 1 {
								viewmodel.loadMore(category: category)
							}
						}
						.id(i)
						Divider().padding(.horizontal)
					}
				}
				.background(Color.background)
			}
			.onChange(of: viewmodel.currentIndex, perform: { value in
				withAnimation(.easeInOut(duration: 0.1)) {
					proxy.scrollTo(viewmodel.currentIndex)
				}
			})
		}
	}
	
	private var coverImageHeight: CGFloat {
		verticalSizeClass == .compact ? 120 : 300
	}
	
	private func coverImageView(image: UIImage) -> some View {
		GeometryReader { proxy in
			Image(uiImage: image)
				.resizable()
				.scaledToFill()
				.frame(
					width: proxy.size.width,
					height: max(0, coverImageHeight + proxy.frame(in: .global).minY)
				)
				.offset(y: -proxy.frame(in: .global).minY)
		}
		.frame(height: coverImageHeight)
	}
}

struct CategoryPlaylistView_Previews: PreviewProvider {
	static var previews: some View {
		CategoryPlaylistView(category: .featured, imageUrl: nil)
			.environmentObject(PlaylistViewModel())
	}
}
