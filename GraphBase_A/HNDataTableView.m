//
//  HNDataTableView.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/20/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNDataTableView.h"
#import "HNNSNotificationStrings.h"
#import "PreCompiledHeaders.h"

@implementation HNDataTableView




#pragma mark -
#pragma mark Keyboard Handling
-(void) keyDown:(NSEvent *)theEvent {
	DLog(@"CALLED - HNDataTableView:  keyDown");
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
	// NOTE: This method and class assumes that there is an NSArrayController datasource and the object controller is set to Entity Mode
	
	// Get selected Row
	NSInteger selectedRow = [self selectedRow];
	
	if (selectedRow == -1) {
		NSBeep();
		return;
	}
	
	// CHANGED
	/*
	// check datasource and get the type of entity it represents
	if (!self.dataSource) {
		DLog(@"ERROR - no datasource for tableview");
		return;
	}
	else if ( ![self.dataSource isKindOfClass: [NSArrayController class]] ) {
		DLog(@"ERROR - tableView datasource is not an NSArrayController.  Do not use an HNDataTable");
		return;
	}
	 */
	
	// Get Entity Name from TableView identifier
		// Note, must be formated at tableviewName<entityName
	NSString *representedEntityName = [[NSString string] entityNameFromIdentifier: self.identifier];
	
	if (!representedEntityName) {
		DLog(@"ERROR - tableview does not have an entityName");
		return;
	}
	
	// set notificationName based upon type of Entity that Array Controller holds
		// Create dictionary to hold notification names
	NSDictionary *notificationNames = @{ @"HNDataItem" : HNRemoveDataFilesNotification, @"HNTreeNode" : HNRemoveCollectionNotification, @"HNGraphTemplate" : HNRemoveGraphTemplateNotification, @"HNParseTemplate" : HNRemoveParseTemplateNotification};
	
	
	
	NSString *notificationName = [notificationNames objectForKey: representedEntityName];
	
	if (!notificationName) {
		DLog(@"ERROR - no notificaitonName.  Tableview does know the type of data to delete");
		return;
	}
	
	if (notificationName) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		NSDictionary *userInfo = [NSDictionary dictionary];
		[nc postNotificationName: notificationName
						  object: self
						userInfo: userInfo];
	}
}

@end

