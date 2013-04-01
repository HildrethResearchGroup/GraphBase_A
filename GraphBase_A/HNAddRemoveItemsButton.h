//
//  HNAddRemoveItemsButton.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/11/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HNMenuItem;

@interface HNAddRemoveItemsButton : NSButton {

	NSMutableArray *menuItemArray;

}

//@property (assign, nonatomic, readwrite) IBOutlet id addCollectionsReciever;
@property (retain, strong, nonatomic) NSMutableArray *menuItemArray;




#pragma mark -
#pragma mark Menu Items
-(void) addMenuItem: (HNMenuItem *) newMenuItem atIndex: (NSInteger) index;
-(NSMenu *) addItemsMenu;
-(void) postNewAddOrRemoveNotificationOfType: (NSString *)notificationName withDetails: (NSDictionary *) userInfo;

@end
