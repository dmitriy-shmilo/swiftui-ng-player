//
//  ContentView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI

struct PlaylistView: View {
	@State private var currentItem = 0
	
	@Environment(\.safeAreaInsets)
	private var safeAreaInsets
	
	var body: some View {
		ZStack(alignment: .bottom) {
			ScrollView {
				LazyVStack {
					Spacer()
						.frame(height: safeAreaInsets.top)
					
					ForEach(0...10, id: \.self) { i in
						PlaylistItemView(isHighlighted: i == currentItem)
							.padding(.leading, safeAreaInsets.leading)
							.padding(.trailing, safeAreaInsets.trailing)
							.onTapGesture {
								withAnimation {
									self.currentItem = i
								}
							}
					}

					// TODO: un-magic this number
					Spacer()
						.frame(height: safeAreaInsets.bottom + 128)
				}
			}
			PlayerControlsView(
				onPlay: {},
				onPause: {},
				onNext: {
					withAnimation {
						currentItem = min(currentItem + 1, 10)
					}
				},
				onPrevious: {
					withAnimation {
						currentItem = max(currentItem - 1, 0)
					}
				})
		}
		.ignoresSafeArea()
		.background(Color(white: 0.98).ignoresSafeArea())
	}
}

struct PlaylistView_Previews: PreviewProvider {
	static var previews: some View {
		PlaylistView()
	}
}
