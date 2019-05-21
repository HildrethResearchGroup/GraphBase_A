//
//  HNAppDelegate+HNCoreDataManagement.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 10/19/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNAppDelegate.h"
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "HNAppDelegate+HNCoreDataManagement.h"
#import "PreCompiledHeaders.h"
#import "HNCoreDataHeaders.h"
#import "HNTreeController.h"
#import "HNSourceViewController.h"
#import "HNOutlineView.h"
#import "HNDataViewController.h"

#import "HNAccessoryView.h"

@implementation HNAppDelegate (HNCoreDataManagement)



#pragma mark -
#pragma mark Adding Collections
-(HNTreeNode *) addCollectionFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: addCollectionFromNotification");
	
	NSString *collectionType = [[note userInfo] objectForKey: HNCollectionOfType];
	
	//NSDictionary *collectionDetails = @{ HNCollectionOfType: typeOfCollection };
	NSIndexPath *insertionPath;
    
    insertionPath = [[note userInfo] objectForKey: HNTargetTreeNodeNSIndexPathKey];
    
    if (!insertionPath) {
        if ([self.treeController respondsToSelector:@selector(indexPathForInsertion)]) {
            insertionPath = [self.treeController indexPathForInsertion];
        }
        else {
            NSLog(@"treeController does NOT respond to indexPathForInsertion");
            NSLog(@"%@", [self.treeController class]);
        }
    }
    //insertionPath = [insertionPath indexPathByAddingIndex: 0];
	
	
	
	if (!insertionPath) {
		DLog(@"NO insertion path");
		return nil;
	}
	
	HNTreeNode *newNode = [self addNewCollectionOfType: collectionType withInsertionPath: insertionPath];
    
    // Select newNode, set focus, and set for editing
    HNOutlineView *sourceList = [self.sourceListViewController outlineView];
    NSTreeNode *treeNode = [self.treeController nodeAtIndexPath: insertionPath];
    [sourceList noteNumberOfRowsChanged];
    //DLog(@"sourceList = %@" ,sourceList);
    NSInteger row = [sourceList rowForItem: treeNode];
    DLog(@"row = %lu", row);
    [sourceList scrollRowToVisible:row];
    [sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [sourceList editColumn:0 row:row withEvent:nil select:YES];
    
    
    
    
    
    //[self saveAction: self];
	return newNode;
	
}


-(HNTreeNode *) addNewCollectionOfType: (NSString *) collectionType withInsertionPath: (NSIndexPath *) insertionPath  {
	
	if (!collectionType) {
		collectionType = HNProjectCollectionType;
	}
	
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	
	
	
	//Create Group Node
	HNTreeNode * newTreeNode = [NSEntityDescription insertNewObjectForEntityForName:@"HNTreeNode"
															 inManagedObjectContext:[self managedObjectContext]];
	
	newTreeNode.isLeaf = [NSNumber numberWithBool: NO];
	
    
    
    NSPredicate *collectionPredicate = [NSPredicate predicateWithFormat:@"typeName MATCHES %@", collectionType];
    
    
	// CHANGED
    /*
	if ([collectionType isEqualToString: HNFolderCollectionType]) {
		//[newTreeNode setCollectionType:HNFolderCollectionType];
		[undoManager setActionName: @"Add Folder"];
	}
	else if ([collectionType isEqualToString: HNProjectCollectionType]) {
		//[newTreeNode setCollectionType: HNProjectCollectionType];
		[undoManager setActionName: @"Add Project"];
	}
    else if ([collectionType isEqualToString: HNExperimentCollectionType]) {
		//[newTreeNode setCollectionType: HNExperimentCollectionType];
		[undoManager setActionName: @"Add Experiment"];
	}
     */
	
    
    NSSet *fetchedCollections = [self.managedObjectContext fetchObjectsForEntityName: @"HNCollectionType" withPredicate: collectionPredicate];
    HNCollectionType *collectionTypeIn = [[fetchedCollections allObjects] firstObject];
    NSString *underActionName = [NSString stringWithFormat: @"Add %@", [collectionTypeIn displayName]];
    //DLog(@"collectionTypeIn.displayName = %@", [collectionTypeIn displayName]);
    //DLog(@"collectionTypeIn.typeName = %@", collectionTypeIn.typeName);
    
    if (![collectionTypeIn respondsToSelector:@selector(displayName)]) {
        DLog(@"collectionTypeIn does NOT respond to displayName");
    }
    else {
        //DLog(@"%@ = ", [collectionTypeIn performSelector:@selector(displayName)]);
    }
    
    [newTreeNode setCollectionType: collectionTypeIn];
    [undoManager setActionName: underActionName];
    
	
	newTreeNode.displayName = newTreeNode.collectionType.displayName;
	//DLog(@"newTreeNodedisplayName = %@", newTreeNode.displayName);
	
	
	// Insert newTreeNode into treeController
	// CHANGED
	/*
	 if ([self.treeController respondsToSelector:@selector(indexPathForInsertion)]) {
	 NSIndexPath *insertionPath = [self.treeController indexPathForInsertion];
	 [self.treeController insertObject:newTreeNode atArrangedObjectIndexPath: insertionPath];
	 }
	 else {
	 NSLog(@"treeController does NOT respond to indexPathForInsertion");
	 NSLog(@"%@", [self.treeController class]);
	 return newTreeNode;
	 }
	 */
	
	if (!insertionPath) {
		DLog(@"NO insertionPath provide");
		return newTreeNode;
	}
	else {
		[self.treeController insertObject:newTreeNode atArrangedObjectIndexPath: insertionPath];
	}
	
	
	
	
	// newTreeNode should have a parent now
	// Set default graph and parse templates from parent node defaults
	if ([newTreeNode parent]) {
		//DLog(@"parent of %@    =   %@", newTreeNode.displayName, newTreeNode.parent.displayName);
		
		[newTreeNode setDefaultsFromParent];
	}
	else {
		DLog(@"%@ does NOT have a parent", newTreeNode.displayName);
	}
	
	
	//[self.dataViewController updateAll];
	[undoManager endUndoGrouping];
	
	//DLog(@"FINISHED - newGroupWithCollectionDetails = %@", newTreeNode);
	return newTreeNode;
}



#pragma mark -
#pragma mark Adding Data Files
-(BOOL) addDataFilesFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: addDataFilesFromNotification");
	BOOL success = YES;
	
	
	
	if ([self.treeController arrangedObjects]  == nil) {
		NSIndexPath *insertionPath = [self.treeController indexPathForInsertion];
		[self addNewCollectionOfType: HNProjectCollectionType withInsertionPath: insertionPath];
	}
	
	
	NSString *sourceOfDataFiles = [[note userInfo] objectForKey: HNaddFilesFrom];
	
	
	if ([sourceOfDataFiles isEqualToString: HNAddFilesFromNSOpenPanel]) {
		[self openPanelForImportingData: self];
	}
	
	else if ([sourceOfDataFiles isEqualToString: HNAddFilePathsFromPasteBoard]) {
		NSArray *filePaths = [[note userInfo] objectForKey: HNArrayOfDataFilePathsToAddKey];
		NSDictionary *userInfo = [note userInfo];
		NSURL *targetNodeURI = [userInfo objectForKey: HNTreeNodeURIKey];
		HNTreeNode *targetTreeNode;
		
		if (targetNodeURI) {
			
			targetTreeNode = [self treeNodeFromURIKey: targetNodeURI];
		}
		else {
			DLog(@"NO targetNodeURI");
			targetTreeNode = [[[self.treeController selectedObjects] firstObject] representedObject];
		}
		
		
		[self createNewDataItemsFromFilePathURLs: [self convertFilePathsToURLS: filePaths]
							  andPlaceInTreeNode: targetTreeNode];
	}
	else {
		success = NO;
	}
	
	
	return success;
}





