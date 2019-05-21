//
//  HNSourceViewController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/10/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNSourceViewController.h"
#import "HNNSNotificationStrings.h"
#import "HNAppDelegateAsDataSource.h"
#import "HNPasteBoardTypes.h"
#import "PreCompiledHeaders.h"

// UI
#import "HNTreeController.h"
#import "HNOutlineView.h"
#import "HNAddRemoveItemsButton.h"
#import "HNAddCollectionsButton.h"
#import "HNMenuItem.h"
#import "ImageAndTextCell.h"

// Core Data
#import "HNCoreDataHeaders.h"

#define ctrlCommandMaskMacro = NSControlKeyMask | NSCommandKeyMask


//NSString *HNNodeIndexPathPasteBoardType = @"HNNodeIndexPathPasteBoardType";


@implementation HNSourceViewController

@synthesize datasource;
@synthesize delegate;
@synthesize outlineView             = _outlineView;

@synthesize outlineViewContextMenu  = _outlineViewContextMenu;
@synthesize button_addItems;
@synthesize button_removeItems;



-(id) init {
    //DLog(@"CALLED - HNSourceViewController: init");
	self =[super init];
	
	if	(!self) {
		return nil;
	}
	
	_outlineView = [[HNOutlineView alloc] init];
    //_outlineViewContextMenu = [[NSMenu alloc] init];
	
	//[self setButton_addItems: [[HNAddRemoveItemsButton alloc] init]];
    

	return self;
}

-(void) awakeFromNib {
	//DLog(@"CALLED - HNSourceViewController: awakeFromNib");
    
	NSArray *pasteBoardTypes = @[ HNNodeIndexPathPasteBoardType, HNDataItemsPasteBoardType, NSFilenamesPboardType ];
	
	[self.outlineView registerForDraggedTypes:pasteBoardTypes];
    
    /*
    [self setOutlineViewContextMenu: [self outlineViewContextualMenu]];
    [self.outlineView setMenu: self.outlineViewContextMenu];
    for (HNMenuItem *nextMenuItem in [[self.outlineView menu] itemArray]) {
        [nextMenuItem setEnabled: YES];
    }
     */
    
    
	//[self setAddButtonsMenuItems];
}



#pragma mark -
#pragma mark Menus

