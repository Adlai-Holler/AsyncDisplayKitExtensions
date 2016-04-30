//
//  Collections.swift
//  AsyncDisplayKitExtensions
//
//  Created by Adlai Holler on 4/30/16.
//  Copyright © 2016 Adlai Holler. All rights reserved.
//

import AsyncDisplayKit

public extension ASTableView {
	
	/// Create and return a sequence of nodes and index paths in this table view.
	public var nodes: AnySequence<(indexPath: NSIndexPath, node: ASCellNode)> {
		return AnySequence { () -> AnyGenerator<(indexPath: NSIndexPath, node: ASCellNode)> in
			let indexPathGenerator = self.indexPaths.generate()
			return anyGenerator {
				indexPathGenerator.next().flatMap { ($0, self.nodeForRowAtIndexPath($0)) }
			}
		}
	}
}

public extension ASCollectionView {
	
	/// Create and return a sequence of nodes and index paths in this collection view.
	/// e.g. `for (indexPath, node) in collectionView.nodes`
	public var nodes: AnySequence<(indexPath: NSIndexPath, node: ASCellNode)> {
		return AnySequence { () -> AnyGenerator<(indexPath: NSIndexPath, node: ASCellNode)> in
			let indexPathGenerator = self.indexPaths.generate()
			return anyGenerator {
				indexPathGenerator.next().flatMap { ($0, self.nodeForItemAtIndexPath($0)) }
			}
		}
	}
	
}

public extension UITableView {
	/// Create and return a sequence of valid index paths (ascending) in this table view.
	public var indexPaths: AnySequence<NSIndexPath> {
		return AnySequence {
			anyGeneratorWithHierarchy(numSections: self.numberOfSections, numberOfItemsInSection: self.numberOfRowsInSection)
		}
	}
}

public extension UICollectionView {
	/// Create and return a sequence of valid index paths (ascending) in this collection view.
	public var indexPaths: AnySequence<NSIndexPath> {
		return AnySequence {
			anyGeneratorWithHierarchy(numSections: self.numberOfSections(), numberOfItemsInSection: self.numberOfItemsInSection)
		}
	}
}

/// FIXME: When compiler supports it, make this a convenience initializer/static func
func anyGeneratorWithHierarchy(numSections numSections: Int, numberOfItemsInSection: (Int) -> Int) -> AnyGenerator<NSIndexPath> {
	var section = -1
	var numRowsInCurrentSection = 0
	var row = 0
	return anyGenerator { () -> NSIndexPath? in
		// Advance to next section if needed.
		if row >= numRowsInCurrentSection {
			section += 1
			row = 0
			numRowsInCurrentSection = section < numSections ? numberOfItemsInSection(section) : 0
		}
		// If no more sections, we're done.
		if section >= numSections {
			return nil
		}
		return NSIndexPath(forRow: row, inSection: section)
	}
}

public extension Int {
	public func validateInPager(pager: ASPagerNode) -> Int? {
		let indexPath = NSIndexPath(forItem: self, inSection: 0)
		return indexPath.validateInCollectionView(pager.view)?.item
	}
}

public extension NSIndexPath {
	public func validateInTableView(tableView: UITableView) -> NSIndexPath? {
		assert(NSThread.isMainThread())
		if tableView.numberOfSections > section && tableView.numberOfRowsInSection(section) > item {
			return self
		} else {
			return nil
		}
	}
	
	public func validateInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
		assert(NSThread.isMainThread())
		if collectionView.numberOfSections() > section && collectionView.numberOfItemsInSection(section) > item {
			return self
		} else {
			return nil
		}
	}
}