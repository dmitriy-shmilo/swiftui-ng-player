//
//  PlaylistViewModel.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI
import SwiftSoup
import Combine

class PlaylistViewModel: ObservableObject {
	@Published var songs = [Song]()
	@Published var isLoading = false
	
	private var mutexRequests = Set<AnyCancellable>()
	
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

					return Song(id: id, title: title, author: author, image: "", score: 0, duration: 0)
				}
			}
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { err in
				print(err)
			}, receiveValue: { [weak self] songs in
				self?.isLoading = false
				self?.songs = songs
			})
			.store(in: &mutexRequests)
	}
}
