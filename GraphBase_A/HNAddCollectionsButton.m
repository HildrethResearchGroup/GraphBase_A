//
//  HNAddCollectionsButton.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/15/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNAddCollectionsButton.h"
#import "HNNSNotificationStrings.h"
#import "HNMenuItem.h"

@implementation HNAddCollectionsButton

@synthesize menuItems = _menuItems;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMenuItems: [[NSMutableArray alloc] init]];
    }
    
    return self;
}




/*
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}
*/

-(void) addMenuItem: (HNMenuItem *) newMenuItem atIndex: (NSInteger) index {
    
    [newMenuItem setAction: @selector(menuItemClicked:)];
    
    if (!index ) {
		index = (int) [menuItems count] + 1;
	}
	
	[self.menuItems insertObject: newMenuItem atIndex: index];
}



-(void) addMenuItemWithDetails: (NSDictionary *) menuItemDetails {
	NSString *menuTitle = [menuItemDetails valueForKey: @"title"];
	
	if (!menuTitle) {
		return;
	}
	NSString *notificationType = [menuItemDetails valueForKey: @"notificationType"];
	NSDictionary *userInfo = [menuItemDetails valueForKey: @"userInfo"];
	NSString *keyEquivalent = [menuItemDetails valueForKey: @"keyEquivalent"];
	
	NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle: menuTitle action: @selector(menuItemClicked:) keyEquivalent:keyEquivalent];
	
	
	int index = (int) [menuItemDetails valueForKey: @"index"];
	// FIX - add fix for: if index is < [menuItems count]
	if (index < [menuItems count]) {
		for (int i = index; i <= index; ++i) {
			NSDictionary *nextMenuItemDictionary = [menuItems objectAtIndex: i];
			[nextMenuItemDictionary setValue: [NSNumber numberWithInt: index + 1] forKey: @"index"];
		}
	}
	
	if (!index ) {
		index = (int) [menuItems count] + 1;
	}
	
	
	NSDictionary *newMenuDictionary = @{ @"menuItem" : newMenuItem, @"notificationType" : notificationType, @"userInfo" : userInfo, @"index" : [NSNumber numberWithInt: index] };
	
	[self.menuItems insertObject: newMenuDictionary atIndex: index];
	
}


- (void)mouseDown:(NSEvent *)theEvent
{
    [self highlight:YES];
    NSEvent *click = [NSEvent mouseEventWithType:[theEvent type]
                                        location:[self frame].origin
                                   modifierFlags:[theEvent
                                                  modifierFlags]
                                       timestamp:[theEvent timestamp]
                                    windowNumber:[theEvent windowNumber]
                                         context:[theEvent context]
                                     eventNumber:[theEvent eventNumber]
                                      clickCount:[theEvent clickCount]
                                        pressure:[theEvent pressure]
                      ];
    
    NSMenu *popUpAddMenu = [self addItemsMenu];
    
    [NSMenu popUpContextMenu:popUpAddMenu withEvent:click forView:self];
}

-(void) mouseUp:(NSEvent *)theEvent {
    [self highlight: NO];
}


-(void) menuItemClicked: (id) sender {
	if (![sender isKindOfClass: [NSMenuItem class]]) {
		return;
	}
	
	// Get index of selected menuItem
	NSInteger index = [[sender menu] indexOfItem: sender];
	
	
	// Get notification information for menuItems array based upon index number
	NSDictionary *menuItemDictionary;
	if (index < [menuItems count]) {
		menuItemDictionary = [menuItems objectAtIndex: index];
	}
	// Check to make sure menuItemDictionary is for the correct menuItem
	if ( ![[menuItemDictionary objectForKey: @"menuItem"] isEqual: sender]) {
		
		// menuItemDiectionary is for the wrong menuItem
		// iterate through the menuItems array to find the correct
		for ( NSDictionary *nextMenuItemDictionary in menuItems) {
			if ([[nextMenuItemDictionary allKeysForObject: sender] count] > 0) {
				menuItemDictionary = nextMenuItemDictionary;
				break;
			}
		}
	}
	
	NSString *notificationType	= [menuItemDictionary objectForKey: @"notificationType"];
	NSDictionary *userInfo		= [menuItemDictionary objectForKey: @"userInfo"];
	
	if (notificationType && userInfo) {
		[self postNewAddOrRemoveNotificationOfType: notificationType withDetails:userInfo];
	}
}



#pragma mark -
#pragma mark Menu Items
// CHANGED