-(IBAction) openPanelForImportingData:(id)sender {
	DLog(@"CALLED - HNAppDelegate: openPanelForImportingData");
	
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:     NO];
	[openPanel setCanCreateDirectories:     NO];
	[openPanel setAllowsMultipleSelection:  YES];
    [openPanel setAllowsOtherFileTypes:     YES];
    
    
    
    
    // Get ParseTemplate File Types/Extensions from User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *fileTypeExtensions = [defaults objectForKey: HNExtensionsForDataFileTypesKey];
	//[openPanel setAllowedFileTypes: fileTypeExtensions];
    
    
    // Set up accessory view
        // Set file types string in the accessories comboBox
    NSMutableString *fileTypesString = [NSMutableString stringWithFormat: @""];
    int i = 0;
    for (i = 0;  i <= [fileTypeExtensions count] - 2; ++i) {
        [fileTypesString appendFormat: @".%@, ", [fileTypeExtensions objectAtIndex: i]];
    }
    
    if ([fileTypeExtensions count] - 1 >= i) {
        NSString *nextExtension = [fileTypeExtensions objectAtIndex: i];
        [fileTypesString appendFormat: @".%@", nextExtension];
    }
    
    DLog(@"fileTypesString = %@", fileTypesString);
    NSComboBox *fileExtensionsBox = [accessoryView_openDataFiles filterDescriptions];
    [fileExtensionsBox removeAllItems];
    [fileExtensionsBox addItemWithObjectValue: fileTypesString];
    [fileExtensionsBox addItemWithObjectValue: @"All file types"];
    [fileExtensionsBox selectItemAtIndex: 0];
    //NSMenuItem *topComboBox = [[fileExtensionsBox menu] itemAtIndex: 0];
    //[topComboBox setTitle: fileTypesString];
    
    
        // Set delegates
    [openPanel setDelegate: accessoryView_openDataFiles];
    
    [openPanel setAccessoryView: accessoryView_openDataFiles];
    [accessoryView_openDataFiles setOpenPanel: openPanel];
    
    
    DLog(@"openPanel.accessoryView = %@", openPanel.accessoryView);
    DLog(@"fileExtensionsBox = %@", fileExtensionsBox);
    //DLog(@"topComboBox = %@", topComboBox);
    
    
	

	
	[openPanel beginSheetModalForWindow: [self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            HNTreeNode *selectedNode = [[self.treeController selectedObjects] firstObject];
            NSArray *newFileURLs = [openPanel URLs];
            
            // Check to see if a new fileType/extension has been added
            // 1) Get list of available file extensions
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *currentExtensions = [defaults objectForKey: HNExtensionsForDataFileTypesKey];
            NSMutableArray *newExtensions = [NSMutableArray array];
            
            // 2) iterate through new files and check extensions to see if they are already known
            for (NSURL *nextFileURL in newFileURLs) {
                NSString *nextExtension = [nextFileURL pathExtension];
                if ([newFileURLs arrayContainsString: nextExtension] == NO) {
                    // Need to add array to allowable defaults
                    [newExtensions addObject: nextExtension];
                }
                
            }
            
            // 3) Add any new extensions to defaults if necessary
            if ([newExtensions count] > 0) {
                DLog(@"New extension - %@ -  has been found", newExtensions);
                // new extensions have been found.  Add them to the defaults
                NSMutableArray *mergedExtensions = [NSMutableArray arrayWithArray: currentExtensions];
                [mergedExtensions addObjectsFromArray: newExtensions];
                
                [defaults setObject: [NSArray arrayWithArray: mergedExtensions] forKey: HNExtensionsForDataFileTypesKey];
            }
            
            
            
            [self createNewDataItemsFromFilePathURLs: newFileURLs
                                  andPlaceInTreeNode: selectedNode];
        }
        else {
            [openPanel close];
        }
    }];
}


-(BOOL) createNewDataItemsFromFilePathURLs: (NSArray *) filePathURLs
						andPlaceInTreeNode: (HNTreeNode *) targetTreeNode {
	DLog(@"CALLED - HNAppDelegate: createNewDataItemsFromFilePathURLs");
	
	int failureCount = 0;
	
	BOOL autoSave = YES;
	
	if (!targetTreeNode) {
		DLog(@"NO targetTreeNode");
		HNTreeNode *selectedNode = [[[self.treeController selectedObjects] lastObject] representedObject];
		targetTreeNode = selectedNode;
	}
	
	int numberOfFiles = (int) [filePathURLs count];
	
	if (numberOfFiles < 1) {
		return NO;
	}
	else if (numberOfFiles == 1) {
		NSURL *nextURL = [filePathURLs firstObject];
		[self createNewDataItemFromFileURL: nextURL
						andPlaceInTreeNode: targetTreeNode
							  withAutoSave: autoSave];
	}
	else {
		// More than one file path
		// Set update to NO and needsSave to yes
		NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
		[undoManager beginUndoGrouping];
		[undoManager setActionName: @"Add Data Files"];
		NSMutableArray *newDataItems = [NSMutableArray array];
		autoSave = NO;
		
		[targetTreeNode willChangeValueForKey: @"dataItems"];
		
		for (NSURL *nextURL in filePathURLs)  {
			HNDataItem *newDataItem = [self createNewDataItemFromFileURL: nextURL
													  andPlaceInTreeNode: targetTreeNode
															withAutoSave: autoSave];
			
			if (newDataItem) {
				[newDataItems addObject: newDataItem];
			}
			else {
				++failureCount;
			}
		}
		
		
		
		// Initial save on managedObjectContext to permenantly set the object IDs
		[self saveAction: self];
		
		
		// set the localized resource path for the new dataItems now that the newDataItems have been saved
		NSURL *applicationSupport = [self applicationFilesDirectory];
		for (HNDataItem *nextDataItem in newDataItems) {
            if (!nextDataItem.localizedResourcePath) {
                [nextDataItem setLocalizedResourcePathFrom: applicationSupport];
            }
		}
		
		// Save changes to dataItems
		[self saveAction: self];
		
		[targetTreeNode didChangeValueForKey: @"dataItems"];
		// Add new dataItems to dataItemsArrayController
		// CHANGED
		[self.dataItemsArrayController addObjects: newDataItems];
		//[self.treeController rearrangeObjects];
		
		//[self.treeController rearrangeObjects];
		[undoManager endUndoGrouping];
	}
	
	
	if (failureCount != 0) {
		return NO;
	}
	
	
	return YES;
}


-(HNDataItem *) createNewDataItemFromFileURL: (NSURL *) filePathURL
						  andPlaceInTreeNode: (HNTreeNode *) targetTreeNode
								withAutoSave: (BOOL) yesNoSave {
	DLog(@"CALLED - HNAppDelegate: createNewDataItemFromFileURL");
	// Check to see if file exists at URL
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if ( ![fm fileExistsAtPath: [filePathURL path]] ) {
		DLog(@"File does not exists at filePath: %@", [filePathURL path]);
		return nil;
	}
    
	
	// Set up undoManager
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName: @"Add Data File"];
	
	if (yesNoSave == YES) {
		[targetTreeNode willChangeValueForKey: @"dataItems"];
	}
	
	
	// Create a new dataItem
	HNDataItem *newDataItem;
	newDataItem = [NSEntityDescription
				   insertNewObjectForEntityForName:@"HNDataItem"
				   inManagedObjectContext:[self managedObjectContext]];
	
	
	// Put newDataItem into the correction location within the treeController
	// this should also the the treeNode/dataItems relationship
	if (!targetTreeNode) {
		targetTreeNode = [[[self.treeController selectedNodes] lastObject] representedObject];
	}
	
	
	if (!targetTreeNode) {			// Put in at root object if no selected nodes
		targetTreeNode = [[[self.treeController rootNodes] firstObject] representedObject];
	}
	
	if ([targetTreeNode isKindOfClass: [HNTreeNode class]]) {
		// Make sure selectedNode is an HNTreeNode
		//DLog(@"SUCCESS:  %@ is of class %@", selectedNode, [selectedNode class]);
		[targetTreeNode  addDataItemsObject: newDataItem];
	}
	else {
		DLog(@"FAIL:  %@ is of class %@", targetTreeNode, [targetTreeNode class]);
	}
	
	
	
	
	// Fill in non-default newDataItem values
	[newDataItem setValue: [filePathURL relativePath] forKey: @"filePath"];
	[newDataItem setValue: [newDataItem fileName] forKey: @"displayName"];
    
	[newDataItem setDefaultCropRange];
	
	// Fill in any default values from parent treeNode
	[newDataItem setDefaultsFromParent];
	
	
	
	
	// TEST
	// Save changes to managedObjectContext, set localizedResoucePath based upon objectID, save again and then add to dataItemsArrayController
	if (yesNoSave) {
        // Save
		[self saveAction: nil];
		
        // Conduct actions that only occur if that dataItem has been saved
        [newDataItem setLocalizedResourcePathFrom: [self applicationFilesDirectory]];
		// Manually add newDataItem to dataItemsArrayController to register and update any table or tab vies using KVC/KVO
		DLog(@"Add Data Items to array Controller");
		[self.dataItemsArrayController addObject: newDataItem];
		//[self.treeController rearrangeObjects];
		[targetTreeNode didChangeValueForKey: @"dataItems"];
	}
	
	// END Adding Files loop
	
	
	[undoManager endUndoGrouping];
	return newDataItem;
}



#pragma mark -
#pragma mark Graph Templates
-(BOOL) addGraphTemplateFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: addGraphTemplateFromNotification");
	BOOL success = YES;
	
	
	NSString *sourceOfDataFiles = [[note userInfo] objectForKey: HNaddFilesFrom];
    
    // Set up targetTreeNode
    NSURL *targetTreeNodeURI = [[note userInfo] objectForKey: HNTreeNodeURIKey];
    HNTreeNode *targetTreeNode;
    
    if (targetTreeNodeURI) {
        targetTreeNode = [self treeNodeFromURIKey: targetTreeNodeURI];
    }
    if (!targetTreeNode) {
        targetTreeNode = [[self.treeController selectedObjects] firstObject];
    }
    
    
	
	
	if ([sourceOfDataFiles isEqualToString: HNAddFilesFromNSOpenPanel]) {
		[self openPanelForAddingGraphTemplate: note];
	}
    else if ( [sourceOfDataFiles isEqualToString: HNAddFilePathsFromPasteBoard] ) {
        NSArray *filePaths = [[note userInfo] objectForKey: HNArrayOfGraphTemplateFilePathsToAddKey];
        if ([filePaths count] > 0) {
            NSArray *fileURLs = [self convertFilePathsToURLS: filePaths];
            [self createNewGraphTemplatesFromFilePathURLs: fileURLs andPlaceInTreeNode: targetTreeNode];
        }
    }
	
	
	return success;
	
}

