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
	
	private var player = AVPlayer()
	private var mutexRequests = Set<AnyCancellable>()
	private var playRequests = Set<AnyCancellable>()
	
	func load() {
		mutexRequests.forEach { $0.cancel() }
		mutexRequests.removeAll()
		isLoading = true
		
		guard let url = URL(string:"https://www.newgrounds.com/audio/featured?type=1") else {
			// TODO: report errors
			return
		}
		
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
	
	func play(song: Song) {
		guard let url = URL(string: "https://www.newgrounds.com/audio/load/\(song.id)") else {
			return
		}
		
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
				} catch {
					print("Failed to activate audio session")
				}
			})
			.store(in: &playRequests)
	}
}