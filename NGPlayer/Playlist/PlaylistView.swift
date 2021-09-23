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
	let imageAsset: String?
	
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
	
	@Environment(\.currentPlayerHeight)
	private var currentPlayerHeight
	
	@State
	private var image: UIImage?
	
	var body: some View {
		var result =
		ZStack(alignment: .top) {
			if viewmodel.isFullLoading {
				VStack(alignment: .center) {
					Spacer()
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
					Spacer()
				}
			} else {
				songListView
			}
			
			navBarView
		}
		.ignoresSafeArea()
		.background(Color.background.ignoresSafeArea())
		.onAppear {
			viewmodel.load(category: category)
		}
		.navigationBarHidden(true)
		.eraseToAnyView()
		
		
		if let imageUrl = imageUrl {
			result = result.onReceive(
				imageProvider.image(for: imageUrl)) { image in
					self.image = image
				}
				.eraseToAnyView()
		} else if let imageAsset = imageAsset {
			result = result.onAppear {
				image = UIImage(named: imageAsset)
			}
			.eraseToAnyView()
		}
		
		return result
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
				
				LazyVStack(spacing: 0) {
					playlistButton
						.zIndex(1)

					ForEach(viewmodel.songs.indices, id: \.self) { i in
						let song = viewmodel.songs[i]
						Divider().padding(.horizontal)
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
					}
					
					Spacer()
						.frame(height: currentPlayerHeight)
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
	
	private var playlistButton: some View {
		HStack {
			Spacer()
			Button(action: {
				let _ = viewmodel.togglePlay()
			}) {
				Image(systemName: viewmodel.isPlaying ? "pause" : "play.fill")
					.resizable()
					.scaledToFit()
					.foregroundColor(.accentColor)
					.frame(width: 32, height: 32)
					// "play" icon is a bit heavy on the left
					.offset(x: viewmodel.isPlaying ? 0 : 4)
			}
			.frame(width: 64, height: 64)
			.background(LinearGradient(
				gradient: Gradient(colors: [
					Color.buttonBackground1,
					Color.buttonBackground2
				]),
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			))
			.overlay(Circle().stroke(Color.buttonBorderBackground, lineWidth: 2))
			.clipShape(Circle())
			.padding()
		}
		.frame(height: 0)
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
		CategoryPlaylistView(category: .featured, imageUrl: nil, imageAsset: nil)
			.environmentObject(PlaylistViewModel())
	}
}
