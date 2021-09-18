//
//  HomeItem.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import Foundation

enum AudioCategory: Hashable {
	case featured
	case latest
	case popular
	case genre(genre: Genre)
}

extension AudioCategory {
	var localizedLabel: String {
		switch self {
		case .featured:
			return "Featured"
		case .latest:
			return "Latest"
		case .popular:
			return "Popular"
		case .genre(let genre):
			return genre.localizedLabel()
		}
	}
	
	var urlComponent: String {
		switch self {
		case .featured:
			return "featured"
		case .latest:
			return "browse"
		case .popular:
			return "popular"
		case .genre:
			return "browse"
		}
	}
	
	var genreId: Int {
		if case .genre(let genre) = self {
			return genre.rawValue
		}
		return 0
	}
}
