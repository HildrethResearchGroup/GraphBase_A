//
//  NSTreeConroller_Extensions.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/6/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTreeController (HNExtensions)

-(NSIndexPath *) indexPathForInsertion;
-(void) selectNone;
-(NSArray *) rootNodes;
-(NSTreeNode *) nodeAtIndexPath: (NSIndexPath *) indexPath;
-(NSArray *) flattenedContent;
-(NSArray *) flattenedNodes;
-(NSTreeNode *) treeNodeForObject:(id)object;
-(NSTreeNode *) nextSiblingOfNodeAtIndexPath: (NSIndexPath *) indexPath;
-(NSTreeNode *) nextSiblingOfNode: (NSTreeNode *) node;
-(void) selectParentFromSelection;


@end
