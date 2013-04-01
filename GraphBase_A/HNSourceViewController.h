//
//  HNSourceViewController.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/10/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "PreCompiledHeaders.h"

@class HNTreeController;
@class HNOutlineView;
@class HNAddRemoveItemsButton;
@class HNAddCollectionsButton;


@interface HNSourceViewController : NSObject <NSApplicationDelegate, NSTableViewDelegate> {
	
    IBOutlet    id  __unsafe_unretained datasource;
    IBOutlet    id  __unsafe_unretained delegate;
    
    // UI
	IBOutlet	HNOutlineView			*outlineView;
	IBOutlet	HNAddRemoveItemsButton	*button_addItems;
	IBOutlet	HNAddRemoveItemsButton  *button_removeItems;
	
	IBOutlet NSMenu *outlineViewContextMenu;
	IBOutlet NSMenu *expandableColumnMenu;
    IBOutlet NSMenuItem *deleteSelectedItemsMenuItem;

	
	
	NSMutableArray *_iconImages;
	
}

@property (unsafe_unretained) id delegate;
@property (unsafe_unretained) id datasource;

@property (retain, nonatomic) HNOutlineView		*outlineView;
@property (retain, nonatomic) HNAddRemoveItemsButton *button_addItems;
@property (retain, nonatomic) HNAddRemoveItemsButton *button_removeItems;
@property (retain, nonatomic) NSMenu *outlineViewContextMenu;

-(void) setAddButtonsMenuItems;
-(void) setRemoveButtonsMenuItems;
-(IBAction) addNewProjectNotification:(id) sender;

@end
