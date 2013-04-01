//
//  HNOutlineView.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/5/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNOutlineView.h"
#import "HNNSNotificationStrings.h"
#import "HNTreeController.h"

@implementation HNOutlineView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



-(void) reloadData {
	[super reloadData];
	NSUInteger row;
	
	for (row = 0; row < [self numberOfRows]; ++row) {
		NSTreeNode *item = [self itemAtRow:row];
		bool itemShouldExpand = NO;
		
		if ( [[item representedObject] respondsToSelector:@selector(isExpanded)]) {
			itemShouldExpand = [[[item representedObject] valueForKey:@"isExpanded"] boolValue];
		}
		
		if (![item isLeaf] && itemShouldExpand ) {
			[self expandItem:item];
		}
	}
}




#pragma mark -
#pragma mark Keyboard Handling
-(void) keyDown:(NSEvent *)theEvent {
	//DLog(@"CALLED - HNOutlineView:  keyDown");
	// Based on:
	// http://stackoverflow.com/questions/4668847/nstableview-delete-key
	
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex: 0];
	
	if (key == NSDeleteFunctionKey) {
		if ([self selectedRow] == -1) {
			NSBeep();
		}
		
		BOOL isEditing = ([[self.window firstResponder] isKindOfClass:[NSText class]]);
		
		if (!isEditing) {
			[self postDeleteNotification];
		}
	}
	
	else {
		[super keyDown: theEvent];
	}
}


-(void) postDeleteNotification {
	// NOTE: This method and class assumes that there is an HNTreeController datasource and the object controller is set to Entity Mode
	
	// Get selected Row
	NSInteger selectedRow = [self selectedRow];
	
	if (selectedRow == -1) {
		NSBeep();
		return;
	}
	
	
	// check datasource and get the type of entity it represents
	if (!self.dataSource) {
		DLog(@"ERROR - no datasource for tableview");
		return;
	}
	else if ( ![self.dataSource isKindOfClass: [HNTreeController class]] ) {
		DLog(@"ERROR - outlineView datasource is not an NSArrayController.  Do not use an HNDataTable");
		return;
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *userInfo = [NSDictionary dictionary];
	[nc postNotificationName: HNRemoveCollectionNotification
					  object: self
					userInfo: userInfo];
}


@end
