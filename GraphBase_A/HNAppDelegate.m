//
//  HNAppDelegate.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 7/30/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//



// App and View Delegates
#import "HNAppDelegate.h"
#import "HNAppDelegate+HNCoreDataManagement.h"

#import "HNTabViewController.h"
#import "HNSourceViewController.h"
#import "HNDataViewController.h"


// UI
#import "HNOutlineView.h"
#import "HNTreeController.h"
#import "HNTreeNodeArrayController.h"
#import "HNPreferencePanelWindowController.h"
#import "DMTabBar.h"
#import "HNDataTableView.h"


// String Constants
#import "HNNSNotificationStrings.h"
#import "HNPasteBoardTypes.h"
#import "HNUserDefaultStrings.h"


// Core Data
#import "HNCoreDataHeaders.h"


// Parsing
#import "HNDataParser.h"

// Views
#import "HNAccessoryView.h"





@implementation HNAppDelegate

@synthesize persistentStoreCoordinator	= _persistentStoreCoordinator;
@synthesize managedObjectModel			= _managedObjectModel;
@synthesize managedObjectContext		= _managedObjectContext;


// View Controllers
@synthesize tabViewController           = _tabViewController;
@synthesize dataViewController			= _dataViewController;
@synthesize treeNodeArrayController		= _treeNodeArrayController;
@synthesize sourceListViewController    = _sourceListViewController;



// Array and Tree Controllers
@synthesize treeController						= _treeController;
@synthesize dataItemsArrayController			= _dataItemsArrayController;
@synthesize parserListArrayController			= _parserListArrayController;
@synthesize graphTemplateListArrayController	= _graphTemplateListArrayController;
@synthesize allParserListArrayController		= _allParserListArrayController;
@synthesize allGraphTemplateListArrayController = _allGraphTemplateListArrayController;
@synthesize collectionTypesArrayController      = _collectionTypesArrayController;

// UNUSED
@synthesize typesOfCollectionsArrayController	= _typesOfCollectionsArrayController;


#pragma mark -
#pragma mark Initialization Methods

+(void) initialize {	
    //Set up Defaults
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
	
    // Default Dictionary for data file types
    NSArray *dataFileTypeExtensions = @[@"text", @"txt", @"dat"];
    [defaultValues setObject: dataFileTypeExtensions
					  forKey: HNExtensionsForDataFileTypesKey];
	
	
	// Default Dictionary for Graph Template Types
	NSArray *defaultGraphTemplateExtensions = @[@"dgraph"];
	[defaultValues setObject: defaultGraphTemplateExtensions
					  forKey: HNExtensionsForGraphTemplatesKey];
	
	// Parse Template Types
	NSArray *defaultParseTemplateExtensions = @[@"gbparser"];
	[defaultValues setObject: defaultParseTemplateExtensions
					  forKey: HNExtensionsForParseTemplatesKey];
	
	
	// Default DGRange for resetting the cropped range to -inf, inf
	NSNumber *resetToFullRange = [NSNumber numberWithBool: YES];
	[defaultValues setObject: resetToFullRange
					  forKey:HNResetCropOnNewSelectionKey];
	
	// Default HNShowMissingFileAlertKey to yes
	NSNumber *showMissingFileAlert = [NSNumber numberWithBool: YES];
	[defaultValues setObject: showMissingFileAlert
					  forKey:HNShowMissingFileAlertKey];
    
    
    
    // Default DataGraph Application name
    NSString *dataGraphApplicationName = @"DataGraph";
    [defaultValues setObject: dataGraphApplicationName
                      forKey: hnApplicationNameDataGraph];
    
    // Default Finder Application name
    NSString *finderApplicationName = @"Finder";
    [defaultValues setObject: finderApplicationName
                      forKey: hnApplicationNameFinder];
    
    
    
    // Default Parse separators
    NSDictionary *parseSeparators = @{@"Tab" : @"\t", @"Space" : @" ", @"Colon" : @":", @"Semicolon" : @";", @"Comma" : @","};
    [defaultValues setObject: parseSeparators
                      forKey: hnUDParseSeparatorDictionaryKey];
    
    

    
    // Register the dictionary of defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
	
}


