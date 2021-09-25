//
//  PlaylistViewModel.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI
import Combine


class PlaylistViewModel: ObservableObject {
	
	// TODO: separate player and network state
	enum State {
		case idle
		case loading(request: AnyCancellable)
		case error(error: Error)
	}
	
	let category: AudioCategory

	@Published
	var state = State.idle
	@Published
	var songs = [Song]()
	@Published
	var currentIndex: Int = -1
	
	var currentSong: Song? {
		currentIndex < 0 || currentIndex >= songs.count ? nil : songs[currentIndex]
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
	
	private var api = NGApi()
	
	init(category: AudioCategory) {
		self.category = category
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
}
