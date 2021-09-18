//
//  ArtCategory.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 18.09.2021.
//

import Foundation

enum ArtCategory: Hashable {
	case featured
	case latest
	case popular
}

extension ArtCategory {
	var urlComponent: String {
		switch self {
		case .featured:
			return "featured"
		case .latest:
			return "browse"
		case .popular:
			return "popular"
		}
	}
}
