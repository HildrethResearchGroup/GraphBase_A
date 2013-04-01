//
//  ESAppDelegate.m
//  SortedTree
//
//  Created by Jonathan Dann on 14/05/2008.
//
// Copyright (c) 2008 Jonathan Dann
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "Sorted Tree" by Jonathan Dann" will do.

#import "ESAppDelegate.h"
#import "ESTreeNode.h"
#import "ESGroupNode.h"
#import "ESLeafNode.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"

NSString *ESNodeIndexPathPasteBoardType = @"ESNodeIndexPathPasteBoardType";

@implementation ESAppDelegate

	
/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "SortedTree" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"SortedTree"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"SortedTree.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}

- (void)awakeFromNib;
{
	[outlineView registerForDraggedTypes:[NSArray arrayWithObject:ESNodeIndexPathPasteBoardType]];
}

- (IBAction)newLeaf:(id)sender;
{
	ESLeafNode *leafNode = [NSEntityDescription insertNewObjectForEntityForName:@"Leaf" inManagedObjectContext:[self managedObjectContext]];
	static NSUInteger count = 0;
	leafNode.displayName = [NSString stringWithFormat:@"Leaf %i",++count];
	[treeController insertObject:leafNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
}

- (IBAction)newGroup:(id)sender;
{
	ESGroupNode *groupNode = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:[self managedObjectContext]];
	static NSUInteger count = 0;
	groupNode.displayName = [NSString stringWithFormat:@"Group %i",++count];
	[treeController insertObject:groupNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];	
}

- (NSArray *)treeNodeSortDescriptors;
{
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES] autorelease]];
}

@end



@implementation ESAppDelegate (NSOutlineViewDragAndDrop)
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteBoard;
{
	[pasteBoard declareTypes:[NSArray arrayWithObject:ESNodeIndexPathPasteBoardType] owner:self];
	[pasteBoard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:ESNodeIndexPathPasteBoardType];
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)proposedParentItem proposedChildIndex:(NSInteger)proposedChildIndex;
{
	if (proposedChildIndex == -1) // will be -1 if the mouse is hovering over a leaf node
		return NSDragOperationNone;
			
	NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ESNodeIndexPathPasteBoardType]];
	BOOL targetIsValid = YES;
	for (NSIndexPath *indexPath in draggedIndexPaths) {
		NSTreeNode *node = [treeController nodeAtIndexPath:indexPath];
		if (!node.isLeaf) {
			if ([proposedParentItem isDescendantOfNode:node] || proposedParentItem == node) { // can't drop a group on one of its descendants
				targetIsValid = NO;
				break;
			}
		}
	}
	return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)proposedParentItem childIndex:(NSInteger)proposedChildIndex;
{
	NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ESNodeIndexPathPasteBoardType]];
	
	NSMutableArray *draggedNodes = [NSMutableArray array];
	for (NSIndexPath *indexPath in droppedIndexPaths)
		[draggedNodes addObject:[treeController nodeAtIndexPath:indexPath]];
	
	NSIndexPath *proposedParentIndexPath;
	if (!proposedParentItem)
		proposedParentIndexPath = [[[NSIndexPath alloc] init] autorelease]; // makes a NSIndexPath with length == 0
	else
		proposedParentIndexPath = [proposedParentItem indexPath];

	[treeController moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex]];
	return YES;
}

@end

@implementation ESAppDelegate (NSOutlineViewDelegate)
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item;
{
    //NSLog(@"called - isGroupItem");
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	
	if ([[item representedObject] respondsToSelector:@selector(isSpecialGroup)] ) {
		return [[[item representedObject] isSpecialGroup] boolValue];
	}
	else {
		//NSLog(@"%@\n does NOT respond to isSpecialGroup", [item representedObject]);
		return NO;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
    NSLog(@"called - shouldCollapseItem");
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	return [[[item representedObject] canCollapse] boolValue];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item;
{
    NSLog(@"called - outlineView:shouldExpandItem");
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	
	if ([[item representedObject] respondsToSelector:@selector(canExpand)] ) {
		NSLog(@"item can respond to \"canExpand\" and: %hhu", [[[item representedObject] canExpand] boolValue]);
        
		return [[[item representedObject] canExpand] boolValue];
	}
	else {
		NSLog(@"%@\n\ndoes not respond to \"canExpand\"", [item representedObject]);
	}
	
	
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	return [[(ESTreeNode *)[item representedObject] isSelectable] boolValue];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification;
{
	if ([[[[notification userInfo] valueForKey:@"NSObject"] representedObject] respondsToSelector:@selector(isExpanded)] ) {
		ESGroupNode *collapsedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
		collapsedItem.isExpanded = [NSNumber numberWithBool:NO];
	}
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification;
{
	if ([[[[notification userInfo] valueForKey:@"NSObject"] representedObject] respondsToSelector:@selector(isExpanded)] ) {
		ESGroupNode *expandedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
		expandedItem.isExpanded = [NSNumber numberWithBool:YES];
	}
}
@end