-(void) openPanelForAddingGraphTemplate: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: addGraphTemplateFromNotification");
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories: NO];
	[openPanel setCanCreateDirectories: NO];
	[openPanel setAllowsMultipleSelection: YES];
	NSArray	*fileTypesArray = @[ @"dgraph" ];
	[openPanel setAllowedFileTypes: fileTypesArray];
	
	
	
	[openPanel beginSheetModalForWindow: [self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
			NSArray *filePaths = [openPanel URLs];
			
			HNTreeNode *selectedNode = [[[self.treeController selectedNodes] lastObject] representedObject];
			
			if ([filePaths count] == 1) {
				[self createNewGraphTemplateFromFilePathURL: [filePaths objectAtIndex: 0] andPlaceInTreeNode: selectedNode withAutoSave: YES];
			}
			else {
				[self createNewGraphTemplatesFromFilePathURLs: [openPanel URLs] andPlaceInTreeNode: selectedNode];
			}
        }
        else {
            [openPanel close];
        }
    }];
}

-(BOOL) createNewGraphTemplatesFromFilePathURLs: (NSArray *) filePathURLs
							 andPlaceInTreeNode: (HNTreeNode *) targetTreeNode {
	DLog(@"CALLED - HNAppDelegate: createNewGraphTemplatesFromFilePathURLs");
	BOOL success = YES;
	
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName: @"Add Data Files"];
	
	if (!targetTreeNode) {
		targetTreeNode = [[[self.treeController selectedNodes] lastObject] representedObject];
	}
	
	NSMutableArray *newGraphTemplates = [NSMutableArray array];
	
	BOOL autoSave = NO;
	
	for (NSURL *nextURL in filePathURLs)  {
		HNGraphTemplate *newGraphTemplate = [self createNewGraphTemplateFromFilePathURL: nextURL andPlaceInTreeNode: targetTreeNode withAutoSave: autoSave];
		[newGraphTemplates addObject: newGraphTemplate];
	}
	
	[self saveAction: self];
	
	[self.graphTemplateListArrayController setSelectedObjects: newGraphTemplates];
	[undoManager endUndoGrouping];
	
	
	return success;
}



-(HNGraphTemplate *) createNewGraphTemplateFromFilePathURL: (NSURL *) filePathURL
										andPlaceInTreeNode: (HNTreeNode *) targetTreeNode
											  withAutoSave: (BOOL) yesNoSave {
	DLog(@"CALLED - HNAppDelegate: createNewGraphTemplateFromFilePathURL");
	// Check to see if file exists at URL
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if ( ![fm fileExistsAtPath: [filePathURL path]] ) {
		DLog(@"File does not exists at filePath: %@", [filePathURL path]);
		return nil;
	}
	
	// Set up undoManager
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName: @"Add Graph Template"];
	
	
	// Create a new graphTemplate
	HNGraphTemplate *newGraphTemplate;
	newGraphTemplate = [NSEntityDescription
						insertNewObjectForEntityForName:@"HNGraphTemplate"
						inManagedObjectContext:[self managedObjectContext]];
	
	// Set values
	[newGraphTemplate setFilePath: [filePathURL relativePath]];
	[newGraphTemplate setDisplayName: [newGraphTemplate fileName]];
	
	
	//START: Put newGraphTemplate into correct HNTreeNode
	
	// CHANGED
	// Get selected HNTreeNode.  NOTE - put in the lowest selected treeNode
	if (!targetTreeNode) {
		targetTreeNode = [[[self.treeController selectedNodes] lastObject] representedObject];
	}
	
	
	// If no selected nodes then select rootNode
	// FIX:  Currently assumes rootNodes are all generic HNTreeNode collections.  What if I add specialized root nodes?
	if (!targetTreeNode) {
		targetTreeNode = [[self.treeController rootNodes] firstObject];
	}
	
	
	// Check class of selected node and add newGraphTemplate to nodes' graphTemplates relationship
	if ([targetTreeNode isKindOfClass: [HNTreeNode class]]) {
		// Make sure selectedNode is an HNTreeNode
		//DLog(@"SUCCESS:  %@ is of class %@", selectedNode, [selectedNode class]);
		if (yesNoSave == YES) {
			[targetTreeNode willChangeValueForKey: @"graphTemplate"];
		}
		
		[targetTreeNode  addGraphTemplatesObject: newGraphTemplate];
		
		if (yesNoSave == YES) {
			[targetTreeNode didChangeValueForKey: @"graphTemplate"];
		}
		
		if ( ![targetTreeNode defaultGraphTemplate]) {
			// Set newGraphTemplate as default if selectedNode does not already have a defaultGraphTemplate
			
			if (yesNoSave == YES) {
				[targetTreeNode willChangeValueForKey: @"defaultGraphTemplate"];
			}
			
			[targetTreeNode setDefaultGraphTemplate: newGraphTemplate];
			
			if (yesNoSave == YES) {
				[targetTreeNode didChangeValueForKey: @"defaultGraphTemplate"];
			}
		}
		
	}
	else {
		DLog(@"FAIL add Graph Template:  %@ is of class %@", targetTreeNode, [targetTreeNode class]);
		return nil;
	}
	
	// Manually add newGraphTemplate to graphTemplatesArrayController to register and update any table or tab vies using KVC/KVO
    [self.allGraphTemplateListArrayController addObject: newGraphTemplate];
	[self.graphTemplateListArrayController addObject: newGraphTemplate];
	
	// PROBLEM - does not work.  Error says that HNTreeNode is not KVC compliant for allGraphTemplates
	// TEMP SOLUTION - rearrange entire object model - poor solution
	//[self.treeController rearrangeObjects];
	[self.graphTemplateListArrayController setSelectedObjects: @[ newGraphTemplate ]];
	
	// Verify the newGraphTemplate is in correctNode
	DLog(@"newGraphTemplate is in:   %@", [newGraphTemplate treeNodes]);
	// END: Put newGraphTemplate into correct HNTreeNode
	
	
	if (yesNoSave) {
		[self saveAction: self];
	}
	
	DLog(@"FINISHED - HNAppDelegate: createNewGraphTemplateFromFilePathURL");
	[undoManager endUndoGrouping];
	return newGraphTemplate;
}



#pragma mark -
#pragma mark Parse Templates
-(BOOL) addParseTemplateFromNotification: (NSNotification *) note {
    DLog(@"CALLED - AppDelegate:  addParseTemplateFromNotification");
	BOOL success = YES;
    
    
    NSDictionary *userInfo = [note userInfo];
	NSURL *targetTreeNodeURI = [userInfo objectForKey: HNTreeNodeURIKey];
    HNTreeNode *targetTreeNode;
    
    if (targetTreeNodeURI) {
        targetTreeNode = [self treeNodeFromURIKey: targetTreeNodeURI];
    }
    
    if (!targetTreeNode) {
        targetTreeNode = [[self.treeController selectedObjects] firstObject];
    }
    if (!targetTreeNode) {
        targetTreeNode = [[[self.treeController rootNodes] firstObject] representedObject];
    }
    
    // Check to see where the parse template should come from
    NSString *addFrom = [userInfo objectForKey: HNaddFilesFrom];
    
    if ([addFrom isEqualToString: HNAddFilesUsingBlankFile]) {
        // Create new blank parse template and check success
        DLog(@"[addFrom isEqualToString: HNAddFilesUsingBlankFile]");
        if (![self createNewEmptyParseTemplateAndPlaceInTreeNode: targetTreeNode withAutoSave: YES]) {
            success = NO;
            return success;
        };
    }
    else if ([addFrom isEqualToString: HNAddFilesFromNSOpenPanel]) {
        [self openPanelForImportingParseTemplates: self];
        
    }
    else if ( [addFrom isEqualToString: HNAddFilePathsFromPasteBoard ]  ) {
        NSArray *filePaths = [[note userInfo] objectForKey:HNArrayOfParseTemplateFilePathsToAddKey];
        if ([filePaths count] > 0) {
            NSArray *fileURLs = [self convertFilePathsToURLS: filePaths];
            [self createNewParseTemplatesFromFiles: fileURLs andPlaceInTreeNode: targetTreeNode];
        }
    }
    
	
	return success;
}


-(void) openPanelForImportingParseTemplates: (id) sender {
    DLog(@"CALLED - HNAppDelegate: openPanelForImportingParseTemplates");
	
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories: NO];
	[openPanel setCanCreateDirectories: NO];
	[openPanel setAllowsMultipleSelection: YES];
    
    // Get ParseTemplate File Types/Extensions from User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *fileTypeExtensions = [defaults objectForKey: HNExtensionsForParseTemplatesKey];
	[openPanel setAllowedFileTypes: fileTypeExtensions];
		
	[openPanel beginSheetModalForWindow: [self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *filesFromOpenPanel = [openPanel URLs];
            if ([filesFromOpenPanel count] > 0) {
                HNTreeNode *targetTreeNode = [[self.treeController selectedObjects] firstObject];
                
                [self createNewParseTemplatesFromFiles: filesFromOpenPanel
                                    andPlaceInTreeNode: targetTreeNode];
            }
        }
        else {
            [openPanel close];
        }
    }];
  
}



