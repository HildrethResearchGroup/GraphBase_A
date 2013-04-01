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

// UI
#import "HNTreeController.h"
#import "HNOutlineView.h"
#import "HNAddRemoveItemsButton.h"
#import "HNAddCollectionsButton.h"
#import "HNMenuItem.h"

// Core Data
#import "HNCoreDataHeaders.h"


//NSString *HNNodeIndexPathPasteBoardType = @"HNNodeIndexPathPasteBoardType";


@implementation HNSourceViewController

@synthesize datasource;
@synthesize delegate;
@synthesize outlineView;
@synthesize treeController;
@synthesize button_addItems;



-(id) init {
    DLog(@"CALLED - HNSourceViewController: init");
	self =[super init];
	
	if	(!self) {
		return nil;
	}
	
	outlineView = [[HNOutlineView alloc] init];
    
    treeController = [[HNTreeController alloc] init];
	
    if (!treeController) {
        DLog(@"no treeController");
    }
    
	[self setAddButtonsMenuItems];
	
	
    
	return self;
}

-(void) awakeFromNib {
	DLog(@"CALLED - HNSourceViewController: awakeFromNib");
    
	[outlineView registerForDraggedTypes:[NSArray arrayWithObject:HNNodeIndexPathPasteBoardType]];
}


-(void) setAddButtonsMenuItems {
	/*
	NSMenu *popUpAddMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [popUpAddMenu insertItemWithTitle:@"New Project"        action:@selector(addNewProject:)        keyEquivalent:@"" atIndex:0];
	[popUpAddMenu insertItemWithTitle:@"New Experiment"     action:@selector(addNewExperiment:)     keyEquivalent:@"" atIndex:1];
    [popUpAddMenu insertItemWithTitle:@"New Folder"			action:@selector(addNewCollection:)     keyEquivalent:@"" atIndex:2];
    [popUpAddMenu insertItemWithTitle:@"New Parse Template" action:@selector(addNewParseTemplate:)  keyEquivalent:@"" atIndex:3];
    [popUpAddMenu insertItemWithTitle:@"Add Data Files"     action:@selector(addNewData:)           keyEquivalent:@"" atIndex:4];
    [popUpAddMenu insertItemWithTitle:@"Add Graph Template" action:@selector(addNewGraphTemplate:)  keyEquivalent:@"" atIndex:5];
	[popUpAddMenu insertItemWithTitle:@"Add Watched Folder" action: nil   keyEquivalent:@"" atIndex:6];
	 */
	
	/*
	// Type of Collection = HNaddProjectType
	NSDictionary *userInfo = @{ HNAddCollectionOfType : HNaddProjectType };

	[self postAddNewDataOrCollectionNotificationOfType: HNAddCollectionNotification
							 withCollectionDetails: userInfo];
	 */
	/*
	 NSString *menuTitle = [menuItemDetails valueForKey: @"title"];
	NSString *notificationType = [menuItemDetails valueForKey: @"notificationType"];
	NSDictionary *userInfo = [menuItemDetails valueForKey: @"userInfo"];
	NSString *keyEquivalent = [menuItemDetails valueForKey: @"keyEquivalent"];
	 */
	
	// Item 0 - Add New Project Button
    HNMenuItem *projectMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Project" action: nil keyEquivalent: @""];
    NSDictionary *projectUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel, HNAddCollectionOfType : HNaddProjectType };
    
    [projectMenuItem setUserInfo: projectUserInfo];
    [projectMenuItem setNotificationType: HNAddCollectionNotification];
    
	
    // Item 1 - Add New Experiment
    HNMenuItem *experimentMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Experiment" action: nil keyEquivalent: @""];
    NSDictionary *experimentUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel, HNAddCollectionOfType : HNaddExperimentType };
    [experimentMenuItem setUserInfo: experimentUserInfo];
    [experimentMenuItem setNotificationType: HNAddCollectionNotification];
    
    
    
    // Item 2 - Add New Folder
    HNMenuItem *folderMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Folder" action: nil keyEquivalent: @""];
    NSDictionary *folderUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel, HNAddCollectionOfType : HNAddFolderCollection };
    [folderMenuItem setUserInfo: folderUserInfo];
    [folderMenuItem setNotificationType: HNAddCollectionNotification];
    
    // Item 3 - Add New Parse Template
    HNMenuItem *parseTemplateMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Parse Template" action: nil keyEquivalent: @""];
    NSDictionary *parseTemplateUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [parseTemplateMenuItem setUserInfo: parseTemplateUserInfo];
    [parseTemplateMenuItem setNotificationType: HNAddParseTemplateNotification];
    
    // Item 4 - Add New Graph Template
    HNMenuItem *graphTemplateMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Graph Template" action: nil keyEquivalent: @""];
    NSDictionary *graphTemplateUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [graphTemplateMenuItem setUserInfo: graphTemplateUserInfo];
    [graphTemplateMenuItem setNotificationType: HNAddGraphTemplateNotification];
    
    
    // Item 5 - Add New Data Files
    HNMenuItem *dataFilesMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Data" action: nil keyEquivalent: @""];
    NSDictionary *dataFilesUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [dataFilesMenuItem setUserInfo: dataFilesUserInfo];
    [dataFilesMenuItem setNotificationType: HNAddDataFilesNotification];
    
    
    // Item 5 - Add New Watched Folders
    HNMenuItem *watchedFoldersMenuItem = [[HNMenuItem alloc] initWithTitle: @"Add Watched Folder" action: nil keyEquivalent: @""];
    NSDictionary *watchedFoldersUserInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
    [watchedFoldersMenuItem setUserInfo: watchedFoldersUserInfo];
    [watchedFoldersMenuItem setNotificationType: HNAddWatchedFoldersNotification];
	
	
}

