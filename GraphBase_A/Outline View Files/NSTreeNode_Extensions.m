//
//  HNTreeNode_Extension.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/6/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"

@implementation NSTreeNode (HNExtension)


// returns an array of NSTreeNodes descending from self
- (NSArray *)descendants {
	NSMutableArray *array = [NSMutableArray array];
	for (NSTreeNode *child in [self childNodes]) {
		[array addObject:child];
		if (![child isLeaf])
			[array addObjectsFromArray:[child descendants]];
	}
	return [array copy];
}



- (NSArray *)groupDescendants {
	NSMutableArray *array = [NSMutableArray array];
	for (NSTreeNode *item in [self childNodes]) {
		if (![item isLeaf])	{
			[array addObject:item];
			[array addObjectsFromArray:[item groupDescendants]];
		}
	}
	return [array copy];
}



- (NSArray *)leafDescendants {
	NSMutableArray *array = [NSMutableArray array];
	for (NSTreeNode *item in [self childNodes]) {
		if ([item isLeaf])
			[array addObject:item];
		else
			[array addObjectsFromArray:[item leafDescendants]];
	}
	return [array copy];
}



// all the siblings, including self
- (NSArray *)siblings {
	return [[self parentNode] childNodes];
}



- (BOOL)isDescendantOfNode:(NSTreeNode *)node {
	return [[node descendants] containsObject:self];
}



- (BOOL)isSiblingOfNode:(NSTreeNode *)node {
	return ([self parentNode] == [node parentNode]);
}



- (BOOL)isSiblingOfOrDescendantOfNode:(NSTreeNode *)node {
	return ([self isSiblingOfNode:node] || [self isDescendantOfNode:node]);
}



// the next increasing index path
-(NSIndexPath *)adjacentIndexPath{
	return [[self indexPath] indexPathByIncrementingLastIndex];
}



// the next 'free' index path at the end of the children array of self's parent
- (NSIndexPath *)nextSiblingIndexPath {
	return [[[self parentNode] indexPath] indexPathByAddingIndex:[[[self parentNode] childNodes] count]];
}



- (NSIndexPath *)nextChildIndexPath {
	if ([self isLeaf])
		return [self nextSiblingIndexPath];
	return [[self indexPath] indexPathByAddingIndex:[[self childNodes] count]];
}


/*
#pragma mark -
#pragma mark Descendants and Siblings
// Returns an array containing ALL descendants
-(NSArray *) descendants {
	NSMutableArray *array = [NSMutableArray array];
	
	for (NSTreeNode *child in [self childNodes]) {
		[array addObject: child];
		if ( ![child isLeaf] ) {
			[array addObjectsFromArray: [child descendants]];
		}
	}
	
	return [array copy];
}

// Returns an array containing descendants that are NOT leafs
-(NSArray *) groupDescendants {
	NSMutableArray *array = [NSMutableArray array];
	for (NSTreeNode *item in [self childNodes]) {
		if ( ![item isLeaf] ) {
			[array addObject: item];
			[array addObjectsFromArray:[item groupDescendants]];
		}
	}
	return [array copy];
}


// Returnas an array containing all descendants that ARE leafs
-(NSArray *) leafDescendants {
	NSMutableArray *array = [NSMutableArray array];
	
	for (NSTreeNode *item in [self childNodes]) {
		if ( [item isLeaf]) {
			[array addObject: item];
		}
		else {
			[array addObjectsFromArray: [item leafDescendants]];
		}
	}
	
	return [array copy];
}



-(NSArray *) siblings {
	return [[self parentNode] childNodes];
}



#pragma mark -
#pragma mark Bool
-(BOOL) isDescendantOfNode: (NSTreeNode *) node {
	return [[node descendants] containsObject:self];
}



-(BOOL) isSiblingOfNode: (NSTreeNode *) node {
	return ([self parentNode] == [node parentNode]);
}



-(BOOL) isSiblingOfOrDescendantOfNode: (NSTreeNode *) node {
	return ( [self isSiblingOfNode: node] || [self isDescendantOfNode: node]);
}



#pragma mark -
#pragma mark NSIndexPath
-(NSIndexPath *) adjacentIndexPath {
	return [[self indexPath] indexPathByIncrementingLastIndex];
}



-(NSIndexPath *) nextSiblingIndexPath {
	NSIndexPath *path = [[[self parentNode] indexPath] indexPathByAddingIndex: [[[self parentNode] childNodes] count]];
	
	return path;
}


-(NSIndexPath *) nextChildIndexPath {
	if ( [self isLeaf]) {
		return [self nextSiblingIndexPath];
	}
	
	return [[self indexPath] indexPathByAddingIndex: [[self childNodes] count]];
}

*/

@end
