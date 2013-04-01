//
//  HNAddCollectionsButton.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/15/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HNSourceViewController;
@class HNMenuItem;

@interface HNAddCollectionsButton : NSButton {
	
	NSMutableArray *menuItems;
	
}

@property (assign, nonatomic, readwrite) IBOutlet id addCollectionsReciever;
@property (retain, nonatomic) NSMutableArray *menuItems;




#pragma mark -
#pragma mark Menu Items
- (NSMenu *)addItemsMenu;
-(void) addMenuItem: (HNMenuItem *) newMenuItem atIndex: (NSInteger) index;
- (IBAction)addNewProject: (id)sender;
- (IBAction)addNewExperiment: (id)sender;
- (IBAction)addNewCollection: (id)sender;
- (IBAction)addNewData: (id)sender;
- (IBAction)addNewGraphTemplate: (id)sender;
- (IBAction)addNewParseTemplate: (id)sender;
- (IBAction)addNewWatchedFolder: (id)sender;


-(void) postAddNewDataOrCollectionNotificationOfType: (NSString *)notificationName withCollectionDetails: (NSDictionary *) collectionDetails;
-(void) postNewAddOrRemoveNotificationOfType: (NSString *)notificationName withDetails: (NSDictionary *) userInfo;



@end
