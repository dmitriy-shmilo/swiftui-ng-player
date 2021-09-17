//
//  PlayerControlsView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlayerControlsView: View {
	let onPlay: () -> Void
	let onPause: () -> Void
	let onNext: () -> Void
	let onPrevious: () -> Void
	
	@State private var isPlaying = false
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	var body: some View {
		
		HStack {
			Button(action: onPrevious) {
				Image(systemName: "backward.end")
					.foregroundColor(Color.secondaryButtonForeground)
			}
			.padding(.horizontal, 64)
			.padding(.vertical, 16)
			Spacer()
			
			Button(action: {
				isPlaying.toggle()
				if isPlaying {
					onPlay()
				} else {
					onPause()
				}
			}) {
				Image(systemName: isPlaying ? "play" : "pause")
					.foregroundColor(Color.secondaryButtonForeground)
			}
			
			Spacer()
			Button(action: onNext) {
				Image(systemName: "forward.end")
					.foregroundColor(Color.secondaryButtonForeground)
			}
			.padding(.horizontal, 64)
		}
		.font(.system(size: 32, weight: .thin))
		.padding(.vertical)
		.padding(.bottom, safeAreaInsets.bottom)
		.padding(.leading, safeAreaInsets.leading)
		.padding(.trailing, safeAreaInsets.trailing)
		.background(Color.secondaryBackground)
	}
}

struct PlayerControlsView_Previews: PreviewProvider {
	static var previews: some View {
		PlayerControlsView(onPlay: {}, onPause: {}, onNext: {}, onPrevious: {})
	}
}
