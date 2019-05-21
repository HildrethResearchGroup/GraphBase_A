//
//  HNTabViewController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/10/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <DataGraph/DataGraph.h>
#import "HNAppDelegateAsDataSource.h"
#import "PreCompiledHeaders.h"

#import "HNTabViewController.h"
#import "HNDataTableView.h"
#import "HNPreferencePanelWindowController.h"
#import "DMTabBar.h"
#import "DMPaletteContainer.h"
#import "DMPaletteSectionView.h"
#import "HNNSNotificationStrings.h"
#import "HNTextFieldLabel.h"

// Line Numbers
#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"
#import "MarkerLineNumberView.h"

// Core Data
#import "HNCoreDataHeaders.h"


// TabView String Contants
#define kTabBarElements     [NSArray arrayWithObjects: \
[NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"Tab-Info"],@"image",@"Show the Info Inspector",@"title",nil], \
[NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"Tab-Collections"],@"image",@"Show the Collection Inspector",@"title",nil], \
[NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"Tab-Text"],@"image",@"Show the Data Text File",@"title",nil], \
[NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"Tab-Parser"],@"image",@"Show the Parser Inspector",@"title",nil], \
[NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"Tab-Graph"],@"image",@"Show the Graph Template Inspector",@"title",nil], \
[NSDictionary dictionaryWithObjectsAndKeys: [NSImage imageNamed:@"Tab-Table"],@"image",@"Show the Table View Inspector",@"title",nil],nil]

//extern NSString *HNGreyOrColorIconKey;


@implementation HNTabViewController

@synthesize delegate    = _delegate;
@synthesize datasource  = _datasource;

@synthesize textField_dataItemDisplayName		= _textField_dataItemDisplayName;
@synthesize textField_dataDetails_filePath      = _textField_dataItem_filePath;

@synthesize tableView_availableGraphTemplates	= _tableView_availableGraphTemplates;
@synthesize tableView_availableParsers			= _tableView_availableParsers;

@synthesize dataGraphTemplateController			= _dataGraphTemplateController;
@synthesize graphTemplateDrawingView			= _graphTemplateDrawingView;
@synthesize dataTableView						= _dataTableView;
@synthesize dataTextView						= _dataTextView;
@synthesize scrollView_dataText                 = _scrollView_dataText;


+(void) initialize {
    // Set up Defaults
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Archive the Grey/Color icon default
    // NO = color icons, YES = grey icons
    NSNumber *iconColor = [NSNumber numberWithInteger: NO];
    [defaultValues setObject:iconColor forKey:HNGreyOrColorIconKey];
    
    // Register the dictionary of defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}



-(id) init {
    DLog(@"CALLED - HNTabViewController: init");
	self = [super init];
	
	if (!self) {
		return nil;
	}
	
	
	// Notification Center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	// Register for changing Icon colors
    [nc addObserver:self
           selector:@selector(handleGreyOrColorIconChange:)
               name:HNGreyOrColorIconNotification
             object:nil];		// Handle Icon Color Change
	
	
	
	return self;
}

-(void) awakeFromNib {
	//DLog(@"Called - HNTabViewController: awakeFromNib");
	// Set greyOrColor option for icons from Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *greyOrColorIconNumber = [defaults objectForKey:HNGreyOrColorIconKey];
	[self loadTabBarWithTemplate: [greyOrColorIconNumber boolValue]];
	
	
	// Set up graphTemplateDrawingView
	self.dataGraphTemplateController = [DGController controllerWithFileInBundle:@"InitialGraph"];
	[self.dataGraphTemplateController setDrawingView: self.graphTemplateDrawingView];
    [self.dataGraphTemplateController setDataTable: self.dataTableView];
	[self.dataGraphTemplateController setDelegate: self];
	
	
	// Set up DMPalettes for Inspector
	[self loadPalettesForInspector];
	
	NSSize bigSize = NSMakeSize(FLT_MAX, FLT_MAX);
	[[self.dataTextView enclosingScrollView] setHasHorizontalScroller: YES];
	[self.dataTextView setHorizontallyResizable: YES];
	[self.dataTextView setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
	[[self.dataTextView textContainer] setContainerSize: bigSize];
	[[self.dataTextView textContainer] setWidthTracksTextView: NO];
    
    lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:self.scrollView_dataText];
    [self.scrollView_dataText setVerticalRulerView:lineNumberView];
    [self.scrollView_dataText setHasHorizontalRuler:NO];
    [self.scrollView_dataText setHasVerticalRuler:YES];
    [self.scrollView_dataText setRulersVisible:YES];
	
    [self.dataTextView setFont:[NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]]];

    

    
}





