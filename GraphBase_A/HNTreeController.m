//
//  HNTreeController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/5/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNTreeController.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"

@interface HNTreeController (Private)
-(void) updateSortOrderOfModelObjects;
@end


@implementation HNTreeController (Private)
-(void) updateSortOrderOfModelObjects {
	for (NSTreeNode *node in [self flattenedNodes])
		[[node representedObject] setValue:[NSNumber numberWithInteger:[[node indexPath] lastIndex]] forKey:@"sortIndex"];
}


@end


@implementation  HNTreeController

- (void)insertObject:(id)object atArrangedObjectIndexPath:(NSIndexPath *)indexPath
{
	[super insertObject:object atArrangedObjectIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}

- (void)insertObjects:(NSArray *)objects atArrangedObjectIndexPaths:(NSArray *)indexPaths
{
	[super insertObjects:objects atArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
}

- (void)removeObjectAtArrangedObjectIndexPath:(NSIndexPath *)indexPath
{
	[super removeObjectAtArrangedObjectIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}

- (void)removeObjectsAtArrangedObjectIndexPaths:(NSArray *)indexPaths
{
	[super removeObjectsAtArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
}

- (void)moveNode:(NSTreeNode *)node toIndexPath:(NSIndexPath *)indexPath
{
	[super moveNode:node toIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}

- (void)moveNodes:(NSArray *)nodes toIndexPath:(NSIndexPath *)indexPath
{
	[super moveNodes:nodes toIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}




@end