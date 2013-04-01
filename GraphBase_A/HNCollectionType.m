//
//  HNCollectionType.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 11/14/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNCollectionType.h"
#import "HNTreeNode.h"


@implementation HNCollectionType

@dynamic displayName;
@dynamic typeName;
@dynamic treeNodes;

-(NSString *) displayName {
    //DLog(@"CALLED - HNCollectionType: displayName");
    
    return self.typeName;
}

@end