#pragma mark -
#pragma mark UI Elements
-(void) handleGreyOrColorIconChange: (NSNotification *) note {
    //DLog(@"Called - HNAppDelegate: handleGreyOrColorIconChange");
    bool iconState = NO;
    //DLog(@"Recieved notification: %@", note);
    NSNumber *iconStateNumber = [[note userInfo] objectForKey: @"greyOrColorIconState"];
    if ([iconStateNumber integerValue] <= 0) {
        iconState = NO;
    }
    else {
        iconState = YES;
    }
    
    [self loadTabBarWithTemplate: iconState];
}



-(void) loadTabBarWithTemplate: (bool)templateState {
    //DLog(@"Called - HNAppDelegate: loadTabBarWithTemplate");
    if (!tabBar) {
		DLog(@"No tabBar");
	}

	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];

    
    // Create an array of DMTabBarItem objects
    [kTabBarElements enumerateObjectsUsingBlock:^(NSDictionary* objDict, NSUInteger idx, BOOL *stop) {
        NSImage *iconImage = [objDict objectForKey:@"image"];
		if (!iconImage) {
			DLog(@"NO ICON IMAGE");
		}
        //[iconImage setTemplate:YES];
        [iconImage setTemplate: templateState];
        
        DMTabBarItem *item1 = [DMTabBarItem tabBarItemWithIcon:iconImage tag:idx];
        item1.toolTip = [objDict objectForKey:@"title"];
        item1.keyEquivalent = [NSString stringWithFormat:@"%ld",idx];
        item1.keyEquivalentModifierMask = NSCommandKeyMask;
        [items addObject:item1];
    }];
    
    //DLog(@"Finished creating the array of DMTabBarItems objects");
    
    // Load them
    tabBar.tabBarItems = items;
    
    // Handle selection events
    [tabBar handleTabBarItemSelection:^(DMTabBarItemSelectionType selectionType, DMTabBarItem *targetTabBarItem, NSUInteger targetTabBarItemIndex) {
        if (selectionType == DMTabBarItemSelectionType_WillSelect) {
            //DLog(@"Will select %lu/%@",targetTabBarItemIndex,targetTabBarItem);
            [tabView selectTabViewItem:[tabView.tabViewItems objectAtIndex:targetTabBarItemIndex]];
        } else if (selectionType == DMTabBarItemSelectionType_DidSelect) {
            //DLog(@"Did select %lu/%@",targetTabBarItemIndex,targetTabBarItem);
        }
    }];
    
    //DLog(@"finisehd loadTablBarWithTemplate");
}

-(void) loadPalettesForInspector {
	// CHANGE
	[self loadInspectorDataView];
    [self loadInspectorParserView];
    [self loadInspectorGraphView];
	[self loadInspectorCollectionView];
    
}


