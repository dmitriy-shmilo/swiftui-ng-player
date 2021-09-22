//
//  Genre.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import Foundation

enum Genre: Int {
	case jazz = 18
	case punk = 28
	case techno = 10
}

extension Genre {
	// TODO: localize
	var localizedLabel: String {
		switch self {
		case .jazz:
			return "Jazz"
		case .punk:
			return "Punk"
		case .techno:
			return "Techno"
		}
	}
	
	var assetName: String? {
		switch self {
		case .jazz:
			return "Jazz"
		case .punk:
			return "Punk"
		case .techno:
			return "Techno"
		}
	}
}
