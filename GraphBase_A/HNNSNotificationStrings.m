//
//  HNNSNotificationStrings.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/16/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNNSNotificationStrings.h"


#pragma mark -
#pragma mark User Defaults
NSString *const HNGreyOrColorIconNotification = @"HNGreyOrColorIconChanged";
NSString * const HNResetCropOnNewSelectionNotification = @"HNResetCropOnNewSelectionNotification";


#pragma mark -
#pragma mark Adding Collections
NSString * const HNCollectionOfType						= @"HNCollectionOfType";
NSString * const HNFolderCollectionType					= @"Folder";							// HNTreeNode with a Generic Collection that gets a Folder icon
NSString * const HNProjectCollectionType				= @"Project";							// HNTreeNode with a Project collection that gets a Project icon
NSString * const HNExperimentCollectionType				= @"Experiment";						// HNTreeNode with a Experiment collection that gets an Experiment icon
NSString * const HNAddCollectionNotification			= @"HNAddCollectionHasBeenSelected";


#pragma mark -
#pragma mark New Data, Graphs, Parsers Notification
NSString * const HNAddDataFilesNotification				= @"HNAddNewDataFiles";						// Notification sent out when new data file(s) are needed
NSString * const HNAddGraphTemplateNotification			= @"HNAddGraphTemplateNotification";		// Notification sent out when new
NSString * const HNAddParseTemplateNotification			= @"HNAddParseTemplateNotification";		// Notification sent out when new
NSString * const HNAddWatchedFoldersNotification        = @"HNAddWatchedFoldersNotification";



#pragma mark -
#pragma mark Adding Files
NSString * const HNaddFilesFrom							= @"HNaddFilesFrom";						// Key
NSString * const HNAddFilesUsingBlankFile               = @"HNAddFilesUsingBlankFile";
NSString * const HNAddFilesFromNotifiationArray         = @"HNAddFilesFromNotifiationArray";
NSString * const HNAddFilesFromNSOpenPanel				= @"HNAddFilesFromNSOpenPanel";
NSString * const HNAddFilePathsFromPasteBoard			= @"HNAddFilePathsFromPasteBoard";
NSString * const HNAddFilesPathsFromDraggedPasteBoard	= @"HNAddFilesPathsFromDraggedPasteBoard";




NSString * const HNArrayOfDataFilePathsToAddKey             = @"HNArrayOfDataFilesToAdd";				// Data Files to add
NSString * const HNArrayOfParseTemplateFilePathsToAddKey    = @"HNArrayOfParseTemplateFilePathsToAddKey";
NSString * const HNArrayOfGraphTemplateFilePathsToAddKey    = @"HNArrayOfGraphTemplateFilePathsToAddKey";
NSString * const hnArrayOfFilePathsKey                      = @"hnArrayOfFilePathsKey";
NSString * const hnArrayOfURLsKey                           = @"hnArrayOfURLsKey";


#pragma mark -
#pragma mark Add Directory
NSString * const HNAddDirectoryNotification				= @"HNAddDirectoryNotification";
NSString * const HNArrayOfDirectoryKeyPathsToAddKey		= @"HNArrayOfDirectoryKeyPathsToAddKey";
// extern NSString * const HNTreeNodeURIKey;		// Declared in HNPasteBoardTypes.h.  Used to store URI to Tree Node
NSString * const HNTargetTreeNodeNSIndexPathKey			= @"HNTargetTreeNodeNSIndexPathKey";



#pragma mark -
#pragma mark Remove Collections and Data
NSString * const HNRemoveDataFilesNotification			= @"HNRemoveDataFilesNotification";
NSString * const HNRemoveCollectionNotification			= @"HNRemoveCollectionNotification";
NSString * const HNRemoveGraphTemplateNotification		= @"HNRemoveGraphTemplateNotification";
NSString * const HNRemoveParseTemplateNotification		= @"HNRemoveParseTemplateNotification";
NSString * const HNRemoveWatchedFolderNotification		= @"HNRemoveWatchedFolderNotification";



#pragma mark -
#pragma mark Move Notifications
NSString * const HNMoveDatatItemsNotification			= @"HNMoveDatatItemsNotification";



#pragma mark -
#pragma mark Export Notifications
NSString * const HNExportParseTemplateNotification		= @"HNExportParseTemplateNotification";
NSString * const HNExportGraphTemplateNotification      = @"HNExportGraphTemplateNotification";
NSString * const HNExportDataFilesNotification          = @"HNExportDataFilesNotification";
NSString * const HNExportCollectionNotification         = @"HNExportCollectionNotification";


NSString * const HNExportTypeKey                        = @"HNExportTypeKey";
NSString * const HNExportItemsUsingKey                  = @"HNExportItemsUsingKey";
NSString * const HNExportItemsUsingSavePanel            = @"HNExportItemsUsingSavePanel";
NSString * const HNExportItemsToDirectoryPath           = @"HNExportItemsToDirectoryPath";
NSString * const HNExportItemsArrayKey                  = @"HNExportItemsArrayKey";



#pragma mark -
#pragma mark Accessing External Applications
NSString * const hnRevealInFinderNotification           = @"hnRevealInFinderNotification";
NSString * const hnOpenInDataGraphNotification          = @"hnOpenInDataGraphNotification";
NSString * const hnArrayOfObjectsKey                    = @"hnArrayOfObjectsKey";


#pragma mark -
#pragma mark Source List View Notifications
NSString * const HNSouceListViewSelectionDidChange		= @"HNSourceListViewSelectionDidChange";