-(void) loadInspectorDataView {
	//DLog(@"CALLED - loadInspectorDataView");
    //START: Data Inspection Palette
	//NSRect bound_dataInspector = NSMakeRect(20, 20, NSWidth(inspectorDataView.frame) - 50.0f, NSHeight(inspectorDataView.frame) - 80.0f);
	NSRect bound_dataInspector = NSMakeRect(0, 0, NSWidth(inspectorDataView.frame), NSHeight(inspectorDataView.frame));
	
	containerDataview = [[DMPaletteContainer alloc] initWithFrame: bound_dataInspector];
	[inspectorDataView addSubview: containerDataview];
    [inspectorDataView setAutoresizesSubviews: YES];
	
	
	
	// Make each palette Section
	DMPaletteSectionView *paletteSection_dataDetails = [[DMPaletteSectionView alloc] initWithContentView: paletteView_dataDetails andTitle: @"Current Data"];
	
	DMPaletteSectionView *paletteSection_dataExperimentalDetails = [[DMPaletteSectionView alloc] initWithContentView: paletteView_dataExperimentalDetails andTitle: @"Experiment Details"];
	
	DMPaletteSectionView *palleteSection_dataExperimentalDetailsFromDataFile = [[DMPaletteSectionView alloc] initWithContentView: palleteView_dataExperimentalDetailsFromDataFile andTitle: @"Experiment Details from Data File"];
	
	
	// Add Palette Section view to container data View in the order that they need to appear
	containerDataview.sectionViews = @[ paletteSection_dataDetails, paletteSection_dataExperimentalDetails, palleteSection_dataExperimentalDetailsFromDataFile ];
    
    // Add Notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver: self
           selector: @selector(setLabelsSize:)
               name: NSViewFrameDidChangeNotification
             object: self.textField_dataDetails_filePath];
    
    [nc addObserver: self
           selector: @selector(setLabelsSize:)
               name: NSViewFrameDidChangeNotification
             object: self.textField_dataItemDisplayName];
    
    
    [containerDataview setAutoresizesSubviews: YES];
    
	//DLog(@"FINISHED - loadInspectorDataView");
}
//END: Data Inspection Palette

-(void) setLabelsSize: (NSNotification *) notification {
    if ([notification.object isKindOfClass: [NSView class]]) {
        [notification.object invalidateIntrinsicContentSize];
    }

}

-(void) loadInspectorGraphView {
	//DLog(@"CALLED - loadInspectorGraphView");
    NSRect bound = NSMakeRect(0, 0, NSWidth(inspectorGraphView.frame), NSHeight(inspectorGraphView.frame));
	containerGraphView = [[DMPaletteContainer alloc] initWithFrame: bound];
    
    [inspectorGraphView addSubview: containerGraphView];
    
    DMPaletteSectionView *paletteSection_availableGraphs = [[DMPaletteSectionView alloc] initWithContentView: paletteView_availableGraphs andTitle: @"Available Graph Templates"];
    
    DMPaletteSectionView *paletteSection_graphDetails = [[DMPaletteSectionView alloc] initWithContentView: paletteView_graphFileDetails andTitle: @"File Details"];
    
    DMPaletteSectionView *paletteSection_graphPreview = [[DMPaletteSectionView alloc] initWithContentView: paletteView_graphPreview andTitle: @"Graph Preview"];
    
    
    // Add Palette Section view to container data View in the order that they need to appear
    containerGraphView.sectionViews = @[ paletteSection_availableGraphs, paletteSection_graphDetails,  paletteSection_graphPreview];
	
	//DLog(@"FINISHED - loadInspectorGraphView");
}



-(void) loadInspectorParserView {
	//DLog(@"CALLED - loadInspectorParserView");
    NSRect bound = NSMakeRect(0, 0, NSWidth(inspectorParserView.frame), NSHeight(inspectorParserView.frame));
	containerParserView = [[DMPaletteContainer alloc] initWithFrame: bound];
    
    [inspectorParserView addSubview: containerParserView];
    
    
    DMPaletteSectionView *paletteSection_availableParsers = [[DMPaletteSectionView alloc] initWithContentView: paletteView_availableParsers andTitle: @"Available Parsers"];
    
    
    DMPaletteSectionView *paletteSection_parserDetails = [[DMPaletteSectionView alloc] initWithContentView: paletteView_parseDetails andTitle: @"Parser Details"];
    
    
    // Add Palette Section view to container data View in the order that they need to appear
    containerParserView.sectionViews = @[ paletteSection_availableParsers, paletteSection_parserDetails ];
	
	//DLog(@"FINISHED - loadInspectorParserView");
}



