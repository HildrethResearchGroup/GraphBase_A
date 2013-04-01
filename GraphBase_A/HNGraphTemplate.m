//
//  HNGraphTemplate.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/8/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNGraphTemplate.h"
#import "HNDataItem.h"
#import "HNTreeNode.h"


@implementation HNGraphTemplate

@dynamic dateImported;
@dynamic dateLastModified;
@dynamic displayName;
@dynamic fileName;
@dynamic filePath;
@dynamic storedUUID;

@dynamic treeNodes;
@dynamic dataItems;
@dynamic defaultGraphForCollections;


-(void) awakeFromInsert {
	// Set initial dates
	[self setDateImported:      [NSDate date]];
    [self setDateLastModified:  [NSDate date]];
	
	NSString *UUID = [[NSProcessInfo processInfo] globallyUniqueString];
	[self setStoredUUID: UUID];
}

-(NSString *) fileName {
    if ([self filePath] == nil) {
        return @"Unknown File Name";
    }
    
    return [[self filePath] lastPathComponent];
}


-(void) setDateLastModified:(NSDate *)dateLastModified {
	dateLastModified = [NSDate date];
}

@end
