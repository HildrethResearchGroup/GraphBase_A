//
//  HNTabViewController.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/10/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DMTabBar;
@class DMPaletteContainer;
@class DPDrawingView;
@class DPDataTableView;
@class DGController;
@class HNDataTableView;
@class NoodleLineNumberView;

@interface HNTabViewController : NSObject <NSTableViewDataSource> {

    IBOutlet    id  __unsafe_unretained datasource;
    IBOutlet    id  __unsafe_unretained delegate;
	

	
	// Graph Controllers
	DGController					*dataGraphTemplateController;
    
    // Arrays
    NSArray *separatorArrays;
	
	// DMTabBar
	IBOutlet    DMTabBar    *tabBar;
    IBOutlet    NSTabView   *tabView;
	
	
	// Inspector Views
	// Sub-tab views using DMInspectorPalette
	IBOutlet	NSView		*inspectorDataView;
	IBOutlet	NSView		*inspectorGraphView;
	IBOutlet	NSView		*inspectorParserView;
	IBOutlet	NSView		*inspectorDGDataTable;
	IBOutlet	NSView		*inspectorCollectionView;
	
	
	// Palettes of inspectorDataView
	DMPaletteContainer		*containerDataview;
	IBOutlet	NSView		*paletteView_dataDetails;
	IBOutlet	NSView		*paletteView_dataExperimentalDetails;
	IBOutlet	NSView		*palleteView_dataExperimentalDetailsFromDataFile;
	
	    
	// Palettes of inspectorCollectionView
	DMPaletteContainer			*containerCollectionView;
	IBOutlet	NSView			*paletteView_collectionDetails;
	
    
    // Palettes of inspectorGraphView
    DMPaletteContainer			*containerGraphView;
    IBOutlet    NSView			*paletteView_availableGraphs;
    IBOutlet    NSView			*paletteView_graphFileDetails;
    IBOutlet    NSView			*paletteView_graphPreview;
	
	IBOutlet	HNDataTableView	*tableView_availableGraphTemplates;
	IBOutlet	DPDrawingView	*graphTemplateDrawingView;
    IBOutlet    NSMenu          *contextMenu_availableGraphsTable;
	
	
	
    
    // Palettes of inspectorParserView
    DMPaletteContainer			*containerParserView;
    IBOutlet    NSView			*paletteView_availableParsers;
    IBOutlet    NSView			*paletteView_parseDetails;
	
	
	// Sub-view items
	// Available Parsers
	IBOutlet	NSPopUpButton	*popUpButton_parserFilter;
	IBOutlet	HNDataTableView	*tableView_availableParsers;
	IBOutlet	NSButton		*button_editParsers;
	IBOutlet	NSMutableDictionary *dictionary_enableEditUI;
	IBOutlet	NSObjectController *controller_EditParserDetails;
    IBOutlet    NSMenu          *contextMenu_availableParsersTable;
	
	
	
	// Palettes of inspectorDGDataTable
	IBOutlet	NSView			*paletteView_dgDataTable;
	IBOutlet	DPDataTableView	*dataTableView;
    
    
    IBOutlet	NSTextView		*dataTextView;
    IBOutlet    NSScrollView    *scrollView_dataText;
    NoodleLineNumberView        *lineNumberView;
	
}

@property (unsafe_unretained) id delegate;
@property (unsafe_unretained) id datasource;


@property (retain) NSArray              *parseStrings;
@property (retain) NSArrayController	*parseTemplatesArrayController;
@property (retain) NSArrayController	*graphTemplatesArrayController;

@property (retain) NSTextField			*textField_dataItemDisplayName;
@property (retain) NSTableView			*tableView_availableGraphTemplates;
@property (retain) NSTableView			*tableView_availableParsers;

@property (retain) DGController			*dataGraphTemplateController;
@property (retain) DPDrawingView		*graphTemplateDrawingView;
@property (retain) DPDataTableView		*dataTableView;
@property (retain) NSTextView			*dataTextView;
@property (retain) NSScrollView         *scrollView_dataText;

-(IBAction)openGraphInDataGraph:(id)sender;


@end