-(HNParseTemplate *) createNewEmptyParseTemplateAndPlaceInTreeNode: (HNTreeNode *) targetTreeNode
                                                 withAutoSave: (BOOL) yesNoSave {
    DLog(@"CALLED - HNAppDelegate: createNewEmptyParseTemplateAndPlaceInTreeNode");
    // Set up undoManager
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
    // LOCALIZATION NEEDED
	[undoManager setActionName: @"Add Parse Template"];
	
	if (!targetTreeNode) {
        DLog(@"NO targetTreeNode");
		return nil;
	}
	
	HNParseTemplate *newParseTemplate  = [NSEntityDescription insertNewObjectForEntityForName: @"HNParseTemplate"
																	   inManagedObjectContext: [self managedObjectContext]];
    // LOCALIZATION NEEDED
    newParseTemplate.displayName = @"New Parse Template";
	
	[newParseTemplate setTreeNodes: [NSSet setWithObject: targetTreeNode]];
	
	if (targetTreeNode.defaultParseTemplate == nil) {
		[targetTreeNode setDefaultParseTemplate: newParseTemplate];
        
        NSString *alertMessage = [NSString stringWithFormat: @"How should %@ Parse Template be applied?\n1) Set as default template for all collections and data files\n2)Set as default if none exist?\n3)Just import?", targetTreeNode.displayName];
        NSString *alternateButtonMessage    = @"1) Set all";
        NSString *defaultButtonMessage      = @"3) Just Import";
        NSString *otherButton               = @"2) Set if none";
        NSAlert *setDefaultParser = [NSAlert alertWithMessageText: alertMessage
                                                    defaultButton: defaultButtonMessage 
                                                  alternateButton: alternateButtonMessage 
                                                      otherButton: otherButton
                                        informativeTextWithFormat: @""];
        
        NSInteger response = [setDefaultParser runModal];
        
        if (response == NSAlertOtherReturn) {
        }
        else if (response == NSAlertDefaultReturn) {
            NSSet *dataItems = [targetTreeNode allDataItems];
            for (HNDataItem *nextDataItem in dataItems) {
                [nextDataItem setParseTemplate: newParseTemplate];
            }
            
            for (HNTreeNode *nextTreeNode in [targetTreeNode allTreeNodeChildren]) {
                [nextTreeNode setDefaultParseTemplate: newParseTemplate];
            }
            
        }
        else if ( response == NSAlertAlternateReturn) {
            NSSet *dataItems = [targetTreeNode allDataItems];
            for (HNDataItem *nextDataItem in dataItems) {
                if (nextDataItem.parseTemplate == nil) {
                    [nextDataItem setParseTemplate: newParseTemplate];
                }
            }
            
            for (HNTreeNode *nextTreeNode in [targetTreeNode allTreeNodeChildren]) {
                if (nextTreeNode.defaultParseTemplate == nil) {
                    [nextTreeNode setDefaultParseTemplate: newParseTemplate];
                }
            }
        }
	}
    
    
    
    if (!targetTreeNode) {
		// Get a node from the selected nodes list
		targetTreeNode = [[[self.treeController selectedNodes] lastObject] representedObject];
	}
	
	
	// If no selected nodes then select rootNode
	// FIX:  Currently assumes rootNodes are all generic HNTreeNode collections.  What if I add specialized root nodes?
	if (!targetTreeNode) {
		targetTreeNode = [[self.treeController rootNodes] firstObject];
	}
	
	// Check class of selected node and add newGraphTemplate to nodes' graphTemplates relationship
	if ([targetTreeNode isKindOfClass: [HNTreeNode class]]) {
		// Make sure selectedNode is an HNTreeNode
		//DLog(@"SUCCESS:  %@ is of class %@", selectedNode, [selectedNode class]);
		[targetTreeNode willChangeValueForKey: @"parseTemplates"];
		[targetTreeNode  addParseTemplatesObject: newParseTemplate];
		
		if ( ![targetTreeNode defaultParseTemplate]) {
			// Set newGraphTemplate as default if selectedNode does not already have a defaultGraphTemplate
			[targetTreeNode willChangeValueForKey: @"defaultParseTemplate"];
			[targetTreeNode setDefaultParseTemplate: newParseTemplate];
			[targetTreeNode didChangeValueForKey: @"defaultParseTemplate"];
		}
	}
	else {
		DLog(@"FAIL add Parse Template:  %@ is of class %@", targetTreeNode, [targetTreeNode class]);
		return nil;
	}
	
	// Manually add newParseTemplate to parseTemplateArrayController to register and update any table or tab vies using KVC/KVO
	//[self.parserListArrayController addObject: newParseTemplate];
	// PROBLEM - does not work.  Error says that HNTreeNode is not KVC compliant for allParseTemplates
	// TEMP SOLUTION - rearrange entire object model - poor solution
	//[self.treeController rearrangeObjects];
	
	[self.allParserListArrayController addObject: newParseTemplate];
	[self.allParserListArrayController rearrangeObjects];
	
	
	
	// Verify the newGraphTemplate is in correctNode
	//DLog(@"newParseTemplate is in:   %@", [newParseTemplate treeNodes]);
	// END: Put newGraphTemplate into correct HNTreeNode
	
	[targetTreeNode didChangeValueForKey: @"parseTemplates"];
	
	//[newParseTemplate dictionaryForArchive];
	
	
    if (yesNoSave) {
        [self saveAction: self];
    }
    
    [undoManager endUndoGrouping];
	return newParseTemplate;
	
}

-(NSArray *) createNewParseTemplatesFromFiles: (NSArray *) arrayOfURLs
                           andPlaceInTreeNode: (HNTreeNode *) targetTreeNode {
    DLog(@"CALLED - HNAppDelegate: createNewParseTemplatesFromFiles:  andPlaceInTreeNode");
    NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
    // LOCALIZATION NEEDED
	[undoManager setActionName: @"Import Parse Templates"];
    
    
    NSMutableArray *newParseTemplates = [NSMutableArray array];
    
    for (NSURL *nextURL in arrayOfURLs) {
        DLog(@"nextURL = %@", nextURL);
        HNParseTemplate *newParseTemplate = [self createNewParseTemplateFromFile: nextURL
                                                              andPlaceInTreeNode: targetTreeNode
                                                                    withAutoSave: NO];
        if (newParseTemplate) {
            [newParseTemplates addObject: newParseTemplate];
        }
    }
    DLog(@"Finished making parseTemplates");
    //[self.allParserListArrayController addObjects:newParseTemplates];
	//[self.allParserListArrayController rearrangeObjects];
    
    [undoManager endUndoGrouping];
    return newParseTemplates;
}



-(HNParseTemplate *) createNewParseTemplateFromFile: (NSURL *) fileURL
                                 andPlaceInTreeNode: (HNTreeNode *) targeTreeNode
                                       withAutoSave: (BOOL) yesNoSave {
    DLog(@"CALLED - HNAppDelegate: createNewParseTemplateFromFile: (individual)");
    
    NSString *filePath = [fileURL path];
    if (!filePath || !targeTreeNode) {
        return nil;
    }
	
	// Create new ParseTemplate
	HNParseTemplate *newParseTemplate = [self createNewEmptyParseTemplateAndPlaceInTreeNode: targeTreeNode withAutoSave: NO];
	
	
	
	
	// Get Parse template details from filePath
	NSFileManager *fm = [NSFileManager defaultManager];
	
	
	// Check file to make sure that is the correct type and it exists
	NSString *parseTemplateExtension = [[[NSUserDefaults standardUserDefaults] objectForKey: HNExtensionsForParseTemplatesKey] firstObject];
	NSString *fileExtension = [filePath pathExtension];
	BOOL fileExtensionsMatch = [fileExtension isEqualToString: parseTemplateExtension];
	
	if (fileExtensionsMatch == NO) {
		DLog(@"ERROR:  Parse Template file:   %@ is not the correct fileType:  %@", [filePath lastPathComponent], parseTemplateExtension);
		return newParseTemplate;
	}
	
	if (![fm fileExistsAtPath: filePath]) {
		DLog(@"ERROR:  Parse Template does not exist at: %@", filePath);
		return newParseTemplate;
	}
	
	
	// File exists and it the correct file type
	// Get Data and open dictionary
	NSDictionary *parseTemplateAttributesFromFile = [NSDictionary dictionaryWithContentsOfFile: filePath];
	
	if ( (!parseTemplateAttributesFromFile)  ||  ([[parseTemplateAttributesFromFile allValues] count] <= 0) ) {
		return newParseTemplate;
	}
	
	
	// START:  ITERATE over parseTemplateAttributesFromFile and set values of newParseTemplate
		// Keys not to iterate over
	NSArray *skipKeysArray = @[@"dateImported", @"dateLastModified", @"storedUUDI"];
	
	for (NSString *nextKey in parseTemplateAttributesFromFile) {
		
		// see if nextKey needs to be skipped
		BOOL skipKey = NO;
		for (NSString *nextSkipKey in skipKeysArray)  {
			if ([nextKey isEqualToString: nextSkipKey]) {
				skipKey = YES;
				break;
			}
		}
		
		// nextKey does not need to be skipped, set values to newParseTemplate
		if (skipKey == NO) {
			SEL nextSelector = NSSelectorFromString(nextKey);
			
			if ([newParseTemplate respondsToSelector: nextSelector]) {
                DLog(@"Setting: %@", nextKey);
				id nextValue = [parseTemplateAttributesFromFile objectForKey: nextKey];
				if (nextValue) {
					[newParseTemplate setPrimitiveValue: nextValue forKey: nextKey];
				}
			}
		}
	}
    [newParseTemplate didChangeValueForKey: @"displayName"];
	
	// END:  ITERATE over parseTemplateAttributesFromFile and set values of newParseTemplate
	
	return newParseTemplate;
    
    if (yesNoSave) {
        [self saveAction: nil];
        [self.allParserListArrayController addObject: newParseTemplate];
        [self.allParserListArrayController rearrangeObjects];
    }
	DLog(@"FINISHED NEXT STEP");
}



