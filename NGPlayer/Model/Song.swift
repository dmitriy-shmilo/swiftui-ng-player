//
//  Song.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import Foundation

struct Song: Identifiable {
	let id: UInt64
	let title: String
	let author: String
	let image: URL?
	let score: Float
	let duration: TimeInterval
}

struct SongSource: Codable {
	let src: String
}

struct SongStorageInfo: Codable {
	let id: UInt64
	let sources: [SongSource]
}

struct SongRequestResult: Codable {
	let content: String
}
