//
//  PlayerViewModel.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 24.09.2021.
//

import Foundation
import AVKit
import MediaPlayer
import Combine

class PlayerViewModel: ObservableObject {
	enum State {
		case idle
		case loading(request: AnyCancellable)
		case playing
		case paused
	}
	
	@Published
	var state = State.idle
	@Published
	var currentDuration: TimeInterval = 0
	@Published
	var currentTime: TimeInterval = 0
	@Published
	var currentPlaylist: PlaylistViewModel?
	
	var currentProgress: Double {
		guard currentDuration > 0 && currentTime > 0 else {
			return 0.0
		}
		
		return currentTime / currentDuration
	}
	
	var isPlaying: Bool {
		switch state {
		case .playing:
			return true
		default:
			return false
		}
	}
	
	// TODO: inject api
	private var api = NGApi()
	private var player = AVPlayer()
	private var commandCenterPlayTarget: Any?
	private var commandCenterPauseTarget: Any?
	private var commandCenterPlayNextTarget: Any?
	private var playerTimeObserver: Any?
	
	init() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onPlayerComplete),
			name: .AVPlayerItemDidPlayToEndTime,
			object: player.currentItem
		)
		setupRemoteCommandCenter()
		playerTimeObserver = player.addPeriodicTimeObserver(
			forInterval: CMTimeMakeWithSeconds(1.0, preferredTimescale: 1),
			queue: DispatchQueue.main
		) { [weak self] time in
			if let self = self, let item = self.player.currentItem {
				let currentTime = CMTimeGetSeconds(item.currentTime())
				if currentTime.isFinite && !currentTime.isNaN {
					self.currentTime = currentTime
				} else {
					self.currentTime = 0
				}
				
				let currentDuration = CMTimeGetSeconds(item.duration)
				if currentDuration.isFinite && !currentDuration.isNaN {
					self.currentDuration = currentDuration
				} else {
					self.currentDuration = 0
				}
			}
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
		teardownRemoteCommandCenter()
		if let playerTimeObserver = playerTimeObserver {
			player.removeTimeObserver(playerTimeObserver)
		}
	}
	
	func ensureCurrentPlaylist(is playlist: PlaylistViewModel) {
		// TODO: implement hashable and equatable for playlists
		guard currentPlaylist !== playlist else {
			return
		}
		
		currentPlaylist = playlist
		state = .paused
		
	}
	
	// TODO: preload songs
	func play(index: Int) -> Bool {
		guard let playlist = currentPlaylist else {
			print("Request to play without a playlist")
			return false
		}
		guard index >= 0 && index < playlist.songs.count else {
			print("Request to play at an invalid index: \(index)")
			return false
		}
		
		let song = playlist.songs[index]
		
		if playlist.currentIndex == index {
			resume()
			return true
		} else {
			playlist.currentIndex = index
		}
		
		player.replaceCurrentItem(with: nil)
		state = .loading(
			request: api.loadSongSourceFor(id: song.id)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { result in
					switch result {
					case .failure(let err):
						print(err)
					default:
						break
					}
				}, receiveValue: { [weak self] src in
						if let self = self {
							self.state = .playing
							DispatchQueue.global(qos: .userInitiated).async {
								self.setupNowPlaying(song: song)
								do {
									let item = AVPlayerItem(url: src)
									self.player.replaceCurrentItem(with: item)
									self.player.play()
									try AVAudioSession.sharedInstance().setActive(true)
								} catch {
									print("Failed to activate audio session")
								}
							}
						}
				})
		)
		
		return true
	}
	
	func togglePlay() -> Bool {
		switch state {
		case .playing:
			pause()
			return true
		case .paused:
			resume()
			return true
		default:
			return playNext()
		}
	}

	func playNext() -> Bool {
		guard let playlist = currentPlaylist, playlist.songs.count > 0 else {
			return false
		}
		return play(index: (playlist.currentIndex + 1) % playlist.songs.count)
	}
	
	func playPrev() -> Bool {
		guard let playlist = currentPlaylist, playlist.songs.count > 0 else {
			return false
		}
		return play(index: (playlist.currentIndex - 1) % playlist.songs.count)
	}
	
	func resume() {
		guard case .paused = state else {
			print("Attempt to resume a non-paused player")
			return
		}
		
		do {
			try AVAudioSession.sharedInstance().setActive(true)
			player.play()
			state = .playing
		} catch {
			print("Failed to activate audio session")
		}
	}
	
	func pause() {
		guard case .playing = state else {
			print("Attempt to pause a non-playing player")
			return
		}
		
		do {
			player.pause()
			state = .paused
			try AVAudioSession.sharedInstance().setActive(false)
		} catch {
			print("Failed to deactivate audio session")
		}
	}
	
	func seek(value: Double) {
		guard currentDuration > 0 && currentDuration.isFinite && !currentDuration.isNaN else {
			return
		}
		player.seek(to: CMTimeMakeWithSeconds(currentDuration * value, preferredTimescale: Int32(NSEC_PER_SEC)))
	}
	
	@objc private func onPlayerComplete() {
		let _ = playNext()
	}
	
	private func setupNowPlaying(song: Song) {
		var nowPlayingInfo = [String : Any]()
		nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
		
		// TODO: grab song artwork from an image provider
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentItem?.currentTime().seconds
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
		
		
		// Set the metadata
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	private func setupRemoteCommandCenter() {
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenterPlayNextTarget = commandCenter.nextTrackCommand.addTarget { [unowned self] event in
			if self.playNext() {
				return .success
			}
			
			return .commandFailed
		}
		
		commandCenterPlayTarget = commandCenter.playCommand.addTarget { [unowned self] event in
			guard let playlist = currentPlaylist else {
				return .commandFailed
			}

			if self.player.rate == 0.0
				&& self.play(index: playlist.currentIndex) {
				return .success
			}
			return .commandFailed
		}
		
		commandCenterPauseTarget = commandCenter.pauseCommand.addTarget { [unowned self] event in
			if self.player.rate == 1.0 {
				self.pause()
				return .success
			}
			return .commandFailed
		}
		
	}
	
	private func teardownRemoteCommandCenter() {
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.nextTrackCommand.removeTarget(commandCenterPlayNextTarget)
		commandCenter.playCommand.removeTarget(commandCenterPlayTarget)
		commandCenter.pauseCommand.removeTarget(commandCenterPauseTarget)
	}
}