-(void) setAddButtonsMenuItems {
	//DLog(@"CALLED - HNSourceViewController: setAddButtonsMenuItems");
    
    
    // START COLLECTIONS SUBMENU
    HNMenuItem *newCollectionsSubMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Collection" action: nil keyEquivalent: @""];
    NSMenu *newCollectionMenu = [[NSMenu alloc] init];
    [newCollectionsSubMenuItem setSubmenu: newCollectionMenu];

    
    // Item 0 - Add New FOLDER  (COLLECTIONS SUBMENU)
    HNMenuItem *folderMenuItem = [[HNMenuItem alloc] initWithTitle: @"New Folder" action: nil keyEquivalent: hnKeyEquivalentNewFolder keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *folderUserInfo = @{ HNCollectionOfType : HNFolderCollectionType };
    [folderMenuItem setUserInfo: folderUserInfo];
    [folderMenuItem setNotificationType: HNAddCollectionNotification];
	//[button_addItems addMenuItem: folderMenuItem atIndex: 2];
    [newCollectionMenu addItem: folderMenuItem];
    
    
	
    // Item 1 - Add New EXPERIMENT  (COLLECTIONS SUBMENU)
    HNMenuItem *experimentMenuItem = [[HNMenuItem alloc] initWithTitle: @"New Experiment" action: nil keyEquivalent: hnKeyEquivalentNewExperiment keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *experimentUserInfo = @{ HNCollectionOfType : HNExperimentCollectionType };
    [experimentMenuItem setUserInfo: experimentUserInfo];
    [experimentMenuItem setNotificationType: HNAddCollectionNotification];
    //[button_addItems addMenuItem: experimentMenuItem atIndex: 1];
    [newCollectionMenu addItem: experimentMenuItem];
    
    
    
    // Item 2 - Add New PROJECT  (COLLECTIONS SUBMENU)
    HNMenuItem *projectMenuItem = [[HNMenuItem alloc] initWithTitle: @"New Project" action: nil keyEquivalent: hnKeyEquivalentNewProject keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
	NSDictionary *projectUserInfo = @{ HNCollectionOfType : HNProjectCollectionType };
    [projectMenuItem setUserInfo: projectUserInfo];
    [projectMenuItem setNotificationType: HNAddCollectionNotification];
	//[button_addItems addMenuItem: projectMenuItem atIndex: 0];
    [newCollectionMenu addItem: projectMenuItem];
    //DLog(@"newCollectionMenu items = %@", [newCollectionMenu itemArray]);
    
    
    [button_addItems addMenuItem: newCollectionsSubMenuItem atIndex: 0];
    // END COLLECTIONS
    
    
    
    // START  IMPORT
    HNMenuItem *importSubMenuItem = [[HNMenuItem alloc] initWithTitle: @"Import" action: nil keyEquivalent: @""];
    NSMenu *importMenu = [[NSMenu alloc] init];
    [importSubMenuItem setSubmenu: importMenu];
    
    
    // Item 0- Add New DATA Files
    HNMenuItem *dataFilesMenuItem = [[HNMenuItem alloc] initWithTitle: @"Data Files" action: nil keyEquivalent: hnKeyEquivalentImportDataFiles keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *dataFilesUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [dataFilesMenuItem setUserInfo: dataFilesUserInfo];
    [dataFilesMenuItem setNotificationType: HNAddDataFilesNotification];
	//[button_addItems addMenuItem: dataFilesMenuItem atIndex: 3];
	[importMenu addItem: dataFilesMenuItem];
    
    
    // Item 1- Import Directory
    HNMenuItem *importDirectoryMenuItem = [[HNMenuItem alloc] initWithTitle: @"Directory" action: nil keyEquivalent: @"" keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *importFoldersUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [importDirectoryMenuItem setUserInfo: importFoldersUserInfo];
    [importDirectoryMenuItem setNotificationType: HNAddDirectoryNotification];
	//[button_addItems addMenuItem: dataFilesMenuItem atIndex: 3];
	[importMenu addItem: importDirectoryMenuItem];
    
    
    // Item 2 - Import Graph Template
    HNMenuItem *importGraphTemplateMenuItem = [[HNMenuItem alloc] initWithTitle: @"Graph Template" action: nil keyEquivalent: hnKeyEquivalentImportGraphTemplateFiles keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *importGraphTemplateUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [importGraphTemplateMenuItem setUserInfo: importGraphTemplateUserInfo];
    [importGraphTemplateMenuItem setNotificationType: HNAddGraphTemplateNotification];
	//[button_addItems addMenuItem: dataFilesMenuItem atIndex: 3];
	[importMenu addItem: importGraphTemplateMenuItem];
    
    
    // Item 3 - Import Parse Template
    HNMenuItem *importParseTemplateMenuItem = [[HNMenuItem alloc] initWithTitle: @"Parse Template" action: nil keyEquivalent: hnKeyEquivalentImportParseTemplateFiles keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *importParseTemplateUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [importParseTemplateMenuItem setUserInfo: importParseTemplateUserInfo];
    [importParseTemplateMenuItem setNotificationType: HNAddParseTemplateNotification];
	//[button_addItems addMenuItem: dataFilesMenuItem atIndex: 3];
	[importMenu addItem: importParseTemplateMenuItem];
    
    
    [button_addItems addMenuItem: importSubMenuItem atIndex: 1];
    // END IMPORT
    
    
    
    
    // Item 4 - Add New PARSE TEMPLATE
    HNMenuItem *parseTemplateMenuItem = [[HNMenuItem alloc] initWithTitle: @"New Parse Template" action: nil keyEquivalent: hnKeyEquivalentNewParseTemplate keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *parseTemplateUserInfo = @{HNaddFilesFrom : HNAddFilesUsingBlankFile};
    [parseTemplateMenuItem setUserInfo: parseTemplateUserInfo];
    [parseTemplateMenuItem setNotificationType: HNAddParseTemplateNotification];
	[button_addItems addMenuItem: parseTemplateMenuItem atIndex: 4];
	
    
    /*
    // Item 5 - Add New Graph Template
    HNMenuItem *graphTemplateMenuItem = [[HNMenuItem alloc] initWithTitle: @"Import Graph Template" action: nil keyEquivalent: hnKeyEquivalentImportGraphTemplateFiles keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *graphTemplateUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [graphTemplateMenuItem	setUserInfo: graphTemplateUserInfo];
    [graphTemplateMenuItem	setNotificationType: HNAddGraphTemplateNotification];
	[button_addItems		addMenuItem: graphTemplateMenuItem	atIndex: 5];
    */
 
    
    /*
    // Item 6 - Add New Watched Folders
    HNMenuItem *watchedFoldersMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Watched Folder" action: nil keyEquivalent: @"" keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    
    NSDictionary *watchedFoldersUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [watchedFoldersMenuItem setUserInfo: watchedFoldersUserInfo];
    [watchedFoldersMenuItem setNotificationType: HNAddWatchedFoldersNotification];
	[button_addItems addMenuItem: watchedFoldersMenuItem atIndex: 6];
	*/
	
}

-(void) setRemoveButtonsMenuItems {
	//DLog(@"CALLED - HNSourceViewController: setRemoveButtonsMenuItems");
	
	
	// Item 0 - Remove Collection
    HNMenuItem *removeCollectionMenuItem = [[HNMenuItem alloc] initWithTitle: @"Remove Collection" action: nil keyEquivalent: @""];
    NSDictionary *removeCollectionUserInfo = [NSDictionary dictionary];
	
    [removeCollectionMenuItem setUserInfo: removeCollectionUserInfo];
    [removeCollectionMenuItem setNotificationType: HNRemoveCollectionNotification];
	[button_removeItems addMenuItem: removeCollectionMenuItem atIndex: 0];
	
	
	// Item 1 - Remove Data Items
    HNMenuItem *removeDataMenuItem = [[HNMenuItem alloc] initWithTitle: @"Remove Data" action: nil keyEquivalent: @""];
    NSDictionary *removeDataUserInfo = [NSDictionary dictionary];
	
    [removeDataMenuItem setUserInfo: removeDataUserInfo];
    [removeDataMenuItem setNotificationType: HNRemoveDataFilesNotification];
	[button_removeItems addMenuItem: removeDataMenuItem atIndex: 1];
	
	
	
	// Item 2 - Remove Parser Template
    HNMenuItem *removeParserMenuItem = [[HNMenuItem alloc] initWithTitle: @"Remove Parse Template" action: nil keyEquivalent: @""];
    NSDictionary *removeParesTemplateUserInfo = [NSDictionary dictionary];
	
    [removeParserMenuItem setUserInfo: removeParesTemplateUserInfo];
    [removeParserMenuItem setNotificationType: HNRemoveParseTemplateNotification];
	[button_removeItems addMenuItem: removeParserMenuItem atIndex: 2];
	
	
	// Item 3 - Remove Graph Template
    HNMenuItem *removeGraphTemplateMenuItem = [[HNMenuItem alloc] initWithTitle: @"Remove Graph Template" action: nil keyEquivalent: @""];
    NSDictionary *removeGraphTemplateUserInfo = [NSDictionary dictionary];
	
    [removeGraphTemplateMenuItem setUserInfo: removeGraphTemplateUserInfo];
    [removeGraphTemplateMenuItem setNotificationType: HNRemoveGraphTemplateNotification];
	[button_removeItems addMenuItem: removeGraphTemplateMenuItem atIndex: 3];
	
}

/*
-(NSMenu *) sourceViewContextualMenu {
    DLog(@"CALLED - HNSourceViewController:  outlineViewContextualMenu");
	NSMenu *contextMenu = [[NSMenu alloc] initWithTitle: @"Context"];
    [NSMenuItem setUsesUserKeyEquivalents: YES];
    
	HNMenuItem *addProjectMenuItem = [[HNMenuItem alloc] initWithTitle: @"New Project" action: nil keyEquivalent: hnKeyEquivalentNewParseTemplate keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[contextMenu addItem: addProjectMenuItem];
    
    
    HNMenuItem *addFolderMenuItem = [[HNMenuItem alloc] initWithTitle: @"New Folder" action: nil  keyEquivalent: hnKeyEquivalentNewFolder keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    [contextMenu addItem: addFolderMenuItem];
    
    
    HNMenuItem *addExperimentMenuItem = [[HNMenuItem alloc] initWithTitle: @"New Experiment" action:nil  keyEquivalent: hnKeyEquivalentNewExperiment keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    [contextMenu addItem: addExperimentMenuItem];
    
    
    HNMenuItem *importDataFiles = [[HNMenuItem alloc] initWithTitle: @"Import Data Filess" action: nil keyEquivalent: hnKeyEquivalentImportDataFiles keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    [contextMenu addItem: importDataFiles];
    
    
    HNMenuItem *importGraphTemplates = [[HNMenuItem alloc] initWithTitle: @"Import Graph Template" action: nil keyEquivalent:@"" keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    [contextMenu addItem: importGraphTemplates];
    
    
    HNMenuItem *importParseTemplates = [[HNMenuItem alloc] initWithTitle: @"Import Parse Template" action: nil keyEquivalent:@"" keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    [contextMenu addItem: importParseTemplates];
    
    
	
	
	HNMenuItem *exportCollection = [[HNMenuItem alloc] initWithTitle: @"Export Collection" action: nil keyEquivalent:@"" keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
    NSDictionary *dataFilesUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [exportCollection setUserInfo: dataFilesUserInfo];
    [exportCollection setNotificationType: HNAddDataFilesNotification];
	[contextMenu addItem: exportCollection];
	
	HNMenuItem *exportParserTemplate = [[HNMenuItem alloc] initWithTitle: @"Export Parsers" action: nil keyEquivalent: @"" keyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[contextMenu addItem: exportParserTemplate];
    
	
	return contextMenu;
	
}
 */


#pragma mark -
#pragma mark Notifications
-(void) postNotificationOfType: (NSString *)notificationName
                   withDetails: (NSDictionary *) userInfo {
	
	if (!notificationName) {
		return;
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName: notificationName
					  object: self
					userInfo: userInfo];
}



#pragma mark Add/New
-(IBAction) addNewProjectNotification:(id) sender {
    DLog(@"CALLED - HNSourceViewController:  addNewProjectNotification");
    
    // Get targetIndexPath based upon selection
    NSTreeController *localTreeController = [self.datasource treeControllerFromSource];
    HNTreeNode *targetTreeNode = [[localTreeController selectedObjects] lastObject];
    NSIndexPath *targetIndexPath = [localTreeController indexPathForInsertion];
    NSURL *targetTreeNodeURI = [[targetTreeNode objectID] URIRepresentation];
    
    
    
    // Set userInfo dictionary
    NSDictionary *userInfo;
    if (targetIndexPath) {
        userInfo = @{ HNCollectionOfType : HNProjectCollectionType, HNTargetTreeNodeNSIndexPathKey : targetIndexPath, HNTreeNodeURIKey : targetTreeNodeURI};
    }
    else {
        userInfo = @{ HNCollectionOfType : HNProjectCollectionType };
    }
    
    // Post Notification
    [self postNotificationOfType: HNAddCollectionNotification withDetails: userInfo];
}



-(IBAction) addNewFolderNotification:(id) sender {
    // Get targetIndexPath based upon selection
    NSTreeController *localTreeController = [self.datasource treeControllerFromSource];
    HNTreeNode *targetTreeNode = [[localTreeController selectedObjects] lastObject];
    NSIndexPath *targetIndexPath = [localTreeController indexPathForInsertion];
    NSURL *targetTreeNodeURI = [[targetTreeNode objectID] URIRepresentation];
    
    // Set userInfo dictionary
    NSDictionary *userInfo;
    if (targetIndexPath) {
        userInfo = @{ HNCollectionOfType : HNFolderCollectionType, HNTargetTreeNodeNSIndexPathKey : targetIndexPath, HNTreeNodeURIKey : targetTreeNodeURI};
    }
    else {
        userInfo = @{ HNCollectionOfType : HNFolderCollectionType };
    }
    
    // Post notification
    [self postNotificationOfType: HNAddCollectionNotification withDetails: userInfo];
	
}



-(IBAction) addNewExperimentNotification:(id) sender {
    
    // Get targetIndexPath based upon selection
    NSTreeController *localTreeController = [self.datasource treeControllerFromSource];
    HNTreeNode *targetTreeNode = [[localTreeController selectedObjects] lastObject];
    NSIndexPath *targetIndexPath = [localTreeController indexPathForInsertion];
    NSURL *targetTreeNodeURI = [[targetTreeNode objectID] URIRepresentation];
    
    // Set userInfo dictionary
    NSDictionary *userInfo;
    if (targetIndexPath) {
        userInfo = @{ HNCollectionOfType : HNExperimentCollectionType, HNTargetTreeNodeNSIndexPathKey : targetIndexPath, HNTreeNodeURIKey : targetTreeNodeURI};
    }
    else {
        userInfo = @{ HNCollectionOfType : HNExperimentCollectionType };
    }
    
    // Post Notification
    [self postNotificationOfType: HNAddCollectionNotification withDetails: userInfo];
    
	
}






#pragma mark Import
-(IBAction)importDataFilesNotification:(id)sender {
    
    NSString *notificationType = HNAddDataFilesNotification;
    
    // Get targetIndexPath based upon selection
    NSTreeController *localTreeController = [self.datasource treeControllerFromSource];
    
    NSIndexPath *targetIndexPath = [localTreeController indexPathForInsertion];
    HNTreeNode *targetTreeNode = [[localTreeController selectedObjects] lastObject];
    NSURL *targetTreeNodeURI = [[targetTreeNode objectID] URIRepresentation];
    
    // Set userInfo dictionary
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary: @{ HNaddFilesFrom : HNAddFilesFromNSOpenPanel }];
    if (targetTreeNode) {
        [userInfo setObject: targetTreeNodeURI forKey: HNTreeNodeURIKey];
    }
    if (targetIndexPath) {
        [userInfo setObject: targetIndexPath forKey: HNTargetTreeNodeNSIndexPathKey];
    }
    
    // Post Notification
    [self postNotificationOfType: notificationType
                     withDetails: [userInfo copy]];
    
}

-(IBAction) importParseTemplateNotifcation:(id)sender {
    NSString *notificationType = HNAddParseTemplateNotification;
    
    // Get targetIndexPath based upon selection
    NSTreeController *localTreeController = [self.datasource treeControllerFromSource];
    
    NSIndexPath *targetIndexPath = [localTreeController indexPathForInsertion];
    HNTreeNode *targetTreeNode = [[localTreeController selectedObjects] lastObject];
    NSURL *targetTreeNodeURI = [[targetTreeNode objectID] URIRepresentation];
    
    // Set userInfo dictionary
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary: @{ HNaddFilesFrom : HNAddFilesFromNSOpenPanel }];
    if (targetTreeNode) {
        [userInfo setObject: targetTreeNodeURI forKey: HNTreeNodeURIKey];
    }
    if (targetIndexPath) {
        [userInfo setObject: targetIndexPath forKey: HNTargetTreeNodeNSIndexPathKey];
    }
    
    // Post Notification
    [self postNotificationOfType: notificationType
                     withDetails: [userInfo copy]];
    
}


-(IBAction) importGraphTemplateNotification:(id)sender {
    NSString *notificationType = HNAddGraphTemplateNotification;
    
    // Get targetIndexPath based upon selection
    NSTreeController *localTreeController = [self.datasource treeControllerFromSource];
    
    NSIndexPath *targetIndexPath = [localTreeController indexPathForInsertion];
    HNTreeNode *targetTreeNode = [[localTreeController selectedObjects] lastObject];
    NSURL *targetTreeNodeURI = [[targetTreeNode objectID] URIRepresentation];
    
    // Set userInfo dictionary
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary: @{ HNaddFilesFrom : HNAddFilesFromNSOpenPanel }];
    if (targetTreeNode) {
        [userInfo setObject: targetTreeNodeURI forKey: HNTreeNodeURIKey];
    }
    if (targetIndexPath) {
        [userInfo setObject: targetIndexPath forKey: HNTargetTreeNodeNSIndexPathKey];
    }
    
    // Post Notification
    [self postNotificationOfType: notificationType
                     withDetails: [userInfo copy]];
    
}

-(IBAction) importFolderNotification:(id)sender {
    NSString *notificationType = HNAddDirectoryNotification;
    
    // Get targetIndexPath based upon selection
    NSTreeController *localTreeController = [self.datasource treeControllerFromSource];
    
    NSIndexPath *targetIndexPath = [localTreeController indexPathForInsertion];
    HNTreeNode *targetTreeNode = [[localTreeController selectedObjects] lastObject];
    NSURL *targetTreeNodeURI = [[targetTreeNode objectID] URIRepresentation];
    
    // Set userInfo dictionary
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary: @{ HNaddFilesFrom : HNAddFilesFromNSOpenPanel }];
    if (targetTreeNode) {
        [userInfo setObject: targetTreeNodeURI forKey: HNTreeNodeURIKey];
    }
    if (targetIndexPath) {
        [userInfo setObject: targetIndexPath forKey: HNTargetTreeNodeNSIndexPathKey];
    }
    
    // Post Notification
    [self postNotificationOfType: notificationType
                     withDetails: [userInfo copy]];
}

#pragma mark Export
-(IBAction) exportCollectionNotification:(id) sender {
	//DLog(@"CALLED - HNSourceViewController:  exportCollectionNotification");
    
    NSArray *selectedTreeNodes = [[self.datasource treeControllerFromSource] selectedObjects];
    
    
    NSDictionary *userInfo = @{HNExportItemsUsingKey : HNExportItemsUsingSavePanel, HNExportItemsArrayKey : selectedTreeNodes};
    
    
    [self postNotificationOfType: HNExportCollectionNotification withDetails: userInfo];
}


-(IBAction) exportParseTemplateNotification:(id) sender {
	//DLog(@"CALLED - HNSourceViewController:  exportParseTemplateNotification");
    // Get list of parseTemplates to export
    NSArray *selectedTreeNodes = [[self.datasource treeControllerFromSource] selectedObjects];
    
    if ([selectedTreeNodes count] == 0) {
        // No selected treeNodes and, thus, not parseTemplates to export
        return;
    }
    
    // Flatten entire selectedTreeNodes structure
    NSMutableSet *flattenedNodes = [NSMutableSet set];
    
    for (HNTreeNode *nextTreeNode in selectedTreeNodes) {
        [flattenedNodes addObject: nextTreeNode];
        [flattenedNodes addObjectsFromArray: [nextTreeNode allTreeNodeChildren]];
    }
    
    // Get all the Parse Templates for flattenedNodes
    NSMutableSet *allParseTemplates = [NSMutableSet set];
    
    for (HNTreeNode *nextTreeNode in flattenedNodes) {
        [allParseTemplates addObject: nextTreeNode.defaultParseTemplate];
        [allParseTemplates unionSet: [nextTreeNode parseTemplates]];
    }
    
    NSDictionary *userInfo = @{HNExportItemsUsingKey : HNExportItemsUsingSavePanel, HNExportItemsArrayKey : [allParseTemplates allObjects]};
    
    [self postNotificationOfType: HNExportParseTemplateNotification
                     withDetails: userInfo];
}


-(IBAction) exportGraphTemplateNotfication:(id) sender {
	//DLog(@"CALLED - HNSourceViewController:  exportGraphTemplateNotfication");
    
    // Get list of parseTemplates to export
    NSArray *selectedTreeNodes = [[self.datasource treeControllerFromSource] selectedObjects];
    
    if ([selectedTreeNodes count] == 0) {
        // No selected treeNodes and, thus, not parseTemplates to export
        return;
    }
    
    // Flatten entire selectedTreeNodes structure
    NSMutableSet *flattenedNodes = [NSMutableSet set];
    
    for (HNTreeNode *nextTreeNode in selectedTreeNodes) {
        [flattenedNodes addObject: nextTreeNode];
        [flattenedNodes addObjectsFromArray: [nextTreeNode allTreeNodeChildren]];
    }
    
    // Get all the Parse Templates for flattenedNodes
    NSMutableSet *allGraphTemplates = [NSMutableSet set];
    
    for (HNTreeNode *nextTreeNode in flattenedNodes) {
        [allGraphTemplates addObject: nextTreeNode.defaultGraphTemplate];
        [allGraphTemplates unionSet: [nextTreeNode parseTemplates]];
    }
    
    NSDictionary *userInfo = @{HNExportItemsUsingKey : HNExportItemsUsingSavePanel, HNExportItemsArrayKey : [allGraphTemplates allObjects]};
    
    [self postNotificationOfType: HNExportGraphTemplateNotification
                     withDetails: userInfo];
    
    
}

-(IBAction) exportDataItemsNotification:(id) sender {
    //DLog(@"CALLED - HNSourceViewController:  exportGraphTemplateNotfication");
    
    // Get list of parseTemplates to export
    NSArray *selectedTreeNodes = [[self.datasource treeControllerFromSource] selectedObjects];
    
    if ([selectedTreeNodes count] == 0) {
        // No selected treeNodes and, thus, not parseTemplates to export
        return;
    }
    
    NSMutableSet *allDataItems = [NSMutableSet set];
    
    for (HNTreeNode *nextTreeNode in selectedTreeNodes) {
        [allDataItems unionSet: [nextTreeNode allDataItems]];
    }
    
    NSDictionary *userInfo = @{HNExportItemsUsingKey : HNExportItemsUsingSavePanel, HNExportItemsArrayKey : [allDataItems allObjects]};
    
    [self postNotificationOfType: HNExportDataFilesNotification
                     withDetails:userInfo];
    
}


@end



#pragma mark -
#pragma mark NSOutlineViewDragAndDrop
@implementation HNSourceViewController (NSOutlineViewDragAndDrop)
- (BOOL)outlineView:(NSOutlineView *)outlineView
		 writeItems:(NSArray *)items
	   toPasteboard:(NSPasteboard *)pasteBoard {
    //DLog(@"Called - HNAppDelegate: outlineView: writeItems: toPasteboard");
    // CHANGED
    [pasteBoard clearContents];
	[pasteBoard declareTypes:[NSArray arrayWithObject:HNNodeIndexPathPasteBoardType] owner:self];
	[pasteBoard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:HNNodeIndexPathPasteBoardType];
    
	return YES;
}


// Validate Drop
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
				  validateDrop:(id < NSDraggingInfo >)info
				  proposedItem:(id)proposedParentItem
			proposedChildIndex:(NSInteger)proposedChildIndex {
	//DLog(@"Called - HNSourceViewController: outlineView: validateDrop");
	
	NSArray *pasteBoardTypes = [[info draggingPasteboard] types];
	
	
	// Dragging/Repositioning TreeNodes
	if ([pasteBoardTypes containsObject: HNNodeIndexPathPasteBoardType]) {
		if (proposedChildIndex == -1) // will be -1 if the mouse is hovering over a leaf node
			return NSDragOperationNone;
		
		NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:HNNodeIndexPathPasteBoardType]];
		BOOL targetIsValid = YES;
		
		
		HNTreeController *localTreeController = [self.datasource treeControllerFromSource];
		
		for (NSIndexPath *indexPath in draggedIndexPaths) {
			NSTreeNode *node = [localTreeController nodeAtIndexPath:indexPath];
			if (!node.isLeaf) {
				if ([proposedParentItem isDescendantOfNode:node] || proposedParentItem == node) { // can't drop a group on one of its descendants
					targetIsValid = NO;
					break;
				}
			}
		}
		
		return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
	}
	
	
	// DROPPING Data Items
	if ( [pasteBoardTypes containsObject: HNDataItemsPasteBoardType]) {
		
		// Only drop on treeNodes, not between
		[self.outlineView setDropItem: proposedParentItem dropChildIndex:NSOutlineViewDropOnItemIndex]
		;
		BOOL targetIsValid = YES;
		if ( !proposedParentItem ) {
			// No target
			targetIsValid = NO;
			return NSDragOperationNone;
		}
		
		
		//return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
		
		return NSDragOperationMove;
	}
	
	
	
	
	// DROPPING filepaths
	if ([pasteBoardTypes containsObject: NSFilenamesPboardType]) {
		[self.outlineView setDropItem: proposedParentItem dropChildIndex: NSOutlineViewDropOnItemIndex];
		//DLog(@"return NSDragOperationLink");
		return NSDragOperationLink;
	}
	
	
	
	
	return NSDragOperationNone;
}



- (BOOL)outlineView:(NSOutlineView *)outlineView
		 acceptDrop:(id < NSDraggingInfo >)info
			   item:(id)proposedParentItem
		 childIndex:(NSInteger)proposedChildIndex {
    //DLog(@"Called - HNSourceViewController: outlineView: acceptDrop");
	
	NSPasteboard *pasteBoard = [info draggingPasteboard];
	NSArray *pasteBoardTypes = [[info draggingPasteboard] types];
	
	NSIndexPath *insertionIndexPath;
	if (!proposedParentItem) {
		insertionIndexPath = [[NSIndexPath alloc] init];  // makes a NSIndexPath with length == 0
	}
	else {
		//insertionIndexPath = [[proposedParentItem indexPath] indexPathByAddingIndex: proposedChildIndex];
		insertionIndexPath = [[proposedParentItem indexPath] indexPathByAddingIndex: 0];
	}
	
	
	//DLog(@"pasteboardTypes = %@", pasteBoardTypes);
	
	
	
	// ********************************
	// Dragging/Repositioning TreeNodes
	if ([pasteBoardTypes containsObject: HNNodeIndexPathPasteBoardType]) {
		//DLog(@"Repositioning Nodes");
		HNTreeController *localTreeController = [self.datasource treeControllerFromSource];
		
		//[self setTreeController: [datasource treeControllerFromSource]];
		NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:HNNodeIndexPathPasteBoardType]];
		
		NSMutableArray *draggedNodes = [NSMutableArray array];
		for (NSIndexPath *indexPath in droppedIndexPaths)
			[draggedNodes addObject:[localTreeController nodeAtIndexPath:indexPath]];
		
		NSIndexPath *proposedParentIndexPath;
		if (!proposedParentItem)
			proposedParentIndexPath = [[NSIndexPath alloc] init]; // makes a NSIndexPath with length == 0
		else
			proposedParentIndexPath = [proposedParentItem indexPath];
		
		[localTreeController moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex]];
		return YES;
	}
	
	
	
	// *******************
	// DROPPING filepaths
	else if ( [pasteBoardTypes containsObject: NSFilenamesPboardType] ) {
        BOOL acceptReturn = NO;
		//DLog(@"Drop files or directory");
		
		HNTreeNode *parentTreeNode	= (HNTreeNode *) [proposedParentItem representedObject];
		NSURL *targetTreeNodeURI	= [[parentTreeNode objectID] URIRepresentation];
		
		NSArray		 *files			= [pasteBoard propertyListForType: NSFilenamesPboardType];
		//DLog(@"files = %@", files);
		NSMutableSet *directories	= [NSMutableSet set];
        NSMutableSet *parseTemplateFiles = [NSMutableSet set];
        NSMutableSet *graphTemplateFiles = [NSMutableSet set];
        NSMutableSet *dataFiles          = [NSMutableSet set];

		
		
		// ADD DIRECTORIES
		NSFileManager *fm = [NSFileManager defaultManager];
		BOOL isDirectory;
		
		
		for (NSString *nextFilePath in files) {
            // Check to see if the nextFilePath is a Data File
            if ([self fileIsADataFile: nextFilePath]) {
                [dataFiles addObject: nextFilePath];
                continue;
            }
            else if ( [self fileIsAGraphTemplate: nextFilePath] ) {
                [graphTemplateFiles addObject: nextFilePath];
                continue;
            }
            else if ( [self fileIsAParseTemplate: nextFilePath] ) {
                [parseTemplateFiles addObject: nextFilePath];
                continue;
            }
            else if ( [fm fileExistsAtPath: nextFilePath isDirectory: &isDirectory] ) {
                if (isDirectory) {
                    [directories addObject: nextFilePath];
                    continue;
                }
            }
            else {
                DLog(@"File to add is an unknown filetype");
            }
			
		}
		
		

		// ADD DATA FILES
		if ([[dataFiles allObjects] count] > 0) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			NSString *notificationType = HNAddDataFilesNotification;
            
			// CHANGED
			//NSDictionary *userInfo = @{ HNaddFilesFrom : HNAddFilePathsFromPasteBoard, HNArrayOfDataFilePathsToAddKey : dataFiles, HNTargetTreeNodeNSIndexPathKey : targetTreeNodeURI};
            
            NSMutableDictionary *userInfoMutable = [NSMutableDictionary dictionaryWithDictionary: @{HNaddFilesFrom : HNAddFilePathsFromPasteBoard, HNArrayOfDataFilePathsToAddKey : dataFiles}];
            if (targetTreeNodeURI) {
                [userInfoMutable setObject: targetTreeNodeURI forKey:HNTreeNodeURIKey];
            }
            if (insertionIndexPath) {
                [userInfoMutable setObject: insertionIndexPath forKey:HNTargetTreeNodeNSIndexPathKey];
            }
			
            NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary: userInfoMutable];
			[nc postNotificationName: notificationType
							  object: self
							userInfo: userInfo];
            
            acceptReturn = YES;
			
		}
        
        // ADD GRAPH TEMPLATES
        if ( [[graphTemplateFiles allObjects] count] > 0 ) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSString *notificationType = HNAddGraphTemplateNotification;
            
            // CHANGED
            //  NSDictionary *userInfo = @{ HNaddFilesFrom : HNAddFilePathsFromPasteBoard, HNArrayOfGraphTemplateFilePathsToAddKey: graphTemplateFiles, HNTreeNodeURIKey : targetTreeNodeURI, HNTargetTreeNodeNSIndexPathKey : insertionIndexPath};
            
            NSMutableDictionary *userInfoMutable = [NSMutableDictionary dictionaryWithDictionary: @{ HNaddFilesFrom : HNAddFilePathsFromPasteBoard, HNArrayOfGraphTemplateFilePathsToAddKey: graphTemplateFiles}];
            if (targetTreeNodeURI) {
                [userInfoMutable setObject: targetTreeNodeURI forKey:HNTreeNodeURIKey];
            }
            if (insertionIndexPath) {
                [userInfoMutable setObject: insertionIndexPath forKey:HNTargetTreeNodeNSIndexPathKey];
            }
			
            NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary: userInfoMutable];
            
			[nc postNotificationName: notificationType
							  object: self
							userInfo: userInfo];
            
            acceptReturn = YES;
        }
        
        
        // ADD PARSE TEMPLATES
        if ( [[parseTemplateFiles allObjects] count] > 0 ) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSString *notificationType = HNAddParseTemplateNotification;
            
            // CHANGED
            //NSDictionary *userInfo = @{ HNaddFilesFrom : HNAddFilePathsFromPasteBoard, HNArrayOfParseTemplateFilePathsToAddKey: parseTemplateFiles, HNTreeNodeURIKey : targetTreeNodeURI, HNTargetTreeNodeNSIndexPathKey : insertionIndexPath};
            
            
            NSMutableDictionary *userInfoMutable = [NSMutableDictionary dictionaryWithDictionary: @{ HNaddFilesFrom : HNAddFilePathsFromPasteBoard, HNArrayOfParseTemplateFilePathsToAddKey: parseTemplateFiles}];
            if (targetTreeNodeURI) {
                [userInfoMutable setObject: targetTreeNodeURI forKey:HNTreeNodeURIKey];
            }
            if (insertionIndexPath) {
                [userInfoMutable setObject: insertionIndexPath forKey:HNTargetTreeNodeNSIndexPathKey];
            }
			
            NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary: userInfoMutable];
            
			[nc postNotificationName: notificationType
							  object: self
							userInfo: userInfo];
            
            acceptReturn = YES;
        }
        
        
        
        // ADD DIRECTORIES
        if ([[directories allObjects] count] != 0) {
			//DLog(@"Dragged directories = %@", directories);
			NSNotificationCenter *nc	= [NSNotificationCenter defaultCenter];
			NSString *notificationType	= HNAddDirectoryNotification;
            
            // CHANGED
			//NSDictionary *userInfo		= @{ HNaddFilesFrom : HNAddFilesFromNotifiationArray, HNArrayOfDirectoryKeyPathsToAddKey: directories, HNTreeNodeURIKey : targetTreeNodeURI, HNTargetTreeNodeNSIndexPathKey : insertionIndexPath};
			DLog(@"Post notification to ADD directories: %@", directories);
            
            NSMutableDictionary *userInfoMutable = [NSMutableDictionary dictionaryWithDictionary: @{ HNaddFilesFrom : HNAddFilesFromNotifiationArray, HNArrayOfDirectoryKeyPathsToAddKey: directories}];
            if (targetTreeNodeURI) {
                [userInfoMutable setObject: targetTreeNodeURI forKey:HNTreeNodeURIKey];
            }
            if (insertionIndexPath) {
                [userInfoMutable setObject: insertionIndexPath forKey:HNTargetTreeNodeNSIndexPathKey];
            }
			
            NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary: userInfoMutable];
            
			[nc postNotificationName: notificationType
							  object: self
							userInfo: userInfo];
			
            
            acceptReturn = YES;
			
			// Check to see if files still need to be added
			if ([[directories allObjects] count] == [files count] ) {
				// CHANGED
                return YES;
			}
		}
        
        
        
        // FINISHED ADDING FILES
        return acceptReturn;
        
	}
	
	
	// ********************
	// DROPPING HNDataItems
	else if ([pasteBoardTypes containsObject: HNDataItemsPasteBoardType]) {
		//DLog(@"Dropping HNDataItems onto Source List");
		NSData *archivedData = [pasteBoard dataForType: HNDataItemsArrayKey];
		HNTreeNode *parentTreeNode = (HNTreeNode *) [proposedParentItem representedObject];
		
		NSURL *targetTreeNodeURI = [[parentTreeNode objectID] URIRepresentation];
		
		
		// See if there are dataItems to drop
		if ( !archivedData ) {
			DLog(@"NO archivedData");
			return NO;
		}
		
		// Post NSNotification
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		NSString *notificationType = HNMoveDatatItemsNotification;
		NSDictionary *userInfo = @{HNDataItemsArrayKey : archivedData, HNTreeNodeURIKey: targetTreeNodeURI };
		[nc postNotificationName: notificationType
						  object:self
						userInfo:userInfo];
		return YES;		
	}
	
	// Does not match any pasteBoardTypes
	else {
		//DLog(@"PasteBoard does not match type:  %@", pasteBoardTypes);
		return NO;
	}
	
	//DLog(@"FINISHED - acceptDrop");
	return NO;
}


