//
//  PlaylistViewModel.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI
import SwiftSoup
import Combine
import AVKit
import MediaPlayer

class PlaylistViewModel: ObservableObject {
	
	// TODO: separate player and network state
	enum State {
		case idle
		case loading(request: AnyCancellable)
		case playing
		case paused
		case error(error: Error)
	}
	
	@Published var state = State.idle
	@Published var songs = [Song]()
	@Published var currentIndex: Int = -1
	@Published var currentDuration: TimeInterval = 0
	@Published var currentTime: TimeInterval = 0
	
	var currentSong: Song? {
		currentIndex < 0 || currentIndex >= songs.count ? nil : songs[currentIndex]
	}
	
	var isPlaying: Bool {
		switch state {
		case .playing:
			return true
		default:
			return false
		}
	}
	
	var isFullLoading: Bool {
		switch state {
		case .loading(request: _):
			return songs.count == 0
		default:
			return false
		}
	}
	
	var hasSongs: Bool {
		songs.count > 0
	}
	
	private var player = AVPlayer()
	private var api = NGApi()
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
	
	func load(category: AudioCategory) {
		
		songs.removeAll(keepingCapacity: true)
		currentIndex = -1
		
		state = .loading(
			request: api.loadSongsFor(category: category, offset: 0)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { [weak self] result in
					switch result {
					case.failure(let err):
						self?.state = .error(error: err)
						print(err)
					case .finished:
						self?.state = .idle
						break
					}
				}, receiveValue: { [weak self] songs in
					self?.songs.append(contentsOf: songs)
				})
		)
	}
	
	func loadMore(category: AudioCategory) {
		state = .loading(
			request: api.loadSongsFor(category: category, offset: songs.count)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { [weak self] result in
					switch result {
					case.failure(let err):
						self?.state = .error(error: err)
						print(err)
					case .finished:
						self?.state = .idle
						break
					}
				}, receiveValue: { [weak self] songs in
					self?.songs.append(contentsOf: songs)
				})
		)
	}
	
	// TODO: preload songs
	func play(index: Int) -> Bool {
		guard index >= 0 && index < songs.count else {
			print("Request to play at an invalid index: \(index)")
			return false
		}
		
		let song = songs[index]
		
		if currentIndex == index {
			resume()
			return true
		} else {
			currentIndex = index
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
	
	func playNext() -> Bool {
		return play(index: currentIndex >= songs.count - 1 ? 0 : currentIndex + 1)
	}
	
	func playPrev() -> Bool {
		return play(index: currentIndex <= 0 ? songs.count - 1 : currentIndex - 1)
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
			if self.player.rate == 0.0
				&& self.play(index: self.currentIndex) {
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
