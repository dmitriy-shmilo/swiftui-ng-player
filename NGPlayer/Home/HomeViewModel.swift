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

	@Published
	private(set) var state: State = .idle
	
	private var artForCategory = [AudioCategory : Art]()
	private var art = [Art]()
	private var disposeBag = Set<AnyCancellable>()
	private var api = NGApi()
	
	func load() {
		guard state != .done && state != .loading else {
			return
		}
		state = .loading
		
		api.loadArtFor(category: .featured)
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
	
	func imageAssetFor(category: AudioCategory) -> String? {
		switch category {
		case .genre(let genre):
			return genre.assetName
		default:
			return nil
		}
	}
	
	func imageUrlFor(category: AudioCategory) -> URL? {
		guard art.count > 0 else {
			return nil
		}

		if let art = artForCategory[category] {
			return art.image
		} else {
			let art = art.remove(at: 0)
			artForCategory[category] = art
			return art.image
		}
	}
}
