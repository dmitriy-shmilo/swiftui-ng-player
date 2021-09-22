//
//  PlayerControlsView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlayerControlsView: View {
	
	@EnvironmentObject
	private var playlistViewModel: PlaylistViewModel
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	@Environment(\.verticalSizeClass)
	private var verticalSizeClass
	
	var body: some View {
		
		VStack(spacing: 0) {
			Divider()
			
			HStack {
				Text(formatTime(playlistViewModel.currentTime))
				Spacer()
				Text(formatTime(playlistViewModel.currentDuration))
			}
			.foregroundColor(.secondaryFont)
			.padding(.horizontal)
			.padding(.leading, safeAreaInsets.leading)
			.padding(.trailing, safeAreaInsets.trailing)
			.padding(.top)
			
			HStack(spacing: 0) {
				Button(action: {
					let _ = playlistViewModel.playPrev()
				}) {
					Image(systemName: "backward.end")
						.foregroundColor(Color.secondaryButtonForeground)
				}
				.padding(.horizontal, 64)
				.padding(.vertical, 16)
				Spacer()
				
				Button(action: {
					switch playlistViewModel.state {
					case .playing:
						playlistViewModel.pause()
					case .paused:
						let _ = playlistViewModel.resume()
					default:
						let _ = playlistViewModel.playNext()
					}
				}) {
					Image(systemName: playlistViewModel.isPlaying ? "pause" : "play")
						.foregroundColor(Color.primaryButtonForeground)
						.font(.system(size: verticalSizeClass == .compact ? 28 : 44, weight: .thin))
				}
				
				Spacer()
				Button(action: {
					let _ = playlistViewModel.playNext()
				}) {
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
		.background(GeometryReader { proxy in
			Color.secondaryBackground
				.reportCurrentPlayerHeight(proxy.frame(in: .global).height)
		})
	}
	
	private func formatTime(_ interval: TimeInterval) -> String {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.minute, .second]
		formatter.unitsStyle = .positional
		formatter.zeroFormattingBehavior = .pad
		return formatter.string(from: interval) ?? "00:00"
	}
}

struct PlayerControlsView_Previews: PreviewProvider {
	static var previews: some View {
		PlayerControlsView()
	}
}
