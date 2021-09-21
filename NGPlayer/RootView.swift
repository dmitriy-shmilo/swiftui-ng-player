//
//  RootView.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 21.09.2021.
//

import SwiftUI

struct RootView: View {
	@StateObject
	private var currentPlaylist = PlaylistViewModel()
	
	@StateObject
	private var imageProvider = ImageProvider()
	
	@State
	private var currentPlayerHeight: CGFloat = 0
	
	var body: some View {
		ZStack(alignment: .bottom) {
			NavigationView {
				HomeView()
			}
			.navigationViewStyle(StackNavigationViewStyle())
			
			if currentPlaylist.hasSongs {
				PlayerControlsView()
					.background(GeometryReader { proxy in })
			}
		}
		.onCurrentPlayerHeightChange { height in
			currentPlayerHeight = height
		}
		.currentPlayerHeight(currentPlayerHeight)
		.ignoresSafeArea()
		.environmentObject(imageProvider)
		.environmentObject(currentPlaylist)
	}
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
