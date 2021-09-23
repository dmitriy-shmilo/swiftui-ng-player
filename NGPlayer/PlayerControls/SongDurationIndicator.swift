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
		ZStack {
			GeometryReader { proxy in
				Path { path in
					path.move(to: CGPoint(x: 0, y: 0))
					path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
				}
				.stroke(Color.buttonBorderBackground, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
				
				let fill = max(0, min(fill, 1.0))
				Path { path in
					path.move(to: CGPoint(x: 0, y: 0))
					path.addLine(to: CGPoint(x: proxy.size.width * fill, y: 0))
				}
				.stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
			}
			.frame(height:5)
		}
	}
}

struct SongDurationIndicator_Previews: PreviewProvider {
	static var previews: some View {
		SongDurationIndicator(fill: 0.3)
	}
}
