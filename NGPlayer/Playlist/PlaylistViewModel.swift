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
	@Published var songs = [Song]()
	@Published var isLoading = false
	@Published var isPlaying = false
	@Published var currentIndex: Int = -1
	
	var currentSong: Song? {
		currentIndex < 0 || currentIndex >= songs.count ? nil : songs[currentIndex]
	}
	
	private var player = AVPlayer()
	private var mutexRequests = Set<AnyCancellable>()
	private var playRequests = Set<AnyCancellable>()
	private var subs = Set<AnyCancellable>()
	
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
		mutexRequests.forEach { $0.cancel() }
		mutexRequests.removeAll()
		isLoading = true
		
		let url = NGUrlProvider.audioFor(category: category)
		let request = URLRequest(url: url)
		
		URLSession.shared
			.dataTaskPublisher(for: request)
			.filter { (data, response) in
				(response as? HTTPURLResponse)?.statusCode == 200
			}
			.compactMap { (data, response) in
				String(data: data, encoding: .utf8)
			}
			.tryMap { html -> [Song] in
				let doc = try SwiftSoup.parse(html)
				let list = try doc.select(".itemlist.alternating>*")
				return try list.compactMap { li -> Song? in
					guard let id = try UInt64(li.attr("data-hub-id")) else {
						return nil
					}
					guard let details = try li.select(".item-details").first() else {
						return nil
					}
					
					let title = try details.select(".detail-title > h4").text()
					let author = try details.select(".detail-title > span > strong").text()
					let image = try URL(string: li.select(".item-icon img").first()?.attr("src") ?? "")
					
					return Song(id: id, title: title, author: author, image: image, score: 0, duration: 0)
				}
			}
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { result in
				switch result {
				case.failure(let err):
					print(err)
				default:
					break
				}
			}, receiveValue: { [weak self] songs in
				self?.isLoading = false
				self?.songs = songs
			})
			.store(in: &mutexRequests)
	}
	
	// TODO: preload songs
	func play(index: Int) {
		guard index >= 0 && index < songs.count else {
			print("Request to play at an invalid index: \(index)")
			return
		}
		
		let song = songs[index]
		let url = URL(string: "https://www.newgrounds.com/audio/load/\(song.id)")!
		
		if currentIndex == index {
			resume()
			return
		} else {
			currentIndex = index
		}

		player.replaceCurrentItem(with: nil)
		playRequests.forEach { $0.cancel() }
		playRequests.removeAll()
		
		var request = URLRequest(url: url)
		request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
		
		URLSession.shared
			.dataTaskPublisher(for: request).filter { (data, response) in
				(response as? HTTPURLResponse)?.statusCode == 200
			}
			.map { (data, response) in
				data
			}
			.decode(type: SongStorageInfo.self, decoder: JSONDecoder())
			.compactMap { ssi in
				URL(string: ssi.sources.first?.src ?? "")
			}
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
					self?.isPlaying = true
				} catch {
					print("Failed to activate audio session")
				}
			})
			.store(in: &playRequests)
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
			isPlaying = true
		} catch {
			print("Failed to activate audio session")
		}
	}
	
	func pause() {
		player.pause()
		isPlaying = false
	}
	
	@objc private func onPlayerComplete() {
		playNex()
	}
}