-(void) loadInspectorCollectionView {
	//DLog(@"CALLED - loadInspectorCollectionView");
    NSRect bound = NSMakeRect(0, 0, NSWidth(inspectorCollectionView.frame), NSHeight(inspectorCollectionView.frame));
	containerCollectionView = [[DMPaletteContainer alloc] initWithFrame: bound];
    
    [inspectorCollectionView addSubview: containerCollectionView];
    
    
    DMPaletteSectionView *paletteSection_collectinDetails = [[DMPaletteSectionView alloc] initWithContentView: paletteView_collectionDetails andTitle: @"Collection Details"];
    
    
    
    // Add Palette Section view to container data View in the order that they need to appear
    containerCollectionView.sectionViews = @[ paletteSection_collectinDetails ];
	
	//DLog(@"FINISHED - loadInspectorCollectionView");
}

-(void) loadDataTableView {
    //NSRect bound = NSMakeRect(0, 0, NSWidth(inspectorDGDataTable.frame), NSHeight(inspectorDGDataTable.frame));
    
}


#pragma mark - IBActions
-(IBAction)showInFinder:(id)sender {
    DLog(@"CALLED - HNDataViewController: showInFinder");
    // CHANGED
    //NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    
    //SEL selectedObjectsSelector = NSSelectorFromString(@"selectedObjects");
    SEL filePathSelector = NSSelectorFromString(@"filePath");
    NSArray *objectsArray;
    NSMutableArray *filePaths = [NSMutableArray array];
    NSString *nextFilePath;
    
    NSMenu *senderMenu;
    if ( [sender isKindOfClass: [NSMenuItem class]] ) {
        senderMenu = [sender menu];
    }
    
    
    if ( senderMenu == contextMenu_availableGraphsTable) {
        NSArrayController *fileSource = [self.datasource allGraphTemplateListArrayControllerFromSource ];
        objectsArray = [fileSource selectedObjects];
    }
    
    
    for (id nextObject in objectsArray) {
        if ([nextObject respondsToSelector: filePathSelector]) {
            [filePaths addObject: [nextObject performSelector: filePathSelector]];
            //nextFilePath = [nextObject filePath];
        }
        else {
            DLog(@"%@ does not respond to 'filePath' selector", nextFilePath);
            nextFilePath = nil;
        }

    }
    
    
    
    // Post Notification
    if ([filePaths count] > 0) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSString *notificationType = hnRevealInFinderNotification;
        NSDictionary *userInfo = @{ hnArrayOfFilePathsKey : filePaths};
        [nc postNotificationName: notificationType
                          object: self
                        userInfo: userInfo];
    }
}


-(IBAction)openGraphInDataGraph:(id)sender {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    NSArray *arrayOfGraphTemplatesToOpen = [[self.datasource allGraphTemplateListArrayControllerFromSource] selectedObjects];
    
    if ([arrayOfGraphTemplatesToOpen count] > 0) {
        NSString *notificationType = hnOpenInDataGraphNotification;
        NSDictionary *userInfo = @{HNExportItemsArrayKey : arrayOfGraphTemplatesToOpen};
        
        [nc postNotificationName: notificationType
                          object: self
                        userInfo: userInfo];
    }

    
    /*
     NSString *applicationName = @"DataGraph";
     NSString *graphFilePath;
     
     id graphObject = [[controller_GraphTemplate selectedObjects] lastObject];
     graphFilePath = [graphObject valueForKey: @"filePath"];
     
     NSFileManager *fm = [NSFileManager defaultManager];
     BOOL success = NO;
     
     if ([fm fileExistsAtPath: graphFilePath]) {
     success = [[NSWorkspace sharedWorkspace] openFile:graphFilePath withApplication:applicationName];
     }
     
     DLog(@"success = %i", success);

     
     */
}

