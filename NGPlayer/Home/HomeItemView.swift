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
	
	@EnvironmentObject
	private var viewModel: HomeViewModel
	@EnvironmentObject
	private var imageProvider: ImageProvider
	
	var body: some View {
		ZStack(alignment:.bottom) {
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFill()
					.frame(width: 180, height: 180)
			} else {
				Spacer()
					.frame(width: 180, height: 180)
			}
			
			Text(item.localizedLabel)
				.font(.title2)
				.foregroundColor(.primaryFont)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 6)
				.background(Color.black.opacity(0.35))
		}
		.background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2378290296, green: 0.2470975518, blue: 0.264349848, alpha: 1)), Color(#colorLiteral(red: 0.2731795907, green: 0.2823192477, blue: 0.3039281964, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
		.clipShape(RoundedRectangle(cornerRadius: 8))
		.onReceive(viewModel.$state, perform: { state in
			if state == .done {
				self.imageUrl = viewModel.imageUrlFor(category: item)
			}
		})
		.onReceive(imageProvider.image(for: imageUrl), perform: { image in
			self.image = image
		})
	}
	
	func image(url: URL?) -> some View {
		return onReceive(imageProvider.image(for: url), perform: { img in
			self.image = img
		})
	}
}

struct HomeItemView_Previews: PreviewProvider {
    static var previews: some View {
		HomeItemView(item: .featured)
    }
}