-(id) init {
    //DLog(@"Called - HNAppDelegate: init");
    self = [super init];
    if (!self) {
        return nil;
    }
	
	_dataItemsArrayController				= [[NSArrayController alloc] init];
	_parserListArrayController				= [[NSArrayController alloc] init];
	_graphTemplateListArrayController		= [[NSArrayController alloc] init];
	_allGraphTemplateListArrayController	= [[NSArrayController alloc] init];
	_allParserListArrayController			= [[NSArrayController alloc] init];
	_collectionTypesArrayController         = [[NSArrayController alloc] init];
	
    /*
	NSFetchRequest *collectionsRequest = [NSFetchRequest fetchRequestWithEntityName: @"HNCollectionType"];
    NSError *error;
    NSArray *collectionsArray = [_managedObjectContext executeFetchRequest: collectionsRequest error:&error];
    
    [_collectionTypesArrayController addObjects: collectionsArray];
     
     */
	
	_treeController = [[HNTreeController alloc] init];
	[_treeController setSelectsInsertedObjects: YES];
	

	// Register for Notifications
	[self registerForNotifications];
	/*
	NSDictionary *userDefaults = @{@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints" : [NSNumber numberWithBool: YES]};
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
	 */
    return self;
}


-(void) awakeFromNib {
    [super awakeFromNib];
    //DLog(@"Called - HNAppDelegate: awakeFromNib");
	[self.treeController setSelectionIndexPath: [NSIndexPath indexPathWithIndex: 0]];
    NSArray *dataSortDescriptors = [self arrayControllerSortDescriptors];
    DLog(@"dataSortDescriptors = %@", dataSortDescriptors);
    [self.dataItemsArrayController setSortDescriptors: dataSortDescriptors];
    
    [self.dataItemsArrayController              fetch: self];
	[self.allParserListArrayController          fetch: self];
	[self.allGraphTemplateListArrayController   fetch: self];
    [self.collectionTypesArrayController        fetch: self];
    
    NSArray *treeNodes = [HNTreeNode findAllObjects];
    
    DLog(@"number of treeNodes = %lu", [treeNodes count]);
    
    if ([treeNodes count] <= 0) {
        // Need to add a Data Folder
        //-(HNTreeNode *) addNewCollectionOfType: (NSString *) collectionType withInsertionPath: (NSIndexPath *) insertionPath
        HNTreeNode *newTreeNode = [NSEntityDescription insertNewObjectForEntityForName:@"HNTreeNode"
                                                                  inManagedObjectContext:[self managedObjectContext]];
        newTreeNode.isLeaf = [NSNumber numberWithBool: NO];
        NSString *collectionType = HNFolderCollectionType;
        NSPredicate *collectionPredicate = [NSPredicate predicateWithFormat:@"typeName MATCHES %@", collectionType];
        NSSet *fetchedCollections = [self.managedObjectContext fetchObjectsForEntityName: @"HNCollectionType" withPredicate: collectionPredicate];
        HNCollectionType *collectionTypeIn = [[fetchedCollections allObjects] firstObject];
        [newTreeNode setCollectionType: collectionTypeIn];
        newTreeNode.displayName = @"Data";
        NSIndexPath *insertionPath = [self.treeController indexPathForInsertion];
        [self.treeController insertObject: newTreeNode atArrangedObjectIndexPath: insertionPath];
        
    }
	//[self.treeController rearrangeObjects];
}



-(void) setUserDefaults {
	
}




