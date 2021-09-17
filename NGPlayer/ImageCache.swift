//
//  ImageCache.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI
import Combine

// TODO: id -> URL mapping
// TODO: persist on disk
// TODO: store decoded images
class ImageCache {
	private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
		let imageCache = NSCache<AnyObject, AnyObject>()
		imageCache.countLimit = 100
		return imageCache
	}()
	
	private var lock = NSLock()
	
	func addImage(_ image: UIImage?, for url: NSURL) {
		guard let image = image else {
			removeImage(for: url)
			return
		}
		
		lock.lock()
		
		imageCache.setObject(image, forKey: url)
		
		lock.unlock()
	}
	
	func removeImage(for url: NSURL) {
		lock.lock()
		
		imageCache.removeObject(forKey: url)
		
		lock.unlock()
	}
	
	func image(for url: NSURL) -> UIImage? {
		imageCache.object(forKey: url) as? UIImage
	}
}

class ImageProvider: ObservableObject {
	private var imageCache = ImageCache()

	func image(for url: URL?) -> AnyPublisher<UIImage?, Never> {
		guard let url = url else {
			return Just(nil)
				.eraseToAnyPublisher()
		}

		if let image = imageCache.image(for: NSURL(string: url.absoluteString)!) {
			return Just(image)
				.eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map { (data, response) in
				UIImage(data: data)
			}
			.catch({ err in
				Just(nil)
			})
			.handleEvents(receiveOutput: { [weak self] img in
				guard let img = img else {
					return
				}
				self?.imageCache.addImage(img, for: NSURL(string: url.absoluteString)!)
			})
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}
