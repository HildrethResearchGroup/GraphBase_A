#import "HNAddRemoveItemsButton.h"
#import "HNNSNotificationStrings.h"
#import "HNMenuItem.h"

@implementation HNAddRemoveItemsButton

@synthesize menuItemArray;

- (id)initWithFrame:(NSRect)frame {
	//DLog(@"CALLED - HNAddRemoveItemsButton: initWithFrame");
	
    self = [super initWithFrame:frame];
    if (self) {
        self.menuItemArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) awakeFromNib {
	//DLog(@"CALLED - HNAddRemoveItemsButton: awakeFromNib");
	if (self) {
        self.menuItemArray = [[NSMutableArray alloc] init];
    }
}




/*
 - (void)drawRect:(NSRect)dirtyRect
 {
 // Drawing code here.
 }
 */

-(void) addMenuItem: (HNMenuItem *) newMenuItem atIndex: (NSInteger) index {
	//DLog(@"CALLED - HNAddRemoveItemsButton: addMenuItem");
	if (!index) {
		index = [menuItemArray count];
	}
	//DLog(@"title = %@", [newMenuItem title]);
	
	if (!self.menuItemArray) {
		DLog(@"NO menuItemarray");
	}

	//[newMenuItem setAction: @selector(menuItemClicked:)];
    [self setMenuAction: newMenuItem];
    
	[self.menuItemArray addObject: newMenuItem];

	
	//DLog(@"menuItems count = %lu", [self.menuItemArray count]);
}

-(void) setMenuAction: (HNMenuItem *) menuItemIn {
    NSMenu *subMenu = [menuItemIn submenu];
    
    if (subMenu) {
        DLog(@"submenu exists = %lu", [subMenu numberOfItems]);
        NSArray *menuItemsFromSubMenu = [subMenu itemArray];
        DLog(@"menuItemsFromSeubMenu = %@", menuItemsFromSubMenu);
        for (HNMenuItem *nextMenuItem in menuItemsFromSubMenu) {
            DLog(@"nextMenuItem = %@", [nextMenuItem title]);
            [nextMenuItem setAction: @selector(menuItemClicked:)];
            [self setMenuAction: nextMenuItem];
        }
    }
    else {
        [menuItemIn setAction: @selector(menuItemClicked:)];
    }
}




- (void)mouseDown:(NSEvent *)theEvent
{
	//DLog(@"CALLED - HNAddRemoveItemsButton: mouseDown");
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
	
	// Disable Add watched folder for now:
	[[popUpAddMenu itemWithTitle: @"Add Watched Folder"] setEnabled: NO];
}

-(void) mouseUp:(NSEvent *)theEvent {
    [self highlight: NO];
}


-(void) menuItemClicked: (id) sender {
	//DLog(@"CALLED - HNAddRemoveItemsButton: menuItemClicked");
	if (![sender isKindOfClass: [NSMenuItem class]]) {
		return;
	}
	
	if ( ![sender isKindOfClass: [HNMenuItem class]] ) {
		// sender is wrong type of class
		return;
	}
	
	HNMenuItem *selectedMenuItem = sender;
	
	NSDictionary *userInfo = selectedMenuItem.userInfo;
	NSString *notificationType = selectedMenuItem.notificationType;
	
	if (notificationType && userInfo) {
		[self postNewAddOrRemoveNotificationOfType: notificationType withDetails:userInfo];
	}
	[self highlight: NO];
}




#pragma mark -
#pragma mark Menu Items
-(NSMenu *)addItemsMenu {
	//DLog(@"CALLED - HNAddRemoveItemsButton: addItemsMenu");
    NSMenu *popUpAddMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
	//DLog(@"menuItems count = %lu", [self.menuItemArray count]);
	
	for (HNMenuItem *nextMenuItem in [self menuItemArray]) {
		if ([nextMenuItem isKindOfClass: [HNMenuItem class]]) {
			[popUpAddMenu addItem: nextMenuItem];
		}
		else {
			DLog(@"No nextMenuitem");
		}
	}
    
	
	//DLog(@"popUpaddMenu size = %lu", [[popUpAddMenu itemArray] count]);
	
	// Disable Add watched folder for now:
	[[popUpAddMenu itemWithTitle: @"Add Watched Folder"] setEnabled: NO];
    
    return popUpAddMenu;
}


//
-(void) postNewAddOrRemoveNotificationOfType: (NSString *)notificationName withDetails: (NSDictionary *) userInfo {
	
	if (!notificationName) {
		return;
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName: notificationName
					  object: self
					userInfo: userInfo];
}


@end	// @implementation HNAddCollectionsButton