/*
-(IBAction)showInFinder:(id)sender {
    DLog(@"CALLED - HNDataViewController: showInFinder");

    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    
    //SEL selectedObjectsSelector = NSSelectorFromString(@"selectedObjects");
    SEL filePathSelector = NSSelectorFromString(@"filePath");
    NSArray *objectsArray;
    NSString *nextFilePath;
    
    if ( [sender tag] == 1 ) {
        NSArrayController *fileSource = [self.datasource allGraphTemplateListArrayControllerFromSource];
        objectsArray = [fileSource selectedObjects];
    }
    else {
        return;
    }
    
    for (id nextObject in objectsArray) {
        if ([nextObject respondsToSelector: filePathSelector]) {
            nextFilePath = [nextObject filePath];
        }
        else {
            nextFilePath = nil;
        }
        
        if (nextFilePath) {
            [workSpace selectFile:nextFilePath inFileViewerRootedAtPath:nil];
        }
    }
}

-(IBAction)openGraphInDataGraph:(id)sender {
    NSString *applicationName = @"DataGraph";
    

    NSArrayController *sourceController = [self.datasource dataItemsArrayControllerFromSource];
    HNGraphTemplate *selectedGraphTemplate = [[[sourceController selectedObjects] firstObject] graphTemplate];
    
    
    NSString *graphFilePath = [selectedGraphTemplate valueForKey: @"filePath"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = NO;
    
    if ([fm fileExistsAtPath: graphFilePath]) {
        success = [[NSWorkspace sharedWorkspace] openFile:graphFilePath withApplication:applicationName];
    }
    
    
    DLog(@"success = %i", success);
}
*/


-(IBAction) exportParsers:(id)sender {
    NSArray *objectsArray;
    DLog(@"sender = %@", sender);
    NSMenu *senderMenu;
    
    if ( [sender isKindOfClass: [NSMenuItem class]] ) {
        senderMenu = [sender menu];
    }
    DLog(@"senderMenu = %@", senderMenu);
    
    if ( senderMenu == contextMenu_availableParsersTable) {
        NSArrayController *fileSource = [self.datasource allParserListArrayControllerFromSource ];
        objectsArray = [fileSource selectedObjects];
    }
    else {
        DLog(@"sender != contextMenu_availableParsersTable");
    }
    
    if ([objectsArray count] > 0) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSString *notificationType = HNExportParseTemplateNotification;
        NSDictionary *userInfo = @{HNExportItemsArrayKey : objectsArray, HNExportItemsUsingKey : HNExportItemsUsingSavePanel};
        
        [nc postNotificationName: notificationType object: self userInfo: userInfo];
        
    }
    else {
        DLog(@"[objectsArray count] !> 0");
    }
}



@end


#pragma mark -
#pragma mark NSControl Delegate
@implementation HNTabViewController (NSControlDelegate)
- (void) controlTextDidChange: (NSNotification *)note {

}

@end




#pragma mark -
#pragma mark TableView Data Source
@implementation HNTabViewController (NSTableViewDataSource)

-(int) numberOfRowsInTableView: (NSTableView *) aTableView {
	//DLog(@"CALLED: HNTabViewController - numberOfRowsInTableView");
	
	// CHANGED
	/*
	NSArrayController *localDataItemsArrayController = [datasource dataItemsArrayControllerFromSource];
    DLog(@"[dataItemsArrayController count] = %lu", [[localDataItemsArrayController arrangedObjects] count]);
    
    return (int) [[localDataItemsArrayController arrangedObjects] count];
	 */
	return  0;
	
}


