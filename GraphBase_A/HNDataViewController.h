//
//  HNDataViewController.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/24/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DataGraph/DataGraph.h>
#import "HNAppDelegateAsDataSource.h"
@class HNSourceViewController;
@class ParsedDataCollector;


@class HNDataItem;
@class HNParseTemplate;
@class HNGraphTemplate;
@class HNDataTableView;




@interface HNDataViewController : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
	
    
    IBOutlet    id  __unsafe_unretained datasource;
    IBOutlet    id  __unsafe_unretained delegate;
		
	// UI
	IBOutlet HNDataTableView		*dataListTableView;
	IBOutlet DPDrawingView			*dataGraphView;
	IBOutlet NSTextField			*label_graphWarning;
    
    IBOutlet NSTextField            *selectedCountTextField;
	
	
	// Controllers
	DGController			*dataGraphController;

	
	// HNDataItems and HNTreeNode sources for dataItems
	NSArray			*treeNodeSourceOfDataItems;
	
	
	
	// Data Parser and Graph Templates
	ParsedDataCollector *parser;
	HNParseTemplate *currentParseTemplate;
	HNGraphTemplate *currentGraphTemplate;
	NSString *currentGraphTemplateFilePath;
	
}


@property (unsafe_unretained) IBOutlet id delegate;
@property (unsafe_unretained) IBOutlet id datasource;

@property (retain, strong, nonatomic) HNDataTableView		*dataListTableView;

@property (retain, nonatomic) NSArrayController *dataItemsArrayController;
@property (retain, nonatomic) DGController		*dataGraphController;
@property (retain, nonatomic) DPDrawingView		*dataGraphView;

@property (retain, nonatomic) NSArray			*treeNodeSourceOfDataItems;
@property (retain, nonatomic) NSMutableArray	*currentDataItems;
@property (retain, nonatomic) NSString			*currentGraphTemplateFilePath;






#pragma mark -
#pragma mark Update Arrays
-(void) updateAll;
-(void) updateDataListTableView;

#pragma mark - 
#pragma mark Update 
-(void) updateGraphDrawingView;
-(void) updateGraphDrawingViewWithDataItem: (HNDataItem *) dataItem;
//-(void) _updateGraphDrawingViewWithDataItem:(HNDataItem *)dataItem thatNeedsToBeParsed: (BOOL) parseDataItemNeeded_yesNO andGraphTemplateUpdated: (BOOL) updateGraphNeeded_yesNO;


-(void) displayEmptyGraph;
-(void) displayMultipleGraphs;



@end