-(void) registerForNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	
	// Register for sourceList/outlineView selection changes
	[nc addObserver: self
		   selector:@selector(sourceViewDidChangeSelectionResponse:)
	 //name: nil
			   name:HNSouceListViewSelectionDidChange
			 object:nil];
	
	
	
	// Register for Adding a new Collection to HNGroupNode (Generic Collection, Project) or HNLeafNode (Experiment)
	[nc addObserver: self
		   selector: @selector(addCollectionFromNotification:)
			   name: HNAddCollectionNotification
			 object: nil];
	
	// Register for Adding new Data File
	[nc addObserver: self
		   selector: @selector(addDataFilesFromNotification:)
			   name: HNAddDataFilesNotification
			 object: nil];
	
	// Register for Adding new Graph Template
	[nc addObserver: self
		   selector: @selector(addGraphTemplateFromNotification:)
			   name: HNAddGraphTemplateNotification
			 object: nil];
	
	
	// Register for Adding new Parse Template
	[nc addObserver: self
		   selector: @selector(addParseTemplateFromNotification:)
			   name: HNAddParseTemplateNotification
			 object: nil];
	
	// Register for Adding Directory
	[nc addObserver: self
		   selector: @selector(addDirectoryFromNotification:)
			   name: HNAddDirectoryNotification
			 object:nil];
	
	
	
	
	// Register for Removing Data Items
	[nc addObserver: self
		   selector:@selector(removeDataItemsFromNotification:)
	 //name: nil
			   name:HNRemoveDataFilesNotification
			 object:nil];
	
	
	// Register for Removing Collections
	[nc addObserver: self
		   selector:@selector(removeCollectionFromNotification:)
	 //name: nil
			   name:HNRemoveCollectionNotification
			 object:nil];
	
	
	// Register for Removing Graph Templates
	[nc addObserver: self
		   selector:@selector(removeGraphTemplateFromNotification:)
	 //name: nil
			   name:HNRemoveGraphTemplateNotification
			 object:nil];
	
	
	// Register for Removing Parse Templates
	[nc addObserver: self
		   selector:@selector(removeParseTemplateFromNotification:)
	 //name: nil
			   name:HNRemoveParseTemplateNotification
			 object:nil];
	
	
	
	// Register for Moving Data Items
	[nc addObserver: self
		   selector:@selector(moveDataItemsNotification:)
			   name: HNMoveDatatItemsNotification
			 object: nil];
    
    
    // Register for Exporting Data Items
	[nc addObserver: self
		   selector:@selector(exportDataItemsNotification:)
			   name: HNExportDataFilesNotification
			 object: nil];
    
    
    // Register for Exporting Parse Templates Items
	[nc addObserver: self
		   selector:@selector(exportParseTemplateNotification:)
			   name: HNExportParseTemplateNotification
			 object: nil];
    
    
    // Register for Exporting Graph Templates Items
	[nc addObserver: self
		   selector:@selector(exportGraphTemplateNotification:)
			   name: HNExportGraphTemplateNotification
			 object: nil];
    
    
    
    //  Register for Revealing in Finder
    [nc addObserver: self
           selector: @selector(revealFilesInFinder:)
               name: hnRevealInFinderNotification
             object: nil];
    
    // Register for Openning in DataGraph
    [nc addObserver: self
           selector: @selector(openGraphsInDataGraph:)
               name: hnOpenInDataGraphNotification
             object: nil];
	
}


-(void) dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver: self];
	
	_persistentStoreCoordinator = nil;
	_managedObjectContext = nil;
	
}



#pragma mark -
#pragma mark Application Methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DLog(@"Called - HNAppDelegate: applicationDidFinishLaunching");
    
    // Set AppDelegate as datasource and delegate for all primary controllers
	[self setAppDelegateAsDataAndDelegateSource];
	
	// Fill in menu items of Add Button of Source View
	[self.sourceListViewController setAddButtonsMenuItems];
	[self.sourceListViewController setRemoveButtonsMenuItems];
	
    [self.allParserListArrayController rearrangeObjects];
	
	//DLog(@"Application Support Folder = %@", [self applicationFilesDirectory]);
    
    [[self.dataViewController dataGraphController] setDataTable: [self.tabViewController dataTableView]];
	
    [_window setAutodisplay: YES];
}

// Used to set AppDelegate as data and delegate source for the sub-controllers
-(void) setAppDelegateAsDataAndDelegateSource {
	if (!_tabViewController) {
        DLog(@"tabViewController does not exist");
    }
    else {
        [self.tabViewController setDatasource: self];
        [self.tabViewController setDelegate:   self];
    }
    
    if (!self.dataViewController) {
        DLog(@"dataViewController does not exist");
    }
    else {
        [self.dataViewController setDatasource: self];
        [self.dataViewController setDelegate:   self];
    }
    
    if (!self.sourceListViewController) {
        DLog(@"sourceListViewController does not exist");
    }
    else {
        [self.sourceListViewController setDatasource: self];
        [self.sourceListViewController setDelegate:   self];
    }
    
    // set selected treeeController
    [self.treeController setSelectionIndexPath: [NSIndexPath indexPathWithIndex: 1]];
    
    // CHANGED
    if (!self.dataItemsArrayController) {
        DLog(@"NO dataItemsArrayController");
    }
    
	
	[self.treeController setSelectionIndexPath: [NSIndexPath indexPathWithIndex: 0]];
	
	[self.dataItemsArrayController setSelectionIndex: 0];
}



// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "H-Nano.GraphBase_A" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
	return [[NSApplication sharedApplication] applicationFilesDirectory];
}



- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}


-(void) applicationDidBecomeActive:(NSNotification *)notification {
    [self.window makeKeyAndOrderFront: self];
}

-(BOOL) applicationShouldHandleReopen:(NSApplication *)sender
                    hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [self.window makeKeyAndOrderFront: self];
    }
    return YES;
}




#pragma mark -
#pragma mark Core Data Methods
// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    //DLog(@"Called - HNAppDelegate: managedObjectModel");
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GraphBase_A" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    //DLog(@"Called - HNAppDelegate: persistentStoreCoordinator");
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"GraphBase_A.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}


// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
	//DLog(@"CALLED - HNAppDelegate:  managedObjectContex");
    if (_managedObjectContext) {
		
		NSFetchRequest *collectionsRequest = [NSFetchRequest fetchRequestWithEntityName: @"HNCollectionType"];
		NSError *error;
		NSArray *collectionsArray = [_managedObjectContext executeFetchRequest: collectionsRequest error:&error];
		if (!error) {
			if ([collectionsArray count] < 3) {
				DLog(@"[collectionsArray count] < 3");
				[self setInitialCollectionTypes];
			}
		}
		
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
    
    // Set initial Collection
	NSArray *collectionTypes = [HNCollectionType findAllObjects];
	if ([collectionTypes count] < 3) {
		[self setInitialCollectionTypes];
	}
    
    

    return _managedObjectContext;
}

-(void) setInitialCollectionTypes {
	//DLog(@"CALLED - HNAppDelegate: setInitialCollectionTypes");
	if (!_managedObjectContext) {
		return;
	}
	
	HNCollectionType * experimentCollectionType = [NSEntityDescription insertNewObjectForEntityForName: @"HNCollectionType"
																				inManagedObjectContext: _managedObjectContext];
	[experimentCollectionType setTypeName: @"Experiment"];
    experimentCollectionType.displayName = experimentCollectionType.typeName;
    
	
	HNCollectionType * folderCollectionType = [NSEntityDescription insertNewObjectForEntityForName: @"HNCollectionType"
																			inManagedObjectContext: _managedObjectContext];
	[folderCollectionType setTypeName: @"Folder"];
    folderCollectionType.displayName = folderCollectionType.typeName;
	
	HNCollectionType * projectCollectionType = [NSEntityDescription insertNewObjectForEntityForName:@"HNCollectionType"
																			 inManagedObjectContext: _managedObjectContext];
	[projectCollectionType setTypeName: @"Project"];
    projectCollectionType.displayName = projectCollectionType.typeName;
	
	
}



// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    //DLog(@"Called - HNAppDelegate: windowWillReturnUndoManager");
    return [[self managedObjectContext] undoManager];
}






#pragma mark -
#pragma mark Menu Items
// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}



-(IBAction) exportParseTemplate: (id)sender {
	// Initial test
	// Get selected Parse Template
	NSArray *selectedParseTemplates = [self.allParserListArrayController selectedObjects];
    
	
	NSString *notificationType = HNExportParseTemplateNotification;
	NSDictionary *userInfo = @{HNExportItemsUsingKey : HNExportItemsUsingSavePanel, HNExportItemsArrayKey : selectedParseTemplates};
	
	// Post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName: notificationType
					  object: self
					userInfo: userInfo];
}

-(IBAction) importParseTemplate:(id)sender {
    
    // Get targetTreeNode
    // Put in top level treeNode for the largest user flexibility.  i.e. all the children of the top level have access to the parse template
    HNTreeNode *targetTreeNode = [[self.allParserListArrayController selectedObjects] firstObject];
    NSURL *targetTreeNodeURI	= [[targetTreeNode objectID] URIRepresentation];
    
    
    NSString *notificationType = HNAddParseTemplateNotification;
    NSDictionary *userInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel, HNTreeNodeURIKey : targetTreeNodeURI};
    
    // Post notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName: notificationType
                      object: self
                    userInfo: userInfo];
}