-(id) tableView: (NSTableView *) aTableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(NSInteger)row {
	//DLog(@"CALLED: HNTabViewController - objectValueForTableColumn");
	
	// CHANGED
	/*
	
	if ([[aTableView identifier] isEqualToString: @"availableParsersTable"]) {
		
		NSArrayController *localDataItemsArrayController = [datasource dataItemsArrayControllerFromSource];
		
		NSArray * currentDataItems = [localDataItemsArrayController arrangedObjects];
		
		if ([[tableColumn identifier] isEqualToString: @"collectionType"]) {
			DLog(@"next type of object = %@", [[currentDataItems objectAtIndex:row] class]);
			HNDataItem *nextDataItem = (HNDataItem *) [currentDataItems objectAtIndex: row];
			NSString *displayString =  [nextDataItem displayName];
			DLog(@"displayName = %@", displayString);
			return displayString;
		}
		else if ([[tableColumn identifier] isEqualToString: @"collection.collectinType"] ) {
			HNDataItem *nextDataItem = (HNDataItem *) [currentDataItems objectAtIndex: row];
			NSString *collectionType = nextDataItem.collection.collectionType;
			return collectionType;
		}
		else {
			return nil;
		}
	}
	 */
	
	return nil;
}


/*
 -(id) tableView: (NSTableView *) aTableView
 setObjectValue:(id)object
 forTableColumn:(NSTableColumn *)tableColumn
 row:(NSInteger)row {
 
 }
 */

// END - NSNSTableViewDataSource
@end

#pragma mark -
#pragma mark TableView Delegate
@implementation HNTabViewController (NSTableViewDelegate)
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	//DLog(@"CALLED - HNTabViewController: tableViewSelectionDidChange");
	
	if ([aNotification object] == [self tableView_availableGraphTemplates]) {
		DLog(@"Selected tableView_availableGraphTemplates");
		
		// Get selected graphTemplate
		if (!self.datasource) {
			DLog(@"No datasource");
			return;
		}
		NSArrayController *localGraphTemplatesArrayController = [self.datasource allGraphTemplateListArrayControllerFromSource];
		
		if (!localGraphTemplatesArrayController) {
			DLog(@"NO localGraphTemplatesArrayController");
			return;
		}
		
		//DLog(@"selectedObjects = %@", [localGraphTemplatesArrayController selectedObjects]);
		
		HNGraphTemplate *selectedGraphTemplate = [[localGraphTemplatesArrayController selectedObjects] firstObject];
        //DLog(@"selectedGraphTemplate = %@", selectedGraphTemplate);
		
		if (!selectedGraphTemplate) {
			DLog(@"NO selectedGraphTemplate");
            [self.dataGraphTemplateController overwriteWithScriptFileInBundle: @"EmptyGraph"];
            [self.dataGraphTemplateController redrawNow];
			return;
		}
		
		// Check to make sure that Graph Template exists at path
		NSString *graphTemplateFilePath = selectedGraphTemplate.filePath;
		NSFileManager *fm = [NSFileManager defaultManager];
		
		if ( ![fm fileExistsAtPath: graphTemplateFilePath]) {
			DLog(@"file not found at: %@", graphTemplateFilePath);
			return;
		}
		
		// overwrite DGController wtih graphTemplate
		[self.dataGraphTemplateController overwriteWithScriptFile: graphTemplateFilePath];
	}
	
	if ([aNotification object] == [self tableView_availableParsers]) {
		
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    
    if ([aTableView isEqualTo: self.dataTableView]) {
        return NO;
    }

    
    return YES;
}

@end

#pragma mark -
#pragma mark NSMenu Delegate
@implementation HNTabViewController (NSMenuDelgate)

-(void) menu: (NSMenu *) menu willHighlightItem:(NSMenuItem *)item {
    NSString *menuTitle = [menu title];
    DLog(@"menuTitle = %@", menuTitle);
    
    if ([menuTitle isEqualToString: @"File Types Selector"]) {
        
        // Item 1 is for user defined/limited file types
        // Item 2 is for all file types
 
    }
}

@end