@end



#pragma mark -
#pragma mark NSOutlineViewDragAndDrop
@implementation HNSourceViewController (NSOutlineViewDragAndDrop)
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteBoard {
    //NSLog(@"Called - HNAppDelegate: outlineView: writeItems: toPasteboard");
	[pasteBoard declareTypes:[NSArray arrayWithObject:HNNodeIndexPathPasteBoardType] owner:self];
	[pasteBoard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:HNNodeIndexPathPasteBoardType];
    
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)proposedParentItem proposedChildIndex:(NSInteger)proposedChildIndex {
	//NSLog(@"Called - HNAppDelegate: outlineView: validateDrop");
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

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)proposedParentItem childIndex:(NSInteger)proposedChildIndex {
    //NSLog(@"Called - HNAppDelegate: outlineView: acceptDrop");
	
	
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

@end




#pragma mark -
#pragma mark NSOutlineViewDelegate
@implementation HNSourceViewController (NSOutlineViewDelegate)
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    //NSLog(@"CALLED - outlineView:  isGroupItem");
	if ([[(HNTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf]) {
		return NO;
    }
	
	else if  ([[item representedObject] respondsToSelector:@selector(isSpecialGroup)] ) {
		return [[[item representedObject] isSpecialGroup] boolValue];
	}
	else {
		//NSLog(@"%@\n does NOT respond to isSpecialGroup", [item representedObject]);
		return NO;
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
    //NSLog(@"Called - HNAppDelegate: shouldCollapseItem");
	if ([[(HNTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	return [[[item representedObject] canCollapse] boolValue];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    //NSLog(@"called - outlineView:shouldExpandItem");
	if ([[(HNTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf]) {
		return NO;
    }
	
	if ([[item representedObject] respondsToSelector:@selector(canExpand)] ) {
		//NSLog(@"item can respond to \"canExpand\" and: %hhu", [[[item representedObject] canExpand] boolValue]);
        
		return [[[item representedObject] canExpand] boolValue];
	}
	else {
		///NSLog(@"%@\n\ndoes not respond to \"canExpand\"", [item representedObject]);
        return NO;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	//NSLog(@"Called - HNAppDelegate: shouldSelectItem");
	
	//HNTreeNode *selectedNode = [item representedObject];
	// NSLog(@"selectedNode = %@,   isLeaf = %lu", selectedNode.displayName, [[selectedNode isLeaf] integerValue]);
	return [[(HNTreeNode *)[item representedObject] isSelectable] boolValue];
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
	NSLog(@"CALLED - SourceListDelegate: outlineViewSelectionDidChange");
	DLog(@"identifier = %@", [[notification object] identifier]);
	DLog(@"for outlineView: %@", [[notification object] description]);
	
	if ([[[notification object] identifier] isEqualToString: @"sourceList"]) {
		
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
	
	


@end