//
//  SongDurationIndicator.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 22.09.2021.
//

import SwiftUI

struct SongDurationIndicator: View {
	let progress: Double
	let onSeek: (Double) -> Void
	
	var body: some View {
		GeometryReader { proxy in
			ZStack(alignment: .leading) {
				Rectangle()
					.fill(Color.buttonBorderBackground)
					.frame(width: proxy.size.width, height: 5)

				let fill = CGFloat(max(0, min(progress, 1.0)))
				Rectangle()
					.fill(Color.accentColor)
					.frame(width: proxy.size.width * fill, height: 3)
				
				Circle()
					.fill(Color.accentColor)
					.frame(width: 9, height: 9)
					.offset(x: proxy.size.width * fill)
			}
			.gesture(DragGesture(minimumDistance: 0).onChanged { value in
				onSeek(Double(value.location.x / proxy.size.width))
			})
		}
		.frame(height:9)
	}
}

struct SongDurationIndicator_Previews: PreviewProvider {
	static var previews: some View {
		SongDurationIndicator(progress: 0.3) { _ in }
	}
}