#pragma mark -
#pragma mark Add Directory
-(BOOL) addDirectoryFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate:  addDirectoryFromNotification");
	BOOL success = YES;
	
	NSDictionary *userInfo		= [note userInfo];
    DLog(@"userInfo = %@", userInfo);
    DLog(@"note = %@", note);
    
    NSString *sourceOfDirectories = [userInfo objectForKey: HNaddFilesFrom];
    
    if ([sourceOfDirectories isEqualToString: HNAddFilesFromNotifiationArray]) {
        success = [self addDirectoriesWithUserInfo: userInfo];
    }
    
    else if ( [sourceOfDirectories isEqualToString: HNAddFilesFromNSOpenPanel] ) {
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setCanChooseDirectories: YES];
        [openPanel setCanCreateDirectories: NO];
        [openPanel setAllowsMultipleSelection: YES];
        [openPanel setAllowedFileTypes: nil];

        [openPanel beginSheetModalForWindow: [self window] completionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelOKButton) {
                //HNTreeNode *selectedNode = [[self.treeController selectedObjects] firstObject];
                //[self createNewDataItemsFromFilePathURLs: [openPanel URLs] andPlaceInTreeNode: selectedNode];
                NSMutableDictionary *localUserInfo = [NSMutableDictionary dictionaryWithDictionary: userInfo];
                NSArray *selectedDirectoryURLS = [openPanel URLs];
                NSArray *selectedDirectoryPaths = [self convertURLsToFilePaths: selectedDirectoryURLS];
                [localUserInfo setObject: selectedDirectoryPaths forKey: HNArrayOfDirectoryKeyPathsToAddKey];
                [self addDirectoriesWithUserInfo: localUserInfo];
                
            }
            else {
                [openPanel close];
            }
        }];
        
    }
    
	return success;
}



-(BOOL) addDirectoriesWithUserInfo: (NSDictionary *) userInfo {
    BOOL success = YES;
    
    NSArray *directoriesToAdd	= [userInfo objectForKey:   HNArrayOfDirectoryKeyPathsToAddKey];
	NSURL *targetNodeURI		= [userInfo objectForKey:   HNTreeNodeURIKey];
	HNTreeNode *targetTreeNode	= [self treeNodeFromURIKey: targetNodeURI];
	NSIndexPath *insertionPath  = [userInfo objectForKey:   HNTargetTreeNodeNSIndexPathKey];
    
    
    if (targetNodeURI) {
        targetTreeNode = [self treeNodeFromURIKey: targetNodeURI];
    }
    
    if (!targetTreeNode) {
        targetTreeNode = [[self.treeController selectedObjects] firstObject];
    }
    
    
    //NSAssert(targetTreeNode, @"targetTreeNode == nil");
    
    if (!insertionPath) {
        insertionPath = [self.treeController indexPathForInsertion];
    }
	
	DLog(@"targetTreeNode = %@", targetTreeNode.displayName);
	
	[targetTreeNode willChangeValueForKey: @"children"];
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString *nextDirectoryPath in directoriesToAdd) {
		BOOL isDirectory = NO;
		if ([fm fileExistsAtPath: nextDirectoryPath isDirectory: &isDirectory]) {
			NSString *extension = [nextDirectoryPath pathExtension];
			if (isDirectory && ![extension isEqualToString: @"dgraph"] ) {
				HNTreeNode *newTreeNode = [self createTreeNodesAndFillFromDirectory: nextDirectoryPath andPlaceInTreeNode:targetTreeNode];
				
				if (newTreeNode) {
					DLog(@"newTreeNode at Notification Level= %@", newTreeNode.displayName);
					DLog(@"insertionPath = %@", insertionPath);
					[self.treeController insertObject: newTreeNode atArrangedObjectIndexPath:insertionPath];
					DLog(@"Finished insertion");
				}
				else {
					DLog(@"NO newTreeNode at Notification Level");
				}
				
			}
		}
	}
	
	[targetTreeNode didChangeValueForKey: @"children"];
    
    return success;
}


