//
//  HNTreeNode_Extension.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/6/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTreeNode (HNExtension)


-(NSArray *) descendants;
-(NSArray *) groupDescendants;
-(NSArray *) leafDescendants;
-(NSArray *) siblings;

-(BOOL) isDescendantOfNode: (NSTreeNode *) node;
-(BOOL) isSiblingOfNode: (NSTreeNode *) node;
-(BOOL) isSiblingOfOrDescendantOfNode: (NSTreeNode *) node;

-(NSIndexPath *) adjacentIndexPath;
-(NSIndexPath *) nextSiblingIndexPath;
-(NSIndexPath *) nextChildIndexPath;

@end
