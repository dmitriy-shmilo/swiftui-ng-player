//
//  NGPlayerApp.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI
import AVKit

@main
struct NGPlayerApp: App {
	
	@StateObject
	private var currentPlaylist = PlaylistViewModel()
	
	@StateObject
	private var imageProvider = ImageProvider()
	
	init() {
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playback, mode: .default, options: [])
		} catch {
			print("Failed to set audio session category.")
		}
	}

	var body: some Scene {
		WindowGroup {
			NavigationView {
				HomeView()
			}
			.navigationViewStyle(StackNavigationViewStyle())
			.environmentObject(imageProvider)
			.environmentObject(currentPlaylist)
		}
	}
}


extension UIApplication {
	var keyWindow: UIWindow? {
		connectedScenes
			.compactMap {
				$0 as? UIWindowScene
			}
			.flatMap {
				$0.windows
			}
			.first {
				$0.isKeyWindow
			}
	}
}

private struct SafeAreaInsetsKey: EnvironmentKey {
	static var defaultValue: EdgeInsets {
		UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
	}
}

extension EnvironmentValues {
	var safeAreaInsets: EdgeInsets {
		self[SafeAreaInsetsKey.self]
	}
}

private extension UIEdgeInsets {
	var swiftUiInsets: EdgeInsets {
		EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
	}
}
