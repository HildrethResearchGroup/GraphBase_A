//
//  HNTreeNode.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/8/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNTreeNode.h"
#import "HNDataItem.h"
#import "HNGraphTemplate.h"
#import "HNParseTemplate.h"


@implementation HNTreeNode

@synthesize keys;

@dynamic dateCreated;
@dynamic dateLastModified;
@dynamic displayName;
@dynamic isLeaf;
@dynamic isSelectable;
@dynamic sortIndex;
@dynamic canCollapse;
@dynamic canExpand;
@dynamic collectionType;
@dynamic isExpanded;
@dynamic isSpecialGroup;
@dynamic children;
@dynamic parent;
@dynamic dataItems;
@dynamic defaultGraphTemplate;
@dynamic defaultParseTemplate;
@dynamic graphTemplates;
@dynamic parseTemplates;
@dynamic storedUUID;

@dynamic allDataItems;
@dynamic allGraphTemplates;


// Some values should not have any setter methods.  Overwrite setValue: forKey: for:
// allDataItems, allTreeNodeChildren, allGraphTemplates, allParseTemplates
-(void) setValue:(id)value forKey:(NSString *)key {
	
	if ([key isEqualToString: @"allDataItems"]) {
		DLog(@"tried to set allDataItems");
	}
	else if ([key isEqualToString: @"allGraphTemplates"]) {
		DLog(@"tried to set allGraphTemplates");
	}
	else if ([key isEqualToString: @"allParseTemplates"]) {
		DLog(@"tried to set allParseTemplates");
	}
	else if ([key isEqualToString: @"allTreeNodeChildren"]) {
		DLog(@"tried to set allTreeNodeChildren");
	}
	else {
		[super setValue: value forKey:key];
	}
}


-(void) awakeFromInsert {
	
	[self setDateCreated: [NSDate date]];
	[self setDateLastModified: [NSDate date]];
	[self setIsLeaf: [NSNumber numberWithBool: NO]];
	
	NSString *UUID = [[NSProcessInfo processInfo] globallyUniqueString];
	[self setStoredUUID: UUID];
}


-(BOOL) setDefaultsFromParent {
	BOOL status = YES;
	
	// check to make sure parent tree node exists
	if (![self parent]) {
		status = NO;
		return status;
	}
	
	[self _setDefaultsFromTreeNode: [self parent]];
	
	return status;
}

-(void) _setDefaultsFromTreeNode: (HNTreeNode *) treeNodeIn {
    [self setDefaultGraphTemplate:     [treeNodeIn defaultGraphTemplate]];
    [self setDefaultParseTemplate:     [treeNodeIn defaultParseTemplate]];
}




-(NSArray *) allTreeNodeChildren {
	//DLog(@"CALLED - allTreeNodeChildren");
	
	NSMutableSet *set = [[NSMutableSet alloc] init];
	
	[set addObject: self];
	
	if ([self children]) {
		for (HNTreeNode *nextTreeNode in [self children]) {
			[set addObject: nextTreeNode];
			if ([[nextTreeNode allTreeNodeChildren] isKindOfClass: [NSArray class]]) {
				[set addObjectsFromArray: [nextTreeNode allTreeNodeChildren]];
			}
		}
	}
	
	NSArray *returnArray = [set allObjects];
	
	//DLog(@"FINISHED - allTreeNodeChildren");
	
	return returnArray;
}



-(NSSet *) allDataItems {
	//DLog(@"CALLED - HNTreeNode: allDataItems");

	
	NSArray *treeNodeArray = [self allTreeNodeChildren];
	
	NSMutableSet *allDataItemSet = [NSMutableSet set];
	
	for (HNTreeNode *nextTreeNode in treeNodeArray) {

		NSSet *nextDataItemSet = [nextTreeNode dataItems];
			
		if (nextDataItemSet) {
			[allDataItemSet unionSet: nextDataItemSet];
		}
	}
	
	
	NSSet *returnSet = [NSSet setWithSet: allDataItemSet];
	
	//DLog(@"FINISHED - allDataItems");
	
	return returnSet;
	
}


// EMPTY methods
-(void) addAllDataItems: (NSSet *) values {
	DLog(@"CALLED - HNTreeNode: addAllDataItems");
}


-(void) removeAllDataItems: (NSSet *) values {
	DLog(@"CALLED - HNTreeNode: removeAllDataItems");
}

-(void) addAllDataItemsObject: (HNDataItem *) value {
	DLog(@"CALLED - HNTreeNode: addAllDataItemsObject");
}

-(void) removeAllDataItemsObject: (HNDataItem *) value {
	
}


-(NSSet *) allGraphTemplates {
	//DLog(@"CALLED - HNTreeNode: allGraphTemplates");
	
	NSArray *treeNodeArray = [self allTreeNodeChildren];
	
	NSMutableSet *allGraphTemplatesSet = [NSMutableSet set];
	
	for (HNTreeNode *nextTreeNode in treeNodeArray) {
		NSSet *nextGraphTemplateSet = [nextTreeNode graphTemplates];
		
		// Don't add if nextGraphTemplateSet is empty
		if ([nextGraphTemplateSet count] > 0) {
			[allGraphTemplatesSet unionSet: nextGraphTemplateSet];
		}
	}
	
	//DLog(@"[allGraphTemplates count] = %lu", [[allGraphTemplatesSet allObjects] count]);
	//DLog(@"%@", allGraphTemplatesSet);
	
	// Return NSSet copy of allGraphTemplatesSet
	return [NSSet setWithSet: allGraphTemplatesSet];
}
-(void) setAllGraphTemplates {
	DLog(@"CALLED - HNTreeNode: setAllGraphTemplates");
}


-(NSSet *) allParseTemplates {
	//DLog(@"CALLED - HNTreeNode: allParseTemplates");
	
	NSArray *treeNodeArray = [self allTreeNodeChildren];
	
	NSMutableSet *allParseTemplatesSet = [NSMutableSet set];
	
	for (HNTreeNode *nextTreeNode in treeNodeArray) {
		NSSet *nextParseTemplateSet = [nextTreeNode parseTemplates];
		
		// Don't add if nextParseTemplateSet is empty
		if ([nextParseTemplateSet count] > 0) {
			[allParseTemplatesSet unionSet: nextParseTemplateSet];
		}
	}
	
	// Return NSSet copy of allParseTemplatesSet
	return [NSSet setWithSet: allParseTemplatesSet];
}


@end