-(HNTreeNode *) createTreeNodesAndFillFromDirectory: (NSString *) directoryPath
								 andPlaceInTreeNode: (HNTreeNode *) targetTreeNode {
	
	DLog(@"CALLED - HNAppDelegate:  createTreeNodesAndFillFromDirectory: andPlaceInTreeNode");
	
	if (!directoryPath) {
		return nil;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath: directoryPath]) {
		return nil;
	}
	
	if (![fm changeCurrentDirectoryPath: directoryPath]) {
		return nil;
	}
	
	// Get Name of directory
	NSString *directoryName = [directoryPath lastPathComponent];
	DLog(@"directoryName = %@", directoryName);
	
	
	// Create New TreeNode
	//-(HNTreeNode *) addNewCollectionOfType: (NSString *) collectionType withInsertionPath: (NSIndexPath *) insertionPath;
	//Create Group Node
	HNTreeNode * newTreeNode = [NSEntityDescription insertNewObjectForEntityForName:@"HNTreeNode"
															 inManagedObjectContext:[self managedObjectContext]];
    
    NSPredicate *folderPredicate = [NSPredicate predicateWithFormat:@"typeName MATCHES %@", HNFolderCollectionType];
    
    HNCollectionType *folderCollectionType = [[[self.managedObjectContext fetchObjectsForEntityName: @"HNCollectionType" withPredicate: folderPredicate] allObjects] firstObject];
    
	newTreeNode.collectionType = folderCollectionType;
	
	newTreeNode.isLeaf = [NSNumber numberWithBool: NO];
	newTreeNode.displayName = directoryName;
	
	if (targetTreeNode) {
		newTreeNode.parent = targetTreeNode;
		[newTreeNode setDefaultsFromParent];
		DLog(@"newTreeNodeDefaults = %@ and %@", newTreeNode.defaultGraphTemplate, newTreeNode.defaultParseTemplate);
	}
    else {
        NSIndexPath *indexPathForInsertion = [self.treeController indexPathForInsertion];
        [self.treeController insertObject: newTreeNode atArrangedObjectIndexPath:indexPathForInsertion];
    }
    
	
	//DLog(@"newTreeNode = %@", newTreeNode);
	
	
	// Get list of all files in directory
	NSError *fileListError;
	NSArray *filesInDirectory = [fm contentsOfDirectoryAtPath: directoryPath
														error:&fileListError];
	if ( (!filesInDirectory) || (fileListError != nil) ) {
		return nil;
	}
	
	DLog(@"\n\nFiles in Directory = %@", filesInDirectory);
	
	
	// Get any data, graph templates, and parse template files
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSArray *dataFileExtensions  = [userDefaults objectForKey: HNExtensionsForDataFileTypesKey];
	NSArray *graphFileExtensions = [userDefaults objectForKey: HNExtensionsForGraphTemplatesKey];
	NSArray *parseFileExtensions = [userDefaults objectForKey: HNExtensionsForParseTemplatesKey];
	
	// This just gives the file names
	NSArray *dataFilesArray		 = [self filesInArray: filesInDirectory
									withExtensions: dataFileExtensions];
	
	NSArray *graphTemplateFilesArray = [self filesInArray: filesInDirectory
										   withExtensions:graphFileExtensions];
	
	NSArray *parseTemplateFilesArray = [self filesInArray: filesInDirectory
										   withExtensions:parseFileExtensions];
	
	
	// update array items so that they include the entire filepath
	dataFilesArray	= [self setFullDirectoryPathForFilePaths: dataFilesArray
									fromParentDirectoryPath: directoryPath];
	graphTemplateFilesArray	= [self setFullDirectoryPathForFilePaths: graphTemplateFilesArray
											 fromParentDirectoryPath: directoryPath];
	parseTemplateFilesArray	= [self setFullDirectoryPathForFilePaths: parseTemplateFilesArray
											 fromParentDirectoryPath: directoryPath]
	;
	DLog(@"\n\ndataFilesArray = %@", dataFilesArray);
	DLog(@"\n\ngraphTEmpalteFilesArray = %@", graphTemplateFilesArray);
	//DLog(@"\n\nparseTemplateFilesArray = %@", parseTemplateFilesArray);
	
	
	
	
	// Create and Add graph template files to new Tree node
	if ([graphTemplateFilesArray count] > 0) {
		DLog(@"Making new Graph Templates");
		NSMutableArray *newHNGraphTemplates = [NSMutableArray array];
		NSArray *graphTemplateFileURLs = [self convertFilePathsToURLS: graphTemplateFilesArray];
		
		for (NSURL *nextURL in graphTemplateFileURLs) {
			HNGraphTemplate *newGraphTemplate = [self createNewGraphTemplateFromFilePathURL:nextURL andPlaceInTreeNode: newTreeNode withAutoSave:NO];
			[newHNGraphTemplates addObject: newGraphTemplate];
		}
        
        if (targetTreeNode) {
            [targetTreeNode addGraphTemplates: [NSSet setWithArray: newHNGraphTemplates]];
        }
		
		
		
		// Check to see if there are any templates labeled "default"
		NSMutableArray *defaults = [NSMutableArray array];
		for (HNGraphTemplate *nextGraphTemplate in newHNGraphTemplates) {
			NSString *nextDisplayName = nextGraphTemplate.displayName;
			NSRange defaultExists = [nextDisplayName rangeOfString: @"default" options:NSCaseInsensitiveSearch];
			
			if (defaultExists.location != NSNotFound ) {
				DLog(@"adding %@ to defaults", nextGraphTemplate.displayName);
				[defaults addObject: nextGraphTemplate];
			}
		}
		
		BOOL defaultGraphNeeded = YES;
		// If directory contains a .dgraph titled 'default*.*' set as a default
		if ([defaults count] > 0) {
			DLog(@"setting defaultGraphTemplate from defaults");
			HNGraphTemplate *defaultGraphTemplate = [defaults firstObject];
			[newTreeNode setDefaultGraphTemplate: defaultGraphTemplate];
			defaultGraphTemplate = NO;
		}
		
		if ( (defaultGraphNeeded)  && ( [newHNGraphTemplates count] > 0 )  ) {
			DLog(@"setting defaultGraphTemplate from a non-labled default");
			HNGraphTemplate *defaultGraphTemplate = [newHNGraphTemplates firstObject];
			[newTreeNode setDefaultGraphTemplate: defaultGraphTemplate];
		}
	}
    
    
    // Create and ADD PARSE TEMPLATES files to new Tree node
	if ([graphTemplateFilesArray count] > 0) {
		DLog(@"Making new Parse Templates");
		NSMutableArray *newHNParseTemplates = [NSMutableArray array];
		NSArray *fileURLs = [self convertFilePathsToURLS: parseTemplateFilesArray];
		
		for (NSURL *nextURL in fileURLs) {
			HNParseTemplate *newParseTemplate = [self createNewParseTemplateFromFile: nextURL andPlaceInTreeNode: newTreeNode withAutoSave: NO];
			[newHNParseTemplates addObject: newParseTemplate];
		}
        if (targetTreeNode) {
            [targetTreeNode addParseTemplates: [NSSet setWithArray: newHNParseTemplates]];
        }
		
		
		
		// Check to see if there are any templates labeled "default"
		NSMutableArray *defaults = [NSMutableArray array];
		for (HNParseTemplate *nextParseTemplate in newHNParseTemplates) {
			NSString *nextDisplayName = nextParseTemplate.displayName;
			NSRange defaultExists = [nextDisplayName rangeOfString: @"default" options:NSCaseInsensitiveSearch];
			
			if (defaultExists.location != NSNotFound ) {
				DLog(@"adding %@ to defaults", nextParseTemplate.displayName);
				[defaults addObject: nextParseTemplate];
			}
		}
		
		BOOL defaultParseTemplateNeeded = YES;
		// If directory contains a .dgraph titled 'default*.*' set as a default
		if ([defaults count] > 0) {
			DLog(@"setting defaultParseTemplate from defaults");
			HNParseTemplate *defaultParseTemplate = [defaults firstObject];
			[newTreeNode setDefaultParseTemplate: defaultParseTemplate];
			defaultParseTemplateNeeded = NO;
		}
		
		if ( (defaultParseTemplateNeeded)  && ( [newHNParseTemplates count] > 0 )  ) {
			DLog(@"setting defaultParseTemplate from a non-labled default");
			HNParseTemplate *defaultParseTemplate = [newHNParseTemplates firstObject];
			[newTreeNode setDefaultParseTemplate: defaultParseTemplate];
		}
	}
	
	
    // ADD DATA FILES
	if ([dataFilesArray count] > 0) {
		DLog(@"\n\n\\n\nCreating HNDataItems from dataFilesArray");
		NSMutableArray *newHNDataItems = [NSMutableArray array];
		NSArray *dataFileURLs = [self convertFilePathsToURLS: dataFilesArray];
		for (NSURL *nextDataFileURL in dataFileURLs) {
			HNDataItem *newDataItem = [self createNewDataItemFromFileURL: nextDataFileURL andPlaceInTreeNode:newTreeNode withAutoSave: NO];
			DLog(@"newDataItem = %@", newDataItem.displayName);
			//[newDataItem setDefaultsFromParent];
			
			if (newDataItem) {
				[newHNDataItems addObject: newDataItem];
			}
		}
	}
	
	
	// Recursively call itself to fill out all sub-directories
	//DLog(@"Check to see if there are more directories to add");
	NSMutableArray *directoriesArray = [NSMutableArray array];
	for (NSString *nextFilePath in filesInDirectory) {
		BOOL isDirectory;
		if ([fm fileExistsAtPath: nextFilePath isDirectory: &isDirectory]) {
			NSString *extension = [nextFilePath pathExtension];
			if (isDirectory && ![extension isEqualToString: @"dgraph"]) {
				DLog(@"%@ is a directory", nextFilePath);
				[directoriesArray addObject: nextFilePath];
			}
		}
	}
	
	//DLog(@"Have Collection of direcotry Names");
	NSMutableArray *fullDirectoryPaths = [NSMutableArray array];
	for (NSString *nextDirectoryName in directoriesArray) {
		NSString *fullPath = [directoryPath stringByAppendingPathComponent: nextDirectoryName];
		[fullDirectoryPaths addObject: fullPath];
	}
	//DLog(@"Finished creating full directorypaths");
	
	
	//DLog(@"directoriesArray = %@", directoriesArray);
	//DLog(@"fullDirectoryPaths = %@", fullDirectoryPaths);
	//DLog(@"Recursively call self to fill out all sub-directories");
	if ([fullDirectoryPaths count] > 0) {
		DLog(@"[directoriesArray count] = %lu", [fullDirectoryPaths count]);
		for (NSString *nextDirectoryFilePath in fullDirectoryPaths) {
			[self createTreeNodesAndFillFromDirectory: nextDirectoryFilePath andPlaceInTreeNode:newTreeNode];
		}
	}
    else {
        
        NSPredicate *experimentPredicate = [NSPredicate predicateWithFormat:@"typeName MATCHES %@", HNExperimentCollectionType];
        
        HNCollectionType *experimentCollectionType = [[[self.managedObjectContext fetchObjectsForEntityName: @"HNCollectionType" withPredicate: experimentPredicate] allObjects] firstObject];
        
        if (experimentCollectionType) {
            [newTreeNode setCollectionType: experimentCollectionType];
        }
    }
	
	
	DLog(@"FINISHED - HNAppDelegate:  createTreeNodesAndFillFromDirectory: andPlaceInTreeNode");
	
	return newTreeNode;
}

-(NSArray *) filesInArray: (NSArray *) arrayOfFiles
		   withExtensions: (NSArray *) fileExtensions {
	DLog(@"CALLED - HNAppDelegate:  filesInArray: withExtensions");
    DLog(@"arrayOfFiles = %@", arrayOfFiles);
	
	NSMutableArray *matchingFiles = [NSMutableArray array];
    NSMutableSet *matchingFilesSet = [NSMutableSet set]; // NEW
	
	for (NSString *nextExtension in fileExtensions) {
		NSString *predicateString = [NSString stringWithFormat: @"self ENDSWITH '.%@'", nextExtension];
		NSPredicate *filterPredicate = [NSPredicate predicateWithFormat: predicateString];
		NSArray *filesWithCorrectExtension = [arrayOfFiles filteredArrayUsingPredicate:filterPredicate];
        
		[matchingFiles addObjectsFromArray: filesWithCorrectExtension];
        // NEW
        [matchingFilesSet addObjectsFromArray: filesWithCorrectExtension];
	}
	
	
	//return [NSArray arrayWithArray: matchingFiles];
    return [matchingFilesSet allObjects];
}


-(NSArray *) setFullDirectoryPathForFilePaths: (NSArray *) filePaths
					  fromParentDirectoryPath: (NSString *) parentDirectoryPath {
	if (!filePaths || !parentDirectoryPath) {
		return nil;
	}
	
	NSMutableArray *updatedFilePaths = [NSMutableArray array];
	
	for (NSString *nextFile in filePaths) {
		NSString *updatedFilePath = [parentDirectoryPath stringByAppendingPathComponent: nextFile];
		if (updatedFilePath) {
			[updatedFilePaths addObject: updatedFilePath];
		}
	}
	
	return [NSArray arrayWithArray: updatedFilePaths];
	
}



#pragma mark -
#pragma mark Helper Methods
-(HNTreeNode *) treeNodeFromURIKey: (NSURL *) treeNodeURI {
	if (!treeNodeURI) {
		return nil;
	}
	
	NSManagedObjectID *targetTreeNodeID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation: treeNodeURI];
	HNTreeNode *targetTreeNode  = (HNTreeNode *) [self.managedObjectContext objectWithID: targetTreeNodeID];
	
	return targetTreeNode;
}


-(NSArray *) convertFilePathsToURLS: (NSArray *) filePaths {
	//DLog(@"CALLED - HNAppDelegate: convertFilePathsToURLS");
	NSMutableArray *fileURLs = [NSMutableArray array];
	
	DLog(@"fileURLS = %@", fileURLs);
	for (NSString *nextFilePath in filePaths) {
		//DLog(@"nextFilePath = %@", nextFilePath);
		NSURL *newURL = [self convertFilePathToURL: nextFilePath];
		//DLog(@"newURL = %@", newURL);
		[fileURLs addObject: newURL];
	}
	
	return [fileURLs copy];
}


-(NSURL *) convertFilePathToURL: (NSString *) filePath {
	NSURL *newURL = [NSURL fileURLWithPath: filePath];
	
	return newURL;
}

-(NSArray *) convertURLsToFilePaths: (NSArray *) urls {
    NSMutableArray *filePaths = [NSMutableArray array];
    
    for (NSURL *nextURL in urls) {
        NSString *nextFilePath = [self convertURLtoFilePath: nextURL];
        if (nextFilePath) {
            [filePaths addObject: nextFilePath];
        }
    }
    
    return [filePaths copy];
}

-(NSString *) convertURLtoFilePath: (NSURL *) url {
    NSString *filePath;
    if ([url isKindOfClass: [NSURL class]]) {
        filePath = [url path];
    }
    return filePath;
}





