//
//  Types.swift
//  AsyncDisplayKitExtensions
//
//  Created by Adlai Holler on 4/30/16.
//  Copyright © 2016 Adlai Holler. All rights reserved.
//

import AsyncDisplayKit

postfix operator % {}

/// Enables constructs like `sizeRange.max.width = 100%`
public postfix func %(percent: CGFloat) -> ASRelativeDimension {
	// TODO: Is this necessary?
	if percent == 100 {
		return ASRelativeDimensionMakeWithPercent(1)
	}
	return ASRelativeDimensionMakeWithPercent(percent / 100)
}

/// Enables constructs like `sizeRange.max.width = 50.0`
extension ASRelativeDimension: FloatLiteralConvertible {
	public init(floatLiteral value: Double) {
		self = ASRelativeDimensionMakeWithPoints(CGFloat(value))
	}
}

/// Enables constructs like `sizeRange.max.width = 50`
extension ASRelativeDimension: IntegerLiteralConvertible {
	public init(integerLiteral value: Int) {
		self = ASRelativeDimensionMakeWithPoints(CGFloat(value))
	}
}

public extension ASRelativeSizeRange {
	/// e.g. `ASRelativeSizeRange(exactSize: mySize)`
	public init(exactSize: CGSize) {
		self = ASRelativeSizeRangeMakeWithExactCGSize(exactSize)
	}
	
	/// e.g. `ASRelativeSizeRange(exactWidth: 50, exactHeight: 100%)`
	public init(exactWidth: ASRelativeDimension, exactHeight: ASRelativeDimension) {
		self = ASRelativeSizeRangeMakeWithExactRelativeDimensions(exactWidth, exactHeight)
	}
	
	public init(relativeSize: ASRelativeSize) {
		self.init(min: relativeSize, max: relativeSize)
	}

}

public extension ASRelativeDimension {
	public init(percent: CGFloat) {
		self.type = .Percent
		self.value = percent
	}
	
	public init(points: CGFloat) {
		self.type = .Points
		self.value = points
	}
}
