//
//  HNTreeNodeArrayController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/8/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNTreeNodeArrayController.h"
#import "HNCoreDataHeaders.h"

@implementation HNTreeNodeArrayController

/*
-(NSArray *) arrangeObjects:(NSArray *)objects {
    DLog(@"CALLED - HNTreeNodeArrayController: arrangeObjects");
    
    // FIX - need to add search string option
    
    NSMutableSet *filteredSet = [NSMutableSet set];
	
	
    
    for ( HNTreeNode *nextTreeNode in objects) {
        if ( [nextTreeNode isKindOfClass: [HNTreeNode class]]) {
			
            [filteredSet addObject: nextTreeNode];
			
			if ([nextTreeNode children]) {
				NSArray *allChildrenArray = [nextTreeNode allTreeNodeChildren];
				if (allChildrenArray) {
					[filteredSet addObjectsFromArray: allChildrenArray];
				}
			}
        }
        else {
            DLog(@"BAD: nextTreeNode class = %@", [nextTreeNode class]);
        }
    }
    
    
    
    NSArray *filteredArray = [filteredSet allObjects];
    
    DLog(@"\n\nfilteredSet =");
    for (HNTreeNode *nextTreeNode in filteredArray) {
        DLog(@"%@",nextTreeNode.displayName);
    }
    DLog(@"\n\n");
    
    return [super arrangeObjects: filteredArray];

}
 */

@end
