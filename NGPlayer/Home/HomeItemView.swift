//
//  HomeItemView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import SwiftUI

struct HomeItemView: View {
	let item: AudioCategory
	
	@State
	private var image: UIImage?
	@State
	private var imageUrl: URL?
	@State
	private var imageAsset: String?
	
	@EnvironmentObject
	private var viewModel: HomeViewModel
	@EnvironmentObject
	private var imageProvider: ImageProvider
	
	var body: some View {
		NavigationLink(
			destination: LazyView(CategoryPlaylistView(
				category: item,
				imageUrl: imageUrl,
				imageAsset: imageAsset,
				viewmodel: PlaylistViewModel(category: item)
			))
		) {
			ZStack(alignment:.bottom) {
				imageView
				Text(item.localizedLabel)
					.font(.title2)
					.foregroundColor(.primaryFont)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 6)
					.background(Color.black.opacity(0.35))
			}
			.background(LinearGradient(
				gradient: Gradient(colors: [
					Color.buttonBackground1,
					Color.buttonBackground2
				]),
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			))
			.clipShape(RoundedRectangle(cornerRadius: 8))
			.onReceive(viewModel.$state, perform: { state in
				if state == .done {
					if let asset = viewModel.imageAssetFor(category: item) {
						self.imageAsset = asset
					} else {
						self.imageUrl = viewModel.imageUrlFor(category: item)
					}
				}
			})
		}
	}
	
	private var imageView: some View {
		var result: AnyView
		if let imageAsset = imageAsset {
			result = Image(imageAsset)
				.resizable()
				.scaledToFill()
				.eraseToAnyView()
		} else if let image = image {
			result = Image(uiImage: image)
				.resizable()
				.scaledToFill()
				.eraseToAnyView()
		} else {
			// TODO: return a placeholder image
			result = Spacer()
				.eraseToAnyView()
		}
		
		if let imageUrl = imageUrl {
			result = result.onReceive(imageProvider.image(for: imageUrl), perform: { image in
				self.image = image
			}).eraseToAnyView()
		}
		
		return result
			.frame(width: 180, height: 180)
	}
}

struct HomeItemView_Previews: PreviewProvider {
	static var previews: some View {
		HomeItemView(item: .featured)
	}
}
