//
//  SongDurationIndicator.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 22.09.2021.
//

import SwiftUI

// TODO: add a seek handle
struct SongDurationIndicator: View {
	let fill: CGFloat
	
	var body: some View {
		GeometryReader { proxy in
			ZStack(alignment: .leading) {
				Rectangle()
					.fill(Color.buttonBorderBackground)
					.frame(width: proxy.size.width, height: 5)

				let fill = max(0, min(fill, 1.0))
				Rectangle()
					.fill(Color.accentColor)
					.frame(width: proxy.size.width * fill, height: 3)
				
				Circle()
					.fill(Color.accentColor)
					.frame(width: 9, height: 9)
					.offset(x: proxy.size.width * fill)
			}
		}
		.frame(height:9)
	}
}

struct SongDurationIndicator_Previews: PreviewProvider {
	static var previews: some View {
		SongDurationIndicator(fill: 0.3)
	}
}
