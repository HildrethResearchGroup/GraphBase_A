//
//  HNAppDelegate.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 7/30/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "PreCompiledHeaders.h"
#import "DMTabBarDelegate.h"
#import "HNAppDelegateAsDataSource.h"
//#import "HNAppDelegate+HNCoreDataManagement.h"


// UI Controllers
@class HNPreferencePanelWindowController;
@class HNTabViewController;
@class HNSourceViewController;
@class HNDataViewController;


@class DMTabBar;
@class HNOutlineView;
@class HNTreeController;
@class HNTreeNodeArrayController;
@class HNDataParser;

@class HNTreeNode;
@class HNGroupNode;
@class HNLeafNode;
@class HNAccessoryView;



@interface HNAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, HNAppDelegateAsDataSource> {
    
	// Controllers for the various views
	IBOutlet	HNTabViewController		*tabViewController;
	IBOutlet	HNSourceViewController	*sourceListViewController;
	IBOutlet	HNDataViewController	*dataViewController;
	
    
    // Tree Controller
    IBOutlet	HNTreeController	*treeController;
	
    
	// Array Controllers
	IBOutlet	NSArrayController			*typesOfCollectionsArrayController;
    IBOutlet    HNTreeNodeArrayController	*treeNodeArrayController;
	IBOutlet	NSArrayController			*dataItemsArrayController;
    IBOutlet    NSArrayController			*parserListArrayController;
    IBOutlet    NSArrayController			*graphTemplateListArrayController;
	IBOutlet	NSArrayController			*allParserListArrayController;
	IBOutlet	NSArrayController			*allGraphTemplateListArrayController;
    IBOutlet    NSArrayController           *collectionTypesArrayController;
	
	
	
	
	// Core data Objects
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel		 *managedObjectModel;
	NSManagedObjectContext		 *managedObjectContext;
    
    
    // Accessory Views
    IBOutlet    HNAccessoryView *accessoryView_openDataFiles;

	
    
    HNPreferencePanelWindowController *preferenceController;
}


@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSView *testView;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel		 *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext		 *managedObjectContext;
//@property (assign, nonatomic) NSTableView *dataListTableView;
@property (retain, strong, nonatomic)   NSMutableArray				 *currentDataItems;
@property (retain, strong, nonatomic)	HNTreeController			 *treeController;
@property (retain, strong, nonatomic)	HNTreeNodeArrayController	 *treeNodeArrayController;
@property (retain, strong, nonatomic)	NSArrayController			 *dataItemsArrayController;
@property (retain, strong, nonatomic)	NSArrayController			 *typesOfCollectionsArrayController;
@property (retain, strong, nonatomic)	NSArrayController			 *parserListArrayController;
@property (retain, strong, nonatomic)	NSArrayController			 *graphTemplateListArrayController;
@property (retain, strong, nonatomic)	NSArrayController			 *allParserListArrayController;
@property (retain, strong, nonatomic)	NSArrayController			 *allGraphTemplateListArrayController;
@property (retain, strong, nonatomic)	NSArrayController			 *collectionTypesArrayController;


// View Controllers
@property (retain, strong, nonatomic)  HNTabViewController      *tabViewController;
@property (retain, strong, nonatomic)  HNDataViewController     *dataViewController;
@property (retain, strong, nonatomic)  HNSourceViewController	*sourceListViewController;


- (NSURL *)applicationFilesDirectory;


#pragma mark -
#pragma mark Menu Itmes
-(IBAction) saveAction: (id)sender;
-(IBAction) showPreferencePanel: (id)sender;


#pragma mark - 
#pragma mark Source View
- (NSArray *)treeNodeSortDescriptors;
-(NSArray *) arrayControllerSortDescriptors;



@end
