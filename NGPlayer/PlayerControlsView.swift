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
	
	@Binding
	var isPlaying: Bool
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets

	@Environment(\.verticalSizeClass)
	private var verticalSizeClass
	
	var body: some View {
		
		VStack(spacing: 0) {
			Divider()
			
			HStack(spacing: 0) {
				Button(action: onPrevious) {
					Image(systemName: "backward.end")
						.foregroundColor(Color.secondaryButtonForeground)
				}
				.padding(.horizontal, 64)
				.padding(.vertical, 16)
				Spacer()
				
				Button(action: {
					if isPlaying {
						onPause()
					} else {
						onPlay()
					}
				}) {
					Image(systemName: isPlaying ? "pause" : "play")
						.foregroundColor(Color.primaryButtonForeground)
						.font(.system(size: verticalSizeClass == .compact ? 28 : 44, weight: .thin))
				}
				
				Spacer()
				Button(action: onNext) {
					Image(systemName: "forward.end")
						.foregroundColor(Color.secondaryButtonForeground)
				}
				.padding(.horizontal, 64)
			}
			.font(.system(size: verticalSizeClass == .compact ? 22 : 32, weight: .thin))
			.padding(.vertical, verticalSizeClass == .compact ? 2 : 16)
			.padding(.bottom, safeAreaInsets.bottom)
			.padding(.horizontal, max(safeAreaInsets.leading, safeAreaInsets.trailing))
		}
		.background(Color.secondaryBackground)
	}
}

struct PlayerControlsView_Previews: PreviewProvider {
	static var previews: some View {
		PlayerControlsView(onPlay: {}, onPause: {}, onNext: {}, onPrevious: {}, isPlaying: .constant(false))
	}
}
