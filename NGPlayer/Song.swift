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
	let image: String
	let score: Float
	let duration: TimeInterval
}
