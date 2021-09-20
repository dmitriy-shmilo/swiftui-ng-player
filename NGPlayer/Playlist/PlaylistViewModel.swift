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

class PlaylistViewModel: ObservableObject {
	
	enum State {
		case idle
		case loading(request: AnyCancellable)
		case playing
		case error(error: Error)
	}
	
	@Published var state = State.idle
	@Published var songs = [Song]()
	@Published var currentIndex: Int = -1
	
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
	
	private var player = AVPlayer()
	private var api = NGApi()
	
	init() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onPlayerComplete),
			name: .AVPlayerItemDidPlayToEndTime,
			object: player.currentItem
		)
		player.rate = 3.0
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func load(category: AudioCategory) {
		state = .loading(
			request: api.loadSongsFor(category: category)
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
					self?.songs = songs
				})
		)
	}
	
	// TODO: preload songs
	func play(index: Int) {
		guard index >= 0 && index < songs.count else {
			print("Request to play at an invalid index: \(index)")
			return
		}
		
		let song = songs[index]
		
		if currentIndex == index {
			resume()
			return
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
					do {
						try AVAudioSession.sharedInstance().setActive(true)
						let item = AVPlayerItem(url: src)
						self?.player.replaceCurrentItem(with: item)
						self?.player.play()
						self?.state = .playing
					} catch {
						print("Failed to activate audio session")
					}
				})
		)
	}
	
	func playNex() {
		play(index: currentIndex + 1)
	}
	
	func playPrev() {
		play(index: currentIndex - 1)
	}
	
	func resume() {
		do {
			try AVAudioSession.sharedInstance().setActive(true)
			player.play()
			state = .playing
		} catch {
			print("Failed to activate audio session")
		}
	}
	
	func pause() {
		player.pause()
		state = .idle
	}
	
	@objc private func onPlayerComplete() {
		playNex()
	}
}
