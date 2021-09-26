//
//  LazyView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 26.09.2021.
//

import SwiftUI

struct LazyView<Content: View>: View {
	let build: () -> Content
	
	init(_ build: @autoclosure @escaping () -> Content) {
		self.build = build
	}

	var body: Content {
		build()
	}
}
