//
//  PlaylistItemView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlaylistItemView: View {
	let isHighlighted: Bool

	var body: some View {
		HStack {
			Image("AudioIconDefault")
				.resizable()
				.scaledToFit()
				.shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
			VStack(alignment: .leading) {
				Text("Default Title")
					.font(.system(size: 22, weight: .light))
					.padding(.bottom, 4)
				Text("by Somebody")
					.font(.system(size: 14, weight: .regular))
					.foregroundColor(.secondary)
			}
			Spacer()
		}
		.frame(height: 70)
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 8)
				.fill(Color(#colorLiteral(red: 0.999904573, green: 1, blue: 0.999872148, alpha: 1)))
				.shadow(
					color: isHighlighted
						? .accentColor.opacity(0.3)
						: .gray.opacity(0.2),
					radius: 8,
					x: 0,
					y: 8))
		.padding(.vertical, 8)
		.padding(.horizontal, isHighlighted ? 16 : 32)

	}
}

struct PlaylistItemView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistItemView(isHighlighted: false)
    }
}
