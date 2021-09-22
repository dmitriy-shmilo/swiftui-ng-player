//
//  PlayerControlsView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlayerControlsView: View {
	
	@EnvironmentObject
	private var imageProvider: ImageProvider
	
	@EnvironmentObject
	private var playlistViewModel: PlaylistViewModel
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	@Environment(\.verticalSizeClass)
	private var verticalSizeClass
	
	@State
	private var image = UIImage(named: "AudioIconDefault")!

	var body: some View {
		
		VStack(spacing: 0) {
			Divider()
			SongDurationIndicator(
				fill: CGFloat(playlistViewModel.currentTime / playlistViewModel.currentDuration)
			)
			
			HStack(spacing: 8) {
				if let song = playlistViewModel.currentSong {
					Image(uiImage: image)
						.resizable()
						.scaledToFit()
						.frame(width: 45, height: 45, alignment: .center)
						.onReceive(imageProvider.image(
							for: song.image
						)) { img in
							image = img ?? UIImage(named: "AudioIconDefault")!
						}
						.padding(.horizontal)
					
					VStack(alignment: .leading) {
						Text(song.title)
							.font(.system(size: 18, weight: .light))
							.foregroundColor(.primaryFont)
							.lineLimit(1)
						Text(song.author)
							.font(.system(size: 12, weight: .regular))
							.foregroundColor(.secondaryFont)
							.lineLimit(1)
					}
				}
				
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
				}
				.padding(.horizontal)
				
				Button(action: {
					let _ = playlistViewModel.playNext()
				}) {
					Image(systemName: "forward.end")
						.foregroundColor(Color.secondaryButtonForeground)
				}
				.padding(.horizontal)
			}
			.font(.system(size: verticalSizeClass == .compact ? 24 : 32, weight: .thin))
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
