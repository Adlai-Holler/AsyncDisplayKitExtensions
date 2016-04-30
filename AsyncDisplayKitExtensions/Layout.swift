//
//  Layout.swift
//  AsyncDisplayKitExtensions
//
//  Created by Adlai Holler on 4/30/16.
//  Copyright © 2016 Adlai Holler. All rights reserved.
//

import AsyncDisplayKit

public extension ASLayoutable {
	/// e.g. `myNode.withRatio(4/3)`
	public func withRatio(ratio: CGFloat) -> ASRatioLayoutSpec {
		return ASRatioLayoutSpec(ratio: ratio, child: self)
	}
	
	/// e.g. `myNode.withOverlay(myGradient)`
	public func withOverlay(overlay: ASLayoutable?) -> ASOverlayLayoutSpec {
		return ASOverlayLayoutSpec(child: self, overlay: overlay)
	}
	
	public func centeredWithOptions(centeringOptions: ASCenterLayoutSpecCenteringOptions, sizingOptions: ASCenterLayoutSpecSizingOptions) -> ASCenterLayoutSpec {
		return ASCenterLayoutSpec(centeringOptions: centeringOptions, sizingOptions: sizingOptions, child: self)
	}
	
	public func positionedRelativeWithHorizontalPosition(horizontalPosition: ASRelativeLayoutSpecPosition, verticalPosition: ASRelativeLayoutSpecPosition, sizingOption: ASRelativeLayoutSpecSizingOption) -> ASRelativeLayoutSpec {
		return ASRelativeLayoutSpec(horizontalPosition: horizontalPosition, verticalPosition: verticalPosition, sizingOption: sizingOption, child: self)
	}
	
	public func withBackground(background: ASLayoutable?) -> ASBackgroundLayoutSpec {
		return ASBackgroundLayoutSpec(child: self, background: background)
	}
	
	public func withInset(insets: UIEdgeInsets) -> ASInsetLayoutSpec {
		return ASInsetLayoutSpec(insets: insets, child: self)
	}
	
	/// Wrap this layoutable in a static spec so that you can set custom constraints. nil means `unconstrained`.
	public func withStatic(exactWidth exactWidth: ASRelativeDimension? = nil, exactHeight: ASRelativeDimension? = nil, layoutPosition: CGPoint? = nil) -> ASStaticLayoutSpec {
		return withStatic(minWidth: exactWidth ?? 0%, minHeight: exactHeight ?? 0%, maxWidth: exactWidth ?? 100%, maxHeight: exactHeight ?? 100%, layoutPosition: layoutPosition)
	}
	
	/// Wrap this layoutable in a static spec so that you can set custom constraints. nil means `no change`. Defaults are unconstrained (0% - 100% in both dimensions).
	public func withStatic(minWidth minWidth: ASRelativeDimension? = 0%, minHeight: ASRelativeDimension? = 0%, maxWidth: ASRelativeDimension? = 100%, maxHeight: ASRelativeDimension? = 100%, layoutPosition: CGPoint? = nil) -> ASStaticLayoutSpec {
		var sizeRange = self.sizeRange
		if let minWidth = minWidth {
			sizeRange.min.width = minWidth
		}
		if let minHeight = minHeight {
			sizeRange.min.height = minHeight
		}
		if let maxWidth = maxWidth {
			sizeRange.max.width = maxWidth
		}
		if let maxHeight = maxHeight {
			sizeRange.max.height = maxHeight
		}
		self.sizeRange = sizeRange
		if let layoutPosition = layoutPosition {
			self.layoutPosition = layoutPosition
		}
		return ASStaticLayoutSpec(children: [self])
	}
	
	public func spacing(before before: CGFloat? = nil, after: CGFloat? = nil) -> Self {
		if let before = before {
			self.spacingBefore = before
		}
		if let after = after {
			self.spacingAfter = after
		}
		return self
	}
	
	public func flex(basis basis: ASRelativeDimension? = nil, grow: Bool? = nil, shrink: Bool? = nil) -> Self {
		if let grow = grow {
			self.flexGrow = grow
		}
		if let shrink = shrink {
			self.flexShrink = shrink
		}
		if let basis = basis {
			self.flexBasis = basis
		}
		return self
	}
	
}
