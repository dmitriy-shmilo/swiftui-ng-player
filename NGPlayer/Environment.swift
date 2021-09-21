//
//  Environment.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 21.09.2021.
//

import SwiftUI

extension EnvironmentValues {
	var safeAreaInsets: EdgeInsets {
		self[SafeAreaInsetsKey.self]
	}
	
	var currentPlayerHeight: CGFloat {
		get {
			self[CurrentPlayerHeightKey.self]
		}
		set {
			self[CurrentPlayerHeightKey.self] = newValue
		}
	}
}

extension View {
	// propagate player height up the hierarchy
	func reportCurrentPlayerHeight(_ height: CGFloat) -> some View {
		return preference(key: CurrentPlayerHeightPreferenceKey.self, value: height)
	}
	
	// pass player height down the hierarchy
	func currentPlayerHeight(_ height: CGFloat) -> some View {
		return environment(\.currentPlayerHeight, height)
	}
	
	// react to reportCurrentPlayerHeight() call
	func onCurrentPlayerHeightChange(action: @escaping (CGFloat) -> Void) -> some View {
		onPreferenceChange(CurrentPlayerHeightPreferenceKey.self, perform: action)
	}
}

private struct CurrentPlayerHeightPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}

private struct CurrentPlayerHeightKey: EnvironmentKey {
	static var defaultValue: CGFloat = 0
}

private struct SafeAreaInsetsKey: EnvironmentKey {
	static var defaultValue: EdgeInsets {
		UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
	}
}

private extension UIEdgeInsets {
	var swiftUiInsets: EdgeInsets {
		EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
	}
}
