//
//  NGApi.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 19.09.2021.
//

import Foundation
import Combine
import SwiftSoup

class NGApi {

	func loadSongsFor(category: AudioCategory, offset: Int = 0) -> AnyPublisher<[Song], Error> {
		let url = NGUrl.audioFor(category: category, offset: offset)
		let request = URLRequest(url: url)
		
		return URLSession.shared
			.dataTaskPublisher(for: request)
			.filter { (data, response) in
				(response as? HTTPURLResponse)?.statusCode == 200
			}
			.map { (data, response) in
				data
			}
			.decode(type: SongRequestResult.self, decoder: JSONDecoder())
			.tryMap { result -> [Song] in
				let doc = try SwiftSoup.parseBodyFragment(result.content)
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
			.eraseToAnyPublisher()
	}
	
	func loadSongSourceFor(id: UInt64) -> AnyPublisher<URL, Error> {
		let url = NGUrl.audioLoadFor(id: id)
		var request = URLRequest(url: url)
		request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
		
		return URLSession.shared
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
			.eraseToAnyPublisher()
	}
	
	func loadArtFor(category: ArtCategory) -> AnyPublisher<[Art], Error> {
		let url = NGUrl.art(category: category)
		let request = URLRequest(url: url)
		
		return URLSession.shared
			.dataTaskPublisher(for: request)
			.filter { (data, response) in
				(response as? HTTPURLResponse)?.statusCode == 200
			}
			.compactMap { (data, response) in
				String(data: data, encoding: .utf8)
			}
			.tryMap { html -> [Art] in
				let doc = try SwiftSoup.parse(html)
				let list = try doc.select(".portalitem-art-icons-medium>*")
				return try list.compactMap { div -> Art? in
					guard let id = try UInt64(div.attr("data-hub-id")) else {
						return nil
					}

					guard let details = try div.select("a").first() else {
						return nil
					}
					
					guard let image = try URL(string: details.select(".item-icon img").first()?.attr("src") ?? "") else {
						return nil
					}
					
					let title = try details.select("h4").text()
					let author = try details.select("span").text()
					
					return Art(id: id, title: title, author: author, image: image)
				}
			}
			.eraseToAnyPublisher()
	}
}
