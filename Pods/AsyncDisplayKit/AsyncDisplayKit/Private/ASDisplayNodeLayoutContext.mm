//
//  ASDisplayNodeLayoutContext.mm
//  AsyncDisplayKit
//
//  Created by Huy Nguyen on 3/8/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "ASDisplayNodeLayoutContext.h"

#import "ASDisplayNode.h"
#import "ASDisplayNodeInternal.h"
#import "ASDisplayNode+Subclasses.h"
#import "ASLayout.h"

#import <vector>

#import "NSArray+Diffing.h"
#import "ASEqualityHelpers.h"

@implementation ASDisplayNodeLayoutContext {
  ASDN::RecursiveMutex _propertyLock;
  BOOL _calculatedSubnodeOperations;
  NSArray<ASDisplayNode *> *_insertedSubnodes;
  NSArray<ASDisplayNode *> *_removedSubnodes;
  std::vector<NSUInteger> _insertedSubnodePositions;
  std::vector<NSUInteger> _removedSubnodePositions;
}

- (instancetype)initWithNode:(ASDisplayNode *)node
               pendingLayout:(ASLayout *)pendingLayout
      pendingConstrainedSize:(ASSizeRange)pendingConstrainedSize
              previousLayout:(ASLayout *)previousLayout
     previousConstrainedSize:(ASSizeRange)previousConstrainedSize
{
  self = [super init];
  if (self) {
    _node = node;
    _pendingLayout = pendingLayout;
    _pendingConstrainedSize = pendingConstrainedSize;
    _previousLayout = previousLayout;
    _previousConstrainedSize = previousConstrainedSize;
  }
  return self;
}

- (void)applySubnodeInsertions
{
  ASDN::MutexLocker l(_propertyLock);
  [self calculateSubnodeOperationsIfNeeded];
  for (NSUInteger i = 0; i < [_insertedSubnodes count]; i++) {
    NSUInteger p = _insertedSubnodePositions[i];
    [_node insertSubnode:_insertedSubnodes[i] atIndex:p];
  }
}

- (void)applySubnodeRemovals
{
  ASDN::MutexLocker l(_propertyLock);
  [self calculateSubnodeOperationsIfNeeded];
  for (NSUInteger i = 0; i < [_removedSubnodes count]; i++) {
    [_removedSubnodes[i] removeFromSupernode];
  }
}

- (void)calculateSubnodeOperationsIfNeeded
{
  ASDN::MutexLocker l(_propertyLock);
  if (_calculatedSubnodeOperations) {
    return;
  }
  if (_previousLayout) {
    NSIndexSet *insertions, *deletions;
    [_previousLayout.immediateSublayouts asdk_diffWithArray:_pendingLayout.immediateSublayouts
                                                 insertions:&insertions
                                                  deletions:&deletions
                                               compareBlock:^BOOL(ASLayout *lhs, ASLayout *rhs) {
                                                 return ASObjectIsEqual(lhs.layoutableObject, rhs.layoutableObject);
                                               }];
    findNodesInLayoutAtIndexes(_pendingLayout, insertions, &_insertedSubnodes, &_insertedSubnodePositions);
    findNodesInLayoutAtIndexesWithFilteredNodes(_previousLayout,
                                                      deletions,
                                                      _insertedSubnodes,
                                                      &_removedSubnodes,
                                                      &_removedSubnodePositions);
  } else {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_pendingLayout.immediateSublayouts count])];
    findNodesInLayoutAtIndexes(_pendingLayout, indexes, &_insertedSubnodes, &_insertedSubnodePositions);
    _removedSubnodes = nil;
  }
  _calculatedSubnodeOperations = YES;
}

#pragma mark - _ASTransitionContextDelegate

- (NSArray<ASDisplayNode *> *)currentSubnodesWithTransitionContext:(_ASTransitionContext *)context
{
  ASDN::MutexLocker l(_propertyLock);
  return _node.subnodes;
}

- (NSArray<ASDisplayNode *> *)insertedSubnodesWithTransitionContext:(_ASTransitionContext *)context
{
  ASDN::MutexLocker l(_propertyLock);
  [self calculateSubnodeOperationsIfNeeded];
  return _insertedSubnodes;
}

- (NSArray<ASDisplayNode *> *)removedSubnodesWithTransitionContext:(_ASTransitionContext *)context
{
  ASDN::MutexLocker l(_propertyLock);
  [self calculateSubnodeOperationsIfNeeded];
  return _removedSubnodes;
}

- (ASLayout *)transitionContext:(_ASTransitionContext *)context layoutForKey:(NSString *)key
{
  ASDN::MutexLocker l(_propertyLock);
  if ([key isEqualToString:ASTransitionContextFromLayoutKey]) {
    return _previousLayout;
  } else if ([key isEqualToString:ASTransitionContextToLayoutKey]) {
    return _pendingLayout;
  } else {
    return nil;
  }
}

- (ASSizeRange)transitionContext:(_ASTransitionContext *)context constrainedSizeForKey:(NSString *)key
{
  ASDN::MutexLocker l(_propertyLock);
  if ([key isEqualToString:ASTransitionContextFromLayoutKey]) {
    return _previousConstrainedSize;
  } else if ([key isEqualToString:ASTransitionContextToLayoutKey]) {
    return _pendingConstrainedSize;
  } else {
    return ASSizeRangeMake(CGSizeZero, CGSizeZero);
  }
}

#pragma mark - Filter helpers

/**
 * @abstract Stores the nodes at the given indexes in the `storedNodes` array, storing indexes in a `storedPositions` c++ vector.
 */
static inline void findNodesInLayoutAtIndexes(ASLayout *layout,
                                              NSIndexSet *indexes,
                                              NSArray<ASDisplayNode *> * __strong *storedNodes,
                                              std::vector<NSUInteger> *storedPositions)
{
  findNodesInLayoutAtIndexesWithFilteredNodes(layout, indexes, nil, storedNodes, storedPositions);
}

/**
 * @abstract Stores the nodes at the given indexes in the `storedNodes` array, storing indexes in a `storedPositions` c++ vector.
 * @discussion If the node exists in the `filteredNodes` array, the node is not added to `storedNodes`.
 */
static inline void findNodesInLayoutAtIndexesWithFilteredNodes(ASLayout *layout,
                                                               NSIndexSet *indexes,
                                                               NSArray<ASDisplayNode *> *filteredNodes,
                                                               NSArray<ASDisplayNode *> * __strong *storedNodes,
                                                               std::vector<NSUInteger> *storedPositions)
{
  NSMutableArray<ASDisplayNode *> *nodes = [NSMutableArray array];
  std::vector<NSUInteger> positions = std::vector<NSUInteger>();
  NSUInteger idx = [indexes firstIndex];
  while (idx != NSNotFound) {
    ASDisplayNode *node = (ASDisplayNode *)layout.immediateSublayouts[idx].layoutableObject;
    ASDisplayNodeCAssert(node, @"A flattened layout must consist exclusively of node sublayouts");
    // Ignore the odd case in which a non-node sublayout is accessed and the type cast fails
    if (node != nil) {
      BOOL notFiltered = (filteredNodes == nil || [filteredNodes indexOfObjectIdenticalTo:node] == NSNotFound);
      if (notFiltered) {
        [nodes addObject:node];
        positions.push_back(idx);
      }
    }
    idx = [indexes indexGreaterThanIndex:idx];
  }
  *storedNodes = nodes;
  *storedPositions = positions;
}

@end