// Opens the Prefernce Panel
-(IBAction) showPreferencePanel: (id)sender {
    // Is prefereneController nil?
    if (!preferenceController) {
        preferenceController = [[HNPreferencePanelWindowController alloc] init];
    }
    
    [preferenceController showWindow:self];
}


-(IBAction) toggleView:(id)sender {
	if ( [self.testView isHidden] ) {
		[self.testView setHidden: NO];
	}
	else {
		[self.testView setHidden: YES];
	}
}


-(void) sourceViewDidChangeSelectionResponse: (NSNotification *) aNote {
	//DLog(@"CALLED - HNAppDelegate: sourceViewDidChangeSelectionResponse");

}


- (NSArray *)treeNodeSortDescriptors {
    //DLog(@"Called - HNAppDelegate: treeNodeSortDescriptors");
	return [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES]];
    
}

-(NSArray *) arrayControllerSortDescriptors {
    NSSortDescriptor *displayNameSort = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending: YES];
    NSSortDescriptor *collectionNameSort = [[NSSortDescriptor alloc] initWithKey: @"treeNode.displayName" ascending:YES];
    NSArray *sortDescriptions = @[collectionNameSort, displayNameSort];
    
    return sortDescriptions;
}



-(NSPredicate *) filterForIsLeaf {
	NSPredicate *isLeafPredicate = [NSPredicate predicateWithFormat:@"isLeaf == YES"];
	
	return isLeafPredicate;
}



#pragma mark -
#pragma mark External Applications
-(void) openGraphsInDataGraph: (NSNotification *) note {
    
    // Set up
    NSDictionary *userInfo = [note userInfo];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *applicationName = [userDefaults objectForKey: hnApplicationNameDataGraph];
    
    BOOL success = NO;
    
    
    // Get Array of HNGraphTemplates to open in DataGraph
    NSArray *graphTemplatesToOpen = [userInfo objectForKey: HNExportItemsArrayKey];
    if ([graphTemplatesToOpen count] == 0) {
        return;
    }
    
    
    // Open files in DataGraph
   
    for ( id nextObject in graphTemplatesToOpen ) {
        NSString *filePath;
        // Get filePath
        if ([nextObject isKindOfClass: [HNGraphTemplate class]]) {
            filePath = [nextObject performSelector: @selector(filePath)];
        }
        
        // Check to see if filePath exists and then open in DataGraph
        if ( [fm fileExistsAtPath: filePath]) {
            success = [[NSWorkspace sharedWorkspace] openFile: filePath
                                              withApplication: applicationName];
        }
        
    }
}

-(void) revealFilesInFinder: (NSNotification *) note {
    DLog(@"CALLED - HNAppDelegate: revealFilesInFinder");
    NSDictionary *userInfo = [note userInfo];
    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    NSFileManager *fm               = [NSFileManager defaultManager];
    
    NSArray *filePathsArray = [userInfo objectForKey: hnArrayOfFilePathsKey];
    if ( [filePathsArray count] == 0) {
        return;
    }
    
    for (NSString *nextFilePath in filePathsArray) {
        if ([fm fileExistsAtPath: nextFilePath]) {
            [workSpace selectFile: nextFilePath
         inFileViewerRootedAtPath: nil];
        }
    }
}



#pragma mark -
#pragma mark HNAppDelegateAsDataSource
-(HNTreeController *) treeControllerFromSource {
    
    return  [self treeController];
}

// ArrayControllers
-(NSArrayController *) dataItemsArrayControllerFromSource {
	
	return  [self dataItemsArrayController];
}

-(NSArrayController *) allGraphTemplateListArrayControllerFromSource {
	return [self allGraphTemplateListArrayController];
}

-(NSArrayController *) graphTemplateListArrayControllerFromSource {
	return [self graphTemplateListArrayController];
}

-(NSArrayController *) allParserListArrayControllerFromSource {
	return [self allParserListArrayController];
}
-(NSArrayController *) parseTemplateListArrayControllerFromSource {
	return [self parserListArrayController];
}


/*
-(NSURL *) applicationFilesDirectoryFromSource {
	return [self applicationFilesDirectory];
}
 */




@end





























