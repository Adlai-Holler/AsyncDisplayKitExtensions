//
//  Nodes.swift
//  AsyncDisplayKitExtensions
//
//  Created by Adlai Holler on 4/30/16.
//  Copyright © 2016 Adlai Holler. All rights reserved.
//

import AsyncDisplayKit

public extension ASDisplayNode {
	
	/// The default argument values for `ASDisplayNode.configured`
	public struct Defaults {
		public static var layerBacked: Bool?
		public static var opaque: Bool?
		public static var backgroundColor: UIColor??
		public static var hitTestSlop: UIEdgeInsets?
	}
	
	/**
	A sequence containing all the ancestors of the given node, starting with its supernode.
	Usage: `for ancestor in ancestors { NSLog("Ancestor: \(ancestor)") }`
	*/
	public var ancestors: AnySequence<ASDisplayNode> {
		return AnySequence { () -> AnyGenerator<ASDisplayNode> in
			var current: ASDisplayNode? = self
			return anyGenerator {
				current = current?.supernode
				return current
			}
		}
	}

	/**
	Configure this node and then return it. nil means no change. For example, you might put this in your class:
	
	class MyCustomNode {
		let usernameNode = ASTextNode().configured(name: "usernameNode", layerBacked: false, opaque: true)
	}
	
	You can change the default argument values by modifying the `ASDisplayNode.Defaults` struct.
	Note that the defaults struct is not thread-safe so typically you set them once and then leave them alone.
	In order to get the best possible performance, you may set the defaults to `layerBacked: true, opaque: true, background: white` and then
	override them as needed for view-backed or transparent node,.
	*/
	public func configured(@autoclosure name name: () -> String? = nil, preferredFrameSize: CGSize? = nil, layerBacked: Bool? = Defaults.layerBacked, opaque: Bool? = Defaults.opaque, backgroundColor: UIColor?? = Defaults.backgroundColor, hitTestSlop: UIEdgeInsets? = Defaults.hitTestSlop) -> Self {
		if let layerBacked = layerBacked {
			self.layerBacked = layerBacked
		}
		if let backgroundColor = backgroundColor {
			self.backgroundColor = backgroundColor
		}
		if let opaque = opaque {
			self.opaque = opaque
		}
		if let preferredFrameSize = preferredFrameSize {
			self.preferredFrameSize = preferredFrameSize
		}
		if let hitTestSlop = hitTestSlop {
			self.hitTestSlop = hitTestSlop
		}
		#if DEBUG
			self.name = name()
		#endif
		return self
	}
}