#pragma mark -
#pragma mark Remove Objects
-(BOOL) removeDataItemsFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: removeDataItemsFromNotification");
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName: @"Remove Data"];
	
	
	NSSet *selectedDataItems = [NSSet setWithArray: [self.dataItemsArrayController selectedObjects]];
	
	for (HNDataItem *nextDataItem in selectedDataItems) {
		[self.dataItemsArrayController removeObject: nextDataItem];
		[self.managedObjectContext deleteObject: nextDataItem];
	}
	
	[self saveAction: self];
	[undoManager endUndoGrouping];
	
	return YES;
}


-(BOOL) removeCollectionFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: removeCollectionFromNotification");
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName: @"Remove Collection"];
	
	
	NSSet *selectedNodes = [NSSet setWithArray: [self.treeController selectedObjects]];
	
	for (HNTreeNode *nextTreeNode in selectedNodes) {
        
        // Delete any parse and graph templates attached to this 
        
        
        
        // Remove dataItems, parseTemplates, and graphTemplates
        //NSSet *allDataItems = [nextTreeNode allDataItems];
        //[self.dataItemsArrayController removeObjects: [allDataItems allObjects]];
        [self.dataItemsArrayController prepareContent];
        
        
        // Remove treeNode
        NSIndexPath *nextIndexPath = [self.treeController indexPathOfObject: nextTreeNode];
        [self.treeController removeObjectAtArrangedObjectIndexPath: nextIndexPath];
		[self.managedObjectContext deleteObject: nextTreeNode];

	}
	
	
	[self.treeController rearrangeObjects];
    [self.treeController setSelectionIndexPath: [NSIndexPath indexPathWithIndex: 0]];
    
    [self.dataItemsArrayController rearrangeObjects];
    if ([[self.dataItemsArrayController arrangedObjects] count] != 0) {
        [self.dataItemsArrayController setSelectionIndex: 0];
    }
    else {
        [self.dataItemsArrayController setSelectionIndexes: [NSIndexSet new]];
        [self.dataViewController updateGraphDrawingView];
    }
    
    
    
    
	[self saveAction: self];
	[undoManager endUndoGrouping];
	
	return YES;
}


-(BOOL) removeParseTemplateFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: removeParseTemplateFromNotification");
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName: @"Remove Parser"];
	
	
	NSArray *selectedParsers = [self.allParserListArrayController selectedObjects];
	
	// Remove all the selected parse templates from array controllers and MoC
	for (HNParseTemplate *nextParser in selectedParsers) {
		[self.allParserListArrayController removeObject: nextParser];
		[self.parserListArrayController remove: nextParser];
		[self.managedObjectContext deleteObject: nextParser];
	}
	
	DLog(@"allParserListArrayController count = %lu", [[allParserListArrayController arrangedObjects] count]);
	
	
	
	//[self.treeController rearrangeObjects];
	[self saveAction: self];
	[undoManager endUndoGrouping];
	
	return YES;
}


-(BOOL) removeGraphTemplateFromNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: removeGraphTemplateFromNotification");
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName: @"Remove Graph Template"];
	
	
	NSArray *selectedGraphTemplates = [self.allGraphTemplateListArrayController selectedObjects];
	
	// Remove all the selected graph templates from array controllers and MoC
	for (HNGraphTemplate *nextGraphTemplate in selectedGraphTemplates) {
		[self.allGraphTemplateListArrayController removeObject: nextGraphTemplate];
		[self.graphTemplateListArrayController remove: nextGraphTemplate];
		[self.managedObjectContext deleteObject: nextGraphTemplate];
	}
	
	
	//[self.treeController rearrangeObjects];
	[self saveAction: self];
	[undoManager endUndoGrouping];
	
	return YES;
}


-(BOOL) deleteParseTemplate:(HNParseTemplate *) parseTemplate {
    [self.allParserListArrayController removeObject: parseTemplate];
    [self.parserListArrayController remove: parseTemplate];
    [self.managedObjectContext deleteObject: parseTemplate];
    
    return YES;
}

-(BOOL) deleteGraphTemplate: (HNGraphTemplate *) graphTemplate {
    [self.allGraphTemplateListArrayController removeObject: graphTemplate];
    [self.graphTemplateListArrayController remove: graphTemplate];
    [self.managedObjectContext deleteObject: graphTemplate];
    return YES;
}


#pragma mark -
#pragma mark Move Objects
-(BOOL) moveDataItemsNotification: (NSNotification *) note {
	DLog(@"CALLED - HNAppDelegate: moveDataItemsNotification");
	
	
	NSDictionary *userInfo		= [note userInfo];
	NSData *pasteBoardData		= [userInfo objectForKey: HNDataItemsArrayKey];
	DLog(@"pasteBoardData = %@", pasteBoardData);
	NSArray *dataItemURIs = (NSArray *) [NSUnarchiver unarchiveObjectWithData: pasteBoardData];
	DLog(@"Finished unarchive pasteBoardData = %@", dataItemURIs);
	
	// Get targetTreeNode
	NSURL *targetTreeNodeURI	= [userInfo objectForKey: HNTreeNodeURIKey];
	HNTreeNode *targetTreeNode = [self treeNodeFromURIKey: targetTreeNodeURI];
	
	// CHANGED
	/*
	 NSManagedObjectID *targetTreeNodeID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation: targetTreeNodeURI];
	 HNTreeNode *targetTreeNode  = (HNTreeNode *) [self.managedObjectContext objectWithID: targetTreeNodeID];
	 */
	
	if ( ![dataItemURIs isKindOfClass: [NSArray class]]) {
		DLog(@"dataItemURIs isKindOfClass:  %@", [dataItemURIs class]);
	}
	
	
	
	if (!targetTreeNode || !dataItemURIs) {
		DLog(@"No targetTreeNode or dataItemURIs\n targetTreeNode = %@\n\n dataItemURIs = %@", targetTreeNode, dataItemURIs);
		return NO;
	}
	// dataItems and treeNodes exist; continue
	
	
	// Setup undo manager
	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	NSString *undoNote = NSLocalizedString(@"Move Data", @"move Data Message");
	[undoManager setActionName: undoNote];
	
	DLog(@"Target treeNode = %@", targetTreeNode.displayName);
	//Get Managed Objects
	
	for (NSURL *nextURI in dataItemURIs) {
		NSManagedObjectID *nextID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation: nextURI];
		HNDataItem *nextDataItem = (HNDataItem *) [self.managedObjectContext objectWithID: nextID];
		
		if ([nextDataItem isKindOfClass: [HNDataItem class]]) {
			DLog(@"nextDataItem = %@", nextDataItem.displayName);
			DLog(@"nextDataItem class = %@", [nextDataItem class]);
			[nextDataItem setTreeNode: targetTreeNode];
		}
	}
	
	
	[self.treeController rearrangeObjects];
	[self saveAction: self];
	
	DLog(@"FINISHED moveDataItemsNotification");
	
	return YES;
}



#pragma mark -
#pragma mark Export Notifications

-(void) exportDataItemsNotification: (NSNotification *) note {
    NSDictionary *userInfo = [note userInfo];
    NSString *exportItemsUsing = [userInfo objectForKey: HNExportItemsUsingKey];
    
    if ([exportItemsUsing isEqualToString: HNExportItemsUsingSavePanel]) {
        [self savePanelForExportingItems: userInfo];
    }
}


-(void) exportParseTemplateNotification: (NSNotification *) note {
    DLog(@"CALLED - HNAppDelegate:  exportParseTemplateNotification");
	
	NSDictionary *userInfo = [note userInfo];
	NSString *exportParseTemplateUsing = [userInfo objectForKey: HNExportItemsUsingKey];
	
	if ([exportParseTemplateUsing isEqualToString: HNExportItemsUsingSavePanel]) {
        // CHANGED
		//[self savePanelForExportingParseTemplates: userInfo];
        [self savePanelForExportingItems: userInfo];
	}
}

-(void) exportGraphTemplateNotification: (NSNotification *) note {
    NSDictionary *userInfo = [note userInfo];
    NSString *exportItemsUsing = [userInfo objectForKey: HNExportItemsUsingKey];
    
    if ( [exportItemsUsing isEqualToString: HNExportItemsUsingSavePanel]) {
        [self savePanelForExportingItems: userInfo];
    }
}


-(void) exportCollectionNotification: (NSNotification *) note {
    NSDictionary *userInfo = [note userInfo];
    NSString *exportItemsUsing = [userInfo objectForKey: HNExportItemsUsingKey];
    
    if ( [exportItemsUsing isEqualToString: [userInfo objectForKey: HNExportItemsUsingSavePanel]] ) {
        [self savePanelForExportingItems: userInfo];
    }
    
}





