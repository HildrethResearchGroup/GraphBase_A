//
//  HNNSNotificationStrings.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/16/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#pragma mark -
#pragma mark User Defaults
extern NSString * const HNGreyOrColorIconNotification;
extern NSString * const HNResetCropOnNewSelectionNotification;



#pragma mark -
#pragma mark Adding Collections
extern NSString * const HNAddCollectionNotification;

extern NSString * const HNCollectionOfType;
extern NSString * const HNFolderCollectionType;
extern NSString * const HNProjectCollectionType;
extern NSString * const HNExperimentCollectionType;



#pragma mark -
#pragma mark New Data, Graphs, Parsers Notification
extern NSString * const HNAddDataFilesNotification;					// Notification sent out when new data file(s) are requested
extern NSString * const HNAddGraphTemplateNotification;				// Notification sent out when new graph templates are requested
extern NSString * const HNAddParseTemplateNotification;				// Notification sent out when new parse templates are requested
extern NSString * const HNAddWatchedFoldersNotification;            // Notificaiotn sent out when new watched folders are requested



#pragma mark -
#pragma mark Add Files
extern NSString * const HNaddFilesFrom;							// Key indicating where the data files should come from
extern NSString * const HNAddFilesUsingBlankFile;               // For files that are created within GraphBase, i.e. Parse Templates
extern NSString * const HNAddFilesFromNotifiationArray;         // Add files using the array stored in the Notification
extern NSString * const HNAddFilesFromNSOpenPanel;				// Added to userInfo dictionary to let reciever know that an open panel is needed
extern NSString * const HNAddFilePathsFromPasteBoard;			// Add file paths from pasteboard
extern NSString * const HNAddFilesPathsFromDraggedPasteBoard;	// Add file paths from DraggedPasteBoard



extern NSString * const HNArrayOfDataFilePathsToAddKey;			// Key for the list of file paths to add
extern NSString * const HNArrayOfParseTemplateFilePathsToAddKey;
extern NSString * const HNArrayOfGraphTemplateFilePathsToAddKey;
extern NSString * const hnArrayOfFilePathsKey;
extern NSString * const hnArrayOfURLsKey;




#pragma mark -
#pragma mark Add Directory
extern NSString * const HNAddDirectoryNotification;
extern NSString * const HNArrayOfDirectoryKeyPathsToAddKey;
// extern NSString * const HNTreeNodeURIKey;		// Declared in HNPasteBoardTypes.h.  Used to store URI to Tree Node
extern NSString * const HNTargetTreeNodeNSIndexPathKey;




#pragma mark -
#pragma mark Remove Notifications
extern NSString * const HNRemoveDataFilesNotification;
extern NSString * const HNRemoveCollectionNotification;
extern NSString * const HNRemoveGraphTemplateNotification;
extern NSString * const HNRemoveParseTemplateNotification;
extern NSString * const HNRemoveWatchedFolderNotification;



#pragma mark - 
#pragma mark Move Notifications
extern NSString * const HNMoveDatatItemsNotification;



#pragma mark -
#pragma mark Export Notifications
extern NSString * const HNExportParseTemplateNotification;
extern NSString * const HNExportGraphTemplateNotification;
extern NSString * const HNExportDataFilesNotification;
extern NSString * const HNExportCollectionNotification;


extern NSString * const HNExportItemsUsingKey;
extern NSString * const HNExportItemsUsingSavePanel;
extern NSString * const HNExportItemsToDirectoryPath;
extern NSString * const HNExportItemsArrayKey;




#pragma mark -
#pragma mark Accessing External Applications
extern NSString * const hnRevealInFinderNotification;
extern NSString * const hnOpenInDataGraphNotification;
extern NSString * const hnArrayOfObjectsKey;




#pragma mark -
#pragma mark Source List View Notifications
extern NSString * const HNSouceListViewSelectionDidChange;






