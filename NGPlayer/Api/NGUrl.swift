//
//  NGApi.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import Foundation

struct NGUrl {
	private static let Root = "https://www.newgrounds.com"

	// TODO: add sort parameter
	static func audioFor(category: AudioCategory) -> URL {
		URL(string: "\(Root)/audio/\(category.urlComponent)?interval=all&sort=date&genre=\(category.genreId)")!
	}
	
	static func art() -> URL {
		URL(string: "\(Root)/art/featured?interval=all&sort=date&genre=0&suitabilities=e")!
	}
}