#pragma mark Export
-(void) savePanelForExportingItems: (NSDictionary *) userInfo {
    // Get items to export
    NSArray *itemsToExport = [userInfo objectForKey: HNExportItemsArrayKey];
    
    if ([itemsToExport count] == 0) {
        return;
    }
    
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories: YES];
    [openPanel setCanCreateDirectories: YES];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setAllowedFileTypes: @[ @"" ]];
    
    [openPanel beginSheetModalForWindow: [self window] completionHandler: ^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *destinationURL;
            destinationURL = [openPanel URL];
            DLog(@"destinationURL in block = %@", destinationURL);
            if (!destinationURL) {
                DLog(@"ERROR:  No destinationURL from Save Panel");
            }
            
            
            // Export items using appropriate method
            id firstObject = [itemsToExport firstObject];
            
            if (!firstObject) {
                DLog(@"ERROR: No exportClass");
            }
            
            // DATA ITEMS
            if ( [firstObject isKindOfClass: [HNDataItem class]] ) {
                [self exportDataItems: itemsToExport toDirectory: destinationURL byMove: NO];
            }
            
            // GRAPH TEMPLATES
            else if ( [firstObject isKindOfClass: [HNGraphTemplate class]]  ) {
                [self exportGraphTemplates: itemsToExport toDirectory: destinationURL byMove: NO];
            }
            
            // PARSE TEMPLATES
            else if ( [firstObject isKindOfClass: [HNParseTemplate class]] ) {
                [self exportParseTemplateObjects: itemsToExport toDirectory: destinationURL];
            }
            
            // COLLECTION
            else if ( [firstObject isKindOfClass: [HNCollectionType class]] ) {
                // TODO: addExportCollection method
            }
            else {
                DLog(@"ERROR: %@ has an unknown class for export", firstObject);
            }
        }
        else {
            return;
        }
    }];
    DLog(@"FINISHED EXPORT");

}

-(void) exportDataItems: (NSArray *) hnDataItemsToExport
            toDirectory: (NSURL *) targetDirectory
                 byMove: (BOOL) moveFiles_yesOrNo {
    
    if ([hnDataItemsToExport count] == 0) {
        return;
    }
    
    if (!targetDirectory) {
        // TODO: Add error if no target directory
        return;
    }
    
    
    if (!moveFiles_yesOrNo) {
        moveFiles_yesOrNo = NO;
    }
    
    BOOL success = YES;
    for (HNDataItem *nextDataItem in hnDataItemsToExport) {
        
        
        // TODO: change BOOL success to an NSError
        // Need to handle errors during reading/writing move/copy process
        NSError *error;
        success = [self exportDataItem: nextDataItem toDirectory: targetDirectory byMove: moveFiles_yesOrNo withError: &error];
        
        if (success == NO) {
            // Problem with Export, stop export and present error
            // TODO: Recover from export error
            
            
            
            break;
        } // END - success check
    }  // END - export loop
    
}



-(BOOL) exportDataItem: (HNDataItem *) dataItemToExport
           toDirectory: (NSURL *) targetDirectory
                byMove: (BOOL) moveFile_yesOrNo
             withError: (NSError **) error {
    
    BOOL success = YES;
    
    if (!dataItemToExport || !targetDirectory) {
        // TODO: Add Error handling
        return success = NO;
    }
    
    
    if (!moveFile_yesOrNo) {
        moveFile_yesOrNo = NO;
    }
    
    
    // Check files to export
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dataItemURL = [NSURL URLWithString: dataItemToExport.filePath];
    if (!dataItemURL || ( [fm fileExistsAtPath: dataItemToExport.filePath] == NO)   ) {
        NSString *domain = @"com.H-Nano.GraphBase.ErrorDomain";
        NSString *desc = NSLocalizedString(@"Unable to export data:  Data file could not be found", @"Unable to export.  Data file not found key");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
        
        NSError *localError = [NSError errorWithDomain:domain
                                    code:-101
                                userInfo:userInfo];
        
        NSAlert *theAlert = [NSAlert alertWithError: localError];
        [theAlert runModal];
        
        return NO;
    }
    
    
    // Set up targetURL
    NSString *fileName = [dataItemURL lastPathComponent];
    
    
    NSURL *targetURL = [targetDirectory URLByAppendingPathComponent: fileName];
    
    if (moveFile_yesOrNo == YES) {
        // Move Files
        success = [fm moveItemAtURL: dataItemURL toURL: targetURL error: error];
    }
    else {
        success = [fm copyItemAtURL: dataItemURL toURL: targetURL error: error];
    }
    
    
    
    return success;
}



-(void) exportGraphTemplates: (NSArray *) hnGraphTemplatesToExport
                 toDirectory: (NSURL *) targetDirectory
                      byMove: (BOOL) moveFiles_yesOrNo {
    
    if ([hnGraphTemplatesToExport count] == 0) {
        return;
    }
    
    if (!targetDirectory) {
        // TODO: Add error if no target directory
        return;
    }
    
    
    if (!moveFiles_yesOrNo) {
        moveFiles_yesOrNo = NO;
    }
    
    BOOL success = YES;
    for (HNGraphTemplate *nextItem in hnGraphTemplatesToExport) {
        
        if ([nextItem isKindOfClass:[HNGraphTemplate class]]) {
            // TODO: change BOOL success to an NSError
            // Need to handle errors during reading/writing move/copy process
            NSError *error;
            success = [self exportGraphTemplate: nextItem
                                    toDirectory: targetDirectory
                                         byMove: moveFiles_yesOrNo
                                      withError: &error];
            
            if (success == NO) {
                // Problem with Export, stop export and present error
                // TODO: Recover from export error
                
                
                
                break;
            } // END - success check
        }  // END - export loop
    }    
}


-(BOOL) exportGraphTemplate: (HNGraphTemplate *) graphTemplateToExport
                toDirectory: (NSURL *) targetDirectory
                     byMove: (BOOL) moveFile_yesOrNo
                  withError: (NSError **) error {
    
    BOOL success = YES;
    
    if (!graphTemplateToExport || !targetDirectory) {
        // TODO: Add Error handling
        return success = NO;
    }
    
    
    if (!moveFile_yesOrNo) {
        moveFile_yesOrNo = NO;
    }
    
    
    // Check files to export
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *urlOfExportItem = [NSURL URLWithString: graphTemplateToExport.filePath];
    if (!urlOfExportItem || ( [fm fileExistsAtPath: graphTemplateToExport.filePath] == NO)   ) {
        NSString *domain = @"com.H-Nano.GraphBase.ErrorDomain";
        NSString *desc = NSLocalizedString(@"Unable to export data:  Data file could not be found", @"Unable to export.  Data file not found key");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
        
        NSError *localError = [NSError errorWithDomain:domain
                                                  code:-101
                                              userInfo:userInfo];
        
        NSAlert *theAlert = [NSAlert alertWithError: localError];
        [theAlert runModal];
        
        return NO;
    }
    
    
    // Set up targetURL
    NSString *fileName = [urlOfExportItem lastPathComponent];
    
    
    NSURL *targetURL = [targetDirectory URLByAppendingPathComponent: fileName];
    
    if (moveFile_yesOrNo == YES) {
        // Move Files
        success = [fm moveItemAtURL: urlOfExportItem toURL: targetURL error: error];
    }
    else {
        success = [fm copyItemAtURL: urlOfExportItem toURL: targetURL error: error];
    }
    
    
    
    return success;
}



-(void) exportParseTemplateObjects: (NSArray *) parseTemplates
                       toDirectory: (NSURL *) destinationDirectoryURL {
    DLog(@"CALLED - HNAppDelegate:  exportParseTemplateObjects");
	if ( ([parseTemplates count] == 0) || !destinationDirectoryURL) {
		return;
	}
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    NSString *fileExtension = [[defaults objectForKey: HNExtensionsForParseTemplatesKey] firstObject];
	
	NSMutableDictionary *usedFilePaths = [NSMutableDictionary dictionary];
	
	
	for (HNParseTemplate *nextParseTemplate in parseTemplates) {
        DLog(@"nextParseTemplate = %@", nextParseTemplate.displayName);
        
        if (![nextParseTemplate isKindOfClass: [HNParseTemplate class]]) {
            DLog(@"nextParseTemplate is NOT an HNParseTempalte");
            continue;
        }
		
		// Set destinationURL
		NSString *fileName = nextParseTemplate.displayName;
        fileName = [fileName stringByAppendingPathExtension: fileExtension];

		NSURL *destinationURL = [destinationDirectoryURL URLByAppendingPathComponent: fileName];
		NSString *destinationPath = [destinationURL path];
		
		BOOL filePathAlreadyExists = NO;
        NSArray *usedFilePathKeys = [usedFilePaths allKeys];
		for (NSString *nextFilePath in usedFilePathKeys) {
			if ( [nextFilePath isEqualToString: destinationPath] ) {
				filePathAlreadyExists = YES;
			}
		}
		
		// Check to see if fileName has already been used before
		if (filePathAlreadyExists == NO) {
			// filePath has not been used yet
			NSNumber *numberOfWithFileName = [NSNumber numberWithInteger: 1];
			[usedFilePaths setValue: numberOfWithFileName forKey: destinationPath];
			
		}
		else {
			// filePath exists.  Get the number of times this filePath has been used and give destinationURL another name
			NSInteger numberOfPreviousDuplicates = [[usedFilePaths objectForKey: destinationPath] integerValue];
			++numberOfPreviousDuplicates;
            
            destinationURL = [destinationURL URLByDeletingPathExtension];
			
			destinationURL = [destinationURL URLByAppendingPathComponent: [NSString stringWithFormat:@"(%lu)", numberOfPreviousDuplicates]];
			[usedFilePaths setValue: [NSNumber numberWithInteger: numberOfPreviousDuplicates] forKey: destinationPath];
            destinationURL = [destinationURL URLByAppendingPathExtension: fileExtension];
		}
		
		NSDictionary *parseTemplateAttributes = [nextParseTemplate propertiesForExport];
		
        DLog(@"parseTemplateAttributes = %@", parseTemplateAttributes);
		
		
		if ([parseTemplateAttributes writeToURL: destinationURL atomically: YES] == NO) {
			NSLog(@"Failed to write file for ParseTemplate: %@ \n to %@", nextParseTemplate.displayName, [destinationURL path]);
		}
	}
}






@end
