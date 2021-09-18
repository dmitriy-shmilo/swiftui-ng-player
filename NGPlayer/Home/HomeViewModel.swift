//
//  HomeViewModel.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import Foundation
import Combine
import SwiftSoup

class HomeViewModel: ObservableObject {

	enum State {
		case idle
		case loading
		case done
		case error
	}

	@Published var state: State = .idle
	
	private var artForCategory = [AudioCategory : Art]()
	private var art = [Art]()
	private var disposeBag = Set<AnyCancellable>()
	
	func load() {
		guard state != .done && state != .loading else {
			return
		}

		let url = NGUrl.art()
		let request = URLRequest(url: url)
		
		state = .loading
		
		URLSession.shared
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
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] result in
				switch result {
				case.failure(let err):
					print(err)
					self?.state = .error
				default:
					self?.state = .done
					break
				}
			}, receiveValue: { [weak self] art in
				self?.art = art.shuffled()
			})
			.store(in: &disposeBag)
	}
	
	func imageUrlFor(category: AudioCategory) -> URL? {
		if let art = artForCategory[category] {
			return art.image
		} else {
			let art = art.remove(at: 0)
			artForCategory[category] = art
			return art.image
		}
	}
}