-(BOOL) fileIsAGraphTemplate: (NSString *) filePath {
    BOOL extensionMatch = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *fileTypeExtensions = [defaults objectForKey: HNExtensionsForGraphTemplatesKey];
    NSString *fileExtension = [filePath pathExtension];
    
    for (NSString *nextFileExtension in fileTypeExtensions) {
        if ( [fileExtension isEqualToString: nextFileExtension]) {
            return extensionMatch = YES;
        }
    }
    
    return extensionMatch;
}


-(BOOL) fileIsAParseTemplate: (NSString *) filePath {
    BOOL extensionMatch = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *fileTypeExtensions = [defaults objectForKey: HNExtensionsForParseTemplatesKey];
    NSString *fileExtension = [filePath pathExtension];
    
    for (NSString *nextFileExtension in fileTypeExtensions) {
        if ( [fileExtension isEqualToString: nextFileExtension]) {
            return extensionMatch = YES;
        }
    }
    
    return extensionMatch;
}

-(BOOL) fileIsADataFile: (NSString *) filePath {
    BOOL extensionMatch = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *fileTypeExtensions = [defaults objectForKey: HNExtensionsForDataFileTypesKey];
    NSString *fileExtension = [filePath pathExtension];
    
    for (NSString *nextFileExtension in fileTypeExtensions) {
        if ( [fileExtension isEqualToString: nextFileExtension]) {
            return extensionMatch = YES;
        }
    }
    
    return extensionMatch;
}



