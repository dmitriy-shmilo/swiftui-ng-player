//
//  PlaylistItemView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlaylistItemView: View {
	let song: Song
	let isHighlighted: Bool

	@State private var image = UIImage(named: "AudioIconDefault")!
	@EnvironmentObject private var imageProvider: ImageProvider
	
	var body: some View {
		HStack {
			Image(uiImage: image)
				.resizable()
				.scaledToFit()
				.frame(width: 45, height: 45, alignment: .center)
				.onReceive(imageProvider.image(for: song.image)) { img in
					image = img ?? UIImage(named: "AudioIconDefault")!
				}
				.padding(6)
				.background(
					Circle()
						.stroke(
							Color.accentColor,
							style: StrokeStyle(lineWidth: isHighlighted ? 3.0 : 0.0)
						)
				)
			VStack(alignment: .leading) {
				Text(song.title)
					.font(.system(size: 22, weight: .light))
					.foregroundColor(.primaryFont)
					.padding(.bottom, 4)
				Text(song.author)
					.font(.system(size: 14, weight: .regular))
					.foregroundColor(.secondaryFont)
			}
			Spacer()
		}
		.frame(height: 70)
		.padding(.horizontal, isHighlighted ? 16 : 32)

	}
}

struct PlaylistItemView_Previews: PreviewProvider {
    static var previews: some View {
		PlaylistItemView(song: Song(id: 0, title: "Some song", author: "Somebody", image: nil, score: 4.5, duration: 100), isHighlighted: false)
    }
}