/*
-(NSMenu *)addItemsMenu {
    NSMenu *popUpAddMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [popUpAddMenu insertItemWithTitle:@"New Project"        action:@selector(addNewProject:)        keyEquivalent:@"" atIndex:0];
	[popUpAddMenu insertItemWithTitle:@"New Experiment"     action:@selector(addNewExperiment:)     keyEquivalent:@"" atIndex:1];
    [popUpAddMenu insertItemWithTitle:@"New Folder"			action:@selector(addNewCollection:)     keyEquivalent:@"" atIndex:2];
    [popUpAddMenu insertItemWithTitle:@"New Parse Template" action:@selector(addNewParseTemplate:)  keyEquivalent:@"" atIndex:3];
    [popUpAddMenu insertItemWithTitle:@"Add Data Files"     action:@selector(addNewData:)           keyEquivalent:@"" atIndex:4];
    [popUpAddMenu insertItemWithTitle:@"Add Graph Template" action:@selector(addNewGraphTemplate:)  keyEquivalent:@"" atIndex:5];
	[popUpAddMenu insertItemWithTitle:@"Add Watched Folder" action: nil   keyEquivalent:@"" atIndex:6];
    
    
    for (NSMenuItem *nextMenuItem in [popUpAddMenu itemArray]) {
        [nextMenuItem setEnabled: YES];
    }
	
	// Disable Add watched folder for now:
	[[popUpAddMenu itemWithTitle: @"Add Watched Folder"] setEnabled: NO];
    
    return popUpAddMenu;
}
*/


-(NSMenu *)addItemsMenu {
    NSMenu *popUpAddMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
	
	for (NSDictionary *nextMenuItemDictionary in [self menuItems]) {
		NSMenuItem *nextMenuItem = [nextMenuItemDictionary objectForKey: @"menuItem"];
		
		if (nextMenuItem) {
			[popUpAddMenu addItem: nextMenuItem];
		}
	}
	
	// Disable Add watched folder for now:
	[[popUpAddMenu itemWithTitle: @"Add Watched Folder"] setEnabled: NO];
    
    return popUpAddMenu;
}



-(IBAction) addNewProject: (id)sender {
	DLog(@"addNewProject from %@", [sender title]);
	[self highlight: NO];
	
	// Type of Collection = HNProjectCollectionType 
	NSDictionary *userInfo = @{ HNCollectionOfType : HNProjectCollectionType };
	
	[self postAddNewDataOrCollectionNotificationOfType: HNAddCollectionNotification
								 withCollectionDetails: userInfo];
}


-(IBAction)addNewExperiment:(id)sender {
    DLog(@"addNewExperiment");
    [self highlight: NO];
	
	// Type of Collection = HNExperimentCollectionType 
	NSDictionary *userInfo = @{ HNCollectionOfType : HNExperimentCollectionType };
	
	
	[self postAddNewDataOrCollectionNotificationOfType: HNAddCollectionNotification
								 withCollectionDetails: userInfo];
	
}


-(IBAction)addNewCollection:(id)sender {
    DLog(@"addNewCollection");
    [self highlight: NO];
	
	// Type of Collection = HNFolderCollectionType 
	NSDictionary *userInfo = @{ HNCollectionOfType : HNFolderCollectionType };
	
	
	[self postAddNewDataOrCollectionNotificationOfType: HNAddCollectionNotification
								 withCollectionDetails: userInfo];
    
}


- (IBAction)addNewData: (id)sender {
    DLog(@"addNewData");
    [self highlight: NO];

	// Type of Notification = HNAddDataFilesNotification
	// Source of Data		= HNAddFilesFromNSOpenPanel
	NSDictionary *userInfo = @{ HNaddFilesFrom : HNAddFilesFromNSOpenPanel };
	
	[self postAddNewDataOrCollectionNotificationOfType: HNAddDataFilesNotification
								 withCollectionDetails: userInfo];
    
    
}

- (IBAction)addNewGraphTemplate: (id)sender {
    DLog(@"addNewGraphTemplate");
    [self highlight: NO];
    
	// Type of Notification = HNAddGraphTemplateNotification
	// Soure of File		= HNAddFilesFromNSOpenPanel
	NSDictionary *userInfo = @{ HNaddFilesFrom: HNAddFilesFromNSOpenPanel };
	[self postAddNewDataOrCollectionNotificationOfType: HNAddGraphTemplateNotification withCollectionDetails: userInfo];
	
    
}


- (IBAction)addNewParseTemplate: (id)sender {
    DLog(@"addNewParseTemplate");
    [self highlight: NO];
    
	
    
}

-(IBAction) addNewWatchedFolder: (id)sender {
    
}


-(void) postAddNewDataOrCollectionNotificationOfType: (NSString *)notificationName withCollectionDetails: (NSDictionary *) userInfo{
	// use typeOfCollectinTo
	if (notificationName == nil) {
		return;
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName: notificationName
					  object: self
					userInfo: userInfo];
}


//
-(void) postNewAddOrRemoveNotificationOfType: (NSString *)notificationName withDetails: (NSDictionary *) userInfo {
	
	if (!notificationName) {
		return;
	}
	
	
	
}


@end	// @implementation HNAddCollectionsButton