@end




#pragma mark -
#pragma mark NSOutlineViewDelegate
@implementation HNSourceViewController (NSOutlineViewDelegate)
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    //DLog(@"CALLED - outlineView:  isGroupItem");
	if ([[(HNTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf]) {
		return NO;
    }
	
	else if  ([[item representedObject] respondsToSelector:@selector(isSpecialGroup)] ) {
		return [[[item representedObject] isSpecialGroup] boolValue];
	}
	else {
		//DLog(@"%@\n does NOT respond to isSpecialGroup", [item representedObject]);
		return NO;
	}
}


- (void)outlineView:(NSOutlineView *)outlineView
	willDisplayCell:(NSCell *)cell
	 forTableColumn:(NSTableColumn *)tableColumn
			   item:(id)item {
    HNTreeNode *treeNode = [item representedObject];
    if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString: @"sourceListDisplayName"]) {
        // Make sure the image and text cell has an image.  If not, lazily fill in a random image
		
		NSImage *image;
		// EXPERIMENT IMAGE
		if ([treeNode.collectionType.typeName isEqualToString: HNExperimentCollectionType]) {
					image = [NSImage imageNamed:@"Source-Experiment"];
		}
		// PROJECT IMAGE
		else if ([treeNode.collectionType.typeName  isEqualToString: HNProjectCollectionType]) {
			image = [NSImage imageNamed:@"Source-Project"];
		}
		// FOLDER(S) IMAGE
		else if ([treeNode.collectionType.typeName  isEqualToString: HNFolderCollectionType]) {
			// Folders with sub-folders use @"Source-Folders"
			// Folders without sub-folders use @"Source-Folder"
			
			// Get flattend objects and interate to see if sub-folders exists
			BOOL subFoldersExist = NO;
			
			
			if ([item respondsToSelector:@selector(groupDescendants)]) {
				NSArray *flattendObjects = [item groupDescendants];
				for (NSTreeNode *nextNode in flattendObjects) {
					NSString *nextType = [[[nextNode representedObject] collectionType] typeName];
					
					if ([nextType isEqualToString: HNFolderCollectionType]) {
						subFoldersExist = YES;
						break;
					}
				}
				
				if (subFoldersExist == YES) {
					image = [NSImage imageNamed:@"Source-Folders"];
				}
				else  {
					image = [NSImage imageNamed:@"Source-Folder"];
				}
			}
			else {
				DLog(@"item is type of: %@", [item class]);
				image = [NSImage imageNamed:@"Source-Folder"];
			}
			
			
		}
		// NO IMAGE
		else {
			image = nil;
		}
		
        // We know that the cell at this column is our image and text cell, so grab it
        ImageAndTextCell *imageAndTextCell = (ImageAndTextCell *)cell;
        // Set the image here since the value returned from outlineView:objectValueForTableColumn:... didn't specify the image part...
        [imageAndTextCell setImage:image];
    }
}





- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    if ([[(HNTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf]) {
		return NO;
    }
    
    if ([[item representedObject] respondsToSelector:@selector(children)] ) {
		if ([[[item representedObject] children] count] > 0) {
            return YES;
        }
	}
    
    return NO;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item {
    //DLog(@"Called - HNAppDelegate: shouldCollapseItem");
    if ([[(HNTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf]) {
        return NO;}
    
    // TODO: FIX canCollapse
	//return [[[item representedObject] canCollapse] boolValue];
    return YES;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    //DLog(@"called - outlineView:shouldExpandItem");
	if ([[(HNTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf]) {
		return NO;
    }
	
	if ([[item representedObject] respondsToSelector:@selector(canExpand)] ) {
		//DLog(@"item can respond to \"canExpand\" and: %hhu", [[[item representedObject] canExpand] boolValue]);
        
		return [[[item representedObject] canExpand] boolValue];
	}
	else {
		///DLog(@"%@\n\ndoes not respond to \"canExpand\"", [item representedObject]);
        return NO;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	//DLog(@"Called - HNAppDelegate: shouldSelectItem");
	
	//HNTreeNode *selectedNode = [item representedObject];
	// DLog(@"selectedNode = %@,   isLeaf = %lu", selectedNode.displayName, [[selectedNode isLeaf] integerValue]);
    
    
    BOOL shouldSelect = [[(HNTreeNode *)[item representedObject] isSelectable] boolValue];
	return shouldSelect;
}

- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineViewIn {
	[outlineViewIn deselectAll: self];
	
    BOOL selectinShouldChange = YES;
    
    return selectinShouldChange;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
	if ([[[[notification userInfo] valueForKey:@"NSObject"] representedObject] respondsToSelector:@selector(isExpanded)] ) {
		HNTreeNode *collapsedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
		collapsedItem.isExpanded = [NSNumber numberWithBool:NO];
	}
}


- (void)outlineViewItemDidExpand:(NSNotification *)notification {
	if ([[[[notification userInfo] valueForKey:@"NSObject"] representedObject] respondsToSelector:@selector(isExpanded)] ) {
		HNTreeNode *expandedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
		expandedItem.isExpanded = [NSNumber numberWithBool:YES];
	}
}

-(void) outlineViewSelectionDidChange:(NSNotification *) notification {
	//DLog(@"CALLED - HNSourceViewController: outlineViewSelectionDidChange");
	//DLog(@"identifier = %@", [[notification object] identifier]);
	//DLog(@"for outlineView: %@", [[notification object] description]);
    
    
	
	if ([[[notification object] identifier] isEqualToString: @"sourceList"]) {
        //HNOutlineView *outlineView = [notification object];
        
		
		// Post change Notification Center
        
        if (!datasource) {
            DLog(@"NO DATA SOURCE");
			return;
        }
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        NSArray *selectedNodes	= [[self.datasource treeControllerFromSource] selectedNodes];
		NSArray *indexPaths		= [[self.datasource treeControllerFromSource] selectionIndexPaths];
        
        
		
		NSDictionary *userInfo = @{ @"selectednodes" : selectedNodes, @"indexPaths" : indexPaths };
        
		[nc postNotificationName: HNSouceListViewSelectionDidChange object:self userInfo:userInfo];
	}
}


#pragma mark Menu Items
- (IBAction)expandableMenuItemAction:(id)sender {
	DLog(@"CALLED - HNSourceViewController:  expandableMenuItemAction ");
    // The tag of the clicked row contains the item that was clicked on
    NSInteger clickedRow = [_outlineView clickedRow];	
	
	[_outlineView setNeedsDisplayInRect:[_outlineView rectOfRow:clickedRow]];
	
	// CHANGED
	/*
    // Flip the expandable state,
    nodeData.expandable = !nodeData.expandable;
    // Refresh that row (since its state has changed)
    [_outlineView setNeedsDisplayInRect:[_outlineView rectOfRow:clickedRow]];
    // And collopse it if we can no longer expand it
    if (!nodeData.expandable && [_outlineView isItemExpanded:treeNode]) {
       [_outlineView collapseItem:treeNode];
    }
	 */
}


/*
- (void)menuNeedsUpdate:(NSMenu *)menu {
	//DLog(@"CALLED - HNSourceViewController:  menuNeedsUpdate ");
    //DLog(@"For:  %@", menu);
    
    
    NSInteger clickedRow = [_outlineView clickedRow];
	NSTreeNode *clickedNode = [_outlineView itemAtRow:clickedRow];
    HNTreeNode *clickedHNTreeNode = [clickedNode representedObject];
	NSArray *selectedObjects = [[self.datasource treeControllerFromSource] selectedObjects];
	
	
	
    id item = nil;
    HNTreeNode *nodeData = nil;
    BOOL clickedOnMultipleItems = NO;
	
    if (clickedRow != -1) {
        // If we clicked on a selected row, then we want to consider all rows in the selection. Otherwise, we only consider the clicked on row.
        item = [_outlineView itemAtRow:clickedRow];
        nodeData = [item representedObject];
        clickedOnMultipleItems = [_outlineView isRowSelected:clickedRow] && ([_outlineView numberOfSelectedRows] > 1);
    }
	
	if ( ![selectedObjects containsObject: clickedHNTreeNode] ) {
		// move selection to match that of the right click
		
		NSIndexPath *clickedIndexPath = [clickedNode indexPath];
		DLog(@"click not within selection.  Move selectionto indexPath: %@", clickedIndexPath );
		[[self.datasource treeControllerFromSource] setSelectionIndexPath: clickedIndexPath];
	}
	
    
    if (menu == outlineViewContextMenu) {
        NSMenuItem *menuItem = [menu itemAtIndex:0];
        if (nodeData != nil) {
            if (clickedOnMultipleItems) {
                // We could walk through the selection and note what was clicked on at this point
                [menuItem setTitle:[NSString stringWithFormat:@"You clicked on %ld items!", (long)[_outlineView numberOfSelectedRows]]];
            } else {
                [menuItem setTitle:[NSString stringWithFormat:@"You clicked on: '%@'", nodeData.displayName]];
            }
            [menuItem setEnabled:YES];
        } else {
            [menuItem setTitle:@"You didn't click on any rows..."];
            [menuItem setEnabled:NO];
        }
        [deleteSelectedItemsMenuItem setEnabled:[_outlineView selectedRow] != -1];
    }
	else if (menu == expandableColumnMenu) {
        NSMenuItem *menuItem = [menu itemAtIndex:0];
        if (!clickedOnMultipleItems && (nodeData != nil)) {
            // The item will be enabled only if it is a group
            [menuItem setEnabled: YES];
            // Check it if it is expandable
			NSUInteger numberOfSubCollections = [[[nodeData children] allObjects] count];
            [menuItem setState: numberOfSubCollections ? 1 : 0];
			
        } else {
            [menuItem setEnabled:NO];
        }
    }
}
*/




@end