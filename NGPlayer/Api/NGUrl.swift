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
	static func audioFor(category: AudioCategory, offset: Int = 0) -> URL {
		URL(string: "\(Root)/audio/\(category.urlComponent)?interval=all&sort=date&genre=\(category.genreId)&isAjaxRequest=1&offset=\(offset)")!
	}
	
	static func audioLoadFor(id: UInt64) -> URL {
		return URL(string: "https://www.newgrounds.com/audio/load/\(id)")!
	}
	
	static func art(category: ArtCategory) -> URL {
		URL(string: "\(Root)/art/\(category.urlComponent)?interval=all&sort=date&genre=0&suitabilities=e")!
	}
}
