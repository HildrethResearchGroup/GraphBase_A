//
//  HNDataViewController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/24/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNDataViewController.h"
#import "HNDataTableView.h"

// Precompiled Headers
#import "PreCompiledHeaders.h"
#import "HNCoreDataHeaders.h"


// Protocols
#import "HNAppDelegateAsDataSource.h"


// Parsers
#import "ParsedDataCollector.h"


@implementation HNDataViewController

@synthesize delegate					 = _delegate;
@synthesize datasource					 = _datasource;
@synthesize dataListTableView			 = _dataListTableView;
@synthesize dataGraphView				 = _dataGraphView;
@synthesize dataItemsArrayController	 = _dataItemsArrayController;
@synthesize dataGraphController			 = _dataGraphController;
@synthesize treeNodeSourceOfDataItems	 = _treeNodeSourceOfDataItems;
@synthesize currentGraphTemplateFilePath = _currentGraphTemplateFilePath;


-(id) init {
	self = [super init];
	
	if (self) {
		parser = [[ParsedDataCollector alloc] init];
	}
	
	self.dataListTableView = [[HNDataTableView alloc] init];
    
    //self.currentGraphTemplateFilePath = @"InitialGraph";
    
	self.dataGraphController = [DGController createEmpty];
	
	
	return self;
}

-(void) awakeFromNib {
	
    [self.dataGraphController setDrawingView: self.dataGraphView];
	[self.dataGraphController setDelegate: self];
	
	
	// Register for Dragged Types
	NSArray *draggedTypes = @[ NSFilenamesPboardType ];
	[self.dataListTableView registerForDraggedTypes: draggedTypes];
	[self registerForNotifications];
	
	[self updateselectedCountTextField];
	
}

-(void) registerForNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	// Register for sourceList/outlineView selection changes
	[nc addObserver: self
		   selector: @selector(updateGraphDrawingView)
			   name: HNResetCropOnNewSelectionNotification
			 object: nil];
}


#pragma mark -
#pragma mark Updating Methods
-(void) updateAll {
	//dataItemsArrayController = [datasource dataItemsArrayControllerFromSource];
	[self updateDataListTableView];
	[self updateGraphDrawingView];
}

-(void) updateselectedCountTextField {
	// Update selectedCountTextField
	NSArray *selectedItems = [[self.datasource dataItemsArrayControllerFromSource] selectedObjects];
	
	NSUInteger totalNumberOfDataItems = [[[self.datasource dataItemsArrayControllerFromSource] arrangedObjects] count];
	NSUInteger numberOfSelectedItems = [selectedItems count];
	
	NSString *selectedCountString = [NSString stringWithFormat: @"%lu of %lu data files selected", numberOfSelectedItems, totalNumberOfDataItems];
	[selectedCountTextField setStringValue: selectedCountString];
}

-(void) updateWindowTitle {
    NSArray *selectedItems = [[self.datasource dataItemsArrayControllerFromSource] selectedObjects];
    NSUInteger numberOfSelectedItems = [selectedItems count];
    
    NSString *windowTitle = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleName"];
    
    if (windowTitle) {
        if (numberOfSelectedItems != 1) {
            [[[NSApplication sharedApplication] mainWindow] setTitle: windowTitle];
        }
        else {
            NSString *fileName = [[selectedItems firstObject] displayName];
            if (fileName) {
                //windowTitle = [windowTitle stringByAppendingFormat: @" - %@", fileName];
				windowTitle = fileName;
            }
            [[[NSApplication sharedApplication] mainWindow] setTitle: windowTitle];
        }
    }
    
    
    
}




-(void) updateDataListTableView {
	[self.dataListTableView reloadData];
	
	// tableView has changed.  Need to update the GraphDrawingView
	//[self updateGraphDrawingView];
}



-(void) updateGraphDrawingView {
	DLog(@"CALED - HNDataViewController: updateGraphDrawingViewWithDataItem");
	// Get selected dataItems
	NSArray *selectedDataItems = [[self.datasource dataItemsArrayControllerFromSource] selectedObjects];
	
    if ([selectedDataItems count] == 0) {
		// No Data Items selected
		// Draw empty graph
		[self displayEmptyGraph];
        return;
	}
    
	// Get top selected item
	if ( ![[selectedDataItems firstObject] isKindOfClass: [HNDataItem class]] ) {
		DLog(@"SelectedObject is NOT an HNDataItem; it is a %@", [[selectedDataItems firstObject] class]);
        [self displayEmptyGraph];
		return;
	}
	
	if ([selectedDataItems count] == 1) {
		HNDataItem *selectedDataItem = [selectedDataItems firstObject];
		[self updateGraphDrawingViewWithDataItem: selectedDataItem];
        return;
	}
	
}



-(void) newDataSelected: (HNDataItem *) dataItemIn {
    DLog(@"CALLED - HNDataViewController: newDataSelected");
    [self updateGraphDrawingViewWithDataItem: dataItemIn];
}


-(void) updateGraphDrawingViewWithDataItem: (HNDataItem *) dataItem {
	DLog(@"CALLED - HNDataViewController: updateGraphDrawingViewWithDataItem");
    BOOL parseDataItemNeeded_yesNO = YES;
    BOOL updateGraphNeeded_yesNO   = YES;
    
    NSFileManager *fm = [NSFileManager defaultManager];
	currentParseTemplate = [dataItem parseTemplate];
	currentGraphTemplate = [dataItem graphTemplate];
	
	
	// Check to see if dataItem has graph and parse templates.  If not, there there is no reason to parse the dataItem
		// What if file has been parsed/graphed before but the graph template and parse template have been removed?
		// Currently assume that the user does not want to graph data that does not have a graph or parse template
	if ( (currentParseTemplate == nil) || (currentGraphTemplate == nil) ) {
		return;
	}
    BOOL dataFileExists = [fm fileExistsAtPath: dataItem.filePath];
    BOOL graphTemplateFileExists = [fm fileExistsAtPath: dataItem.graphTemplate.filePath];
    
    if (!dataFileExists || !graphTemplateFileExists) {
        DLog(@"ERROR: updateGraphDrawingViewWithDataItem - Missing Data and/or Graph files");
        return;
    }
	
	
	
	// Check to see if data needs to be re-parsed
	// 1) See if saved applicationSupportDataFile exists
	NSString *applicationSupportDataFilePath = [dataItem localizedResourcePath];
	applicationSupportDataFilePath = [applicationSupportDataFilePath stringByAppendingPathComponent: [dataItem applicationSupportLocalDataFileName]];
    
    if ( ![fm fileExistsAtPath: applicationSupportDataFilePath] ) {
        // There is no saved Data, so the file needs to be parsed and graphed
        parseDataItemNeeded_yesNO = YES;
        updateGraphNeeded_yesNO   = YES;
        [self _updateGraphDrawingViewWithDataItem: dataItem
                              thatNeedsToBeParsed: parseDataItemNeeded_yesNO
                          andGraphTemplateUpdated: updateGraphNeeded_yesNO];
        return;
    }
    
    NSDate *fileLastModified            = [[fm attributesOfItemAtPath: dataItem.filePath error: nil] objectForKey: NSFileModificationDate];
    NSDate *graphTemplateLastModified   = [[fm attributesOfItemAtPath: dataItem.graphTemplate.filePath error: nil] objectForKey: NSFileModificationDate];
    NSDate *parseTemplateLastModified   = dataItem.parseTemplate.dateLastModified;
    NSDate *savedFileLastModified       = [[fm attributesOfItemAtPath: applicationSupportDataFilePath error: nil] objectForKey: NSFileModificationDate];
    
    
    
    if ( ([parseTemplateLastModified timeIntervalSinceDate: fileLastModified] < 0) || ([savedFileLastModified timeIntervalSinceDate: fileLastModified] < 0)  ) {
        parseDataItemNeeded_yesNO  = YES;
    }
    else {
        parseDataItemNeeded_yesNO  = NO;
    }
    
    if ([savedFileLastModified timeIntervalSinceDate: graphTemplateLastModified] < 0) {
        updateGraphNeeded_yesNO = YES;
    }
    else {
        updateGraphNeeded_yesNO = NO;
    }
    
    
    [self _updateGraphDrawingViewWithDataItem: dataItem
						 thatNeedsToBeParsed: parseDataItemNeeded_yesNO
					 andGraphTemplateUpdated: updateGraphNeeded_yesNO];
	
	
    return;
}



-(void) _updateGraphDrawingViewWithDataItem:(HNDataItem *)dataItem
					   thatNeedsToBeParsed: (BOOL) parseDataItemNeeded_yesNO
				   andGraphTemplateUpdated: (BOOL) updateGraphNeeded_yesNO {
	// Local Variables
	NSFileManager *fm = [NSFileManager defaultManager];
	// CHANGED
	//id dataArraySource;		// dataArraSource is either a: ParsedDataCollectoin or a .dgraph script
	NSArray *dataArrays;
	NSArray *fieldNames;
    NSString *applicationSupportLocalData = [dataItem applicationSupportLocalDataFileName];
    NSString *localizedResourcePath = [dataItem localizedResourcePath];
    applicationSupportLocalData = [localizedResourcePath stringByAppendingPathComponent: applicationSupportLocalData];
	
	
	// Double Check that applicationSupportLocalData exists.  If not, then set parsedDataItemNeeded and updateGraphNeeded to YES.
    if ( ![fm fileExistsAtPath: applicationSupportLocalData]) {
        parseDataItemNeeded_yesNO = YES;
        updateGraphNeeded_yesNO = YES;
    }
    
    /*
    // TEST
    DGController *localController = [DGController controllerWithContentsOfFile: dataItem.graphTemplate.filePath];
    NSArray *localizedDataArray = [localController dataColumns];
    
    for (DGDataColumn *nextColumn in localizedDataArray) {
        if ([nextColumn.type isEqualToString: @"Plot Action"]) {
            NSArray *entryNames = [nextColumn entryNames];
            DLog(@"Column Class = %@", [nextColumn class]);
            DLog(@"Entry Names = %@", entryNames);
            
            for (NSString *nextEntryName in entryNames) {
                NSArray *nextTolkenSet = [nextColumn getTokensForEntry: nextEntryName];
                
                //DLog(@"nextTolkenSet = %@", nextTolkenSet);
            }
            
        }
    }
     */
    
    
	// CASE: Nothing needs to be updated.  Use applicationSupportLocalData file, overwrite controller and redraw graph 
    if ( (parseDataItemNeeded_yesNO == NO) && (updateGraphNeeded_yesNO == NO) ) {
        
        DLog(@"Overwriting dataGraphController");
        
        
		[self.dataGraphController overwriteWithScriptFile: applicationSupportLocalData];
        [self.dataGraphController redrawNow];
        
        DLog(@"Finished overwriting dataGraphController");
		return;
    }
	
	
	// START: Data does not need to be reparsed
	if ( parseDataItemNeeded_yesNO == NO ) {
		// Previously parsed data stored in applicationSupportLocalData is still up-to-date.
		
		// Check if graph stored in applicationSupportLocalData is stil up-to-date
		if (updateGraphNeeded_yesNO == NO) {
			// CASE: Nothing needs to be updated.  Use applicationSupportLocalData file, overwrite controller and redraw graph
            
			[self.dataGraphController overwriteWithScriptFile: applicationSupportLocalData];
			[self.dataGraphController redrawNow];
			return;

		}
		else {
			DLog(@"Update Graph but not parser");
			// updateGraphNeeded_yesNO = YES
			// CASE: graph template has changed but data stays the same
			// 1) Pull data from old applicationSupportLocalData file
			// 2) Pull canvas and axis titles from old applicationSupportLocalData file
			// 3) Overwrite self.datagraphController with new dataItem.graphTemplate file
			// 4) Put old data into self.datagraphController
			// 5) Apply old canvas and axis titles
			
			
			
			// 1) Pull data from old applicationSupportLocalData file
			DGController *tempController = [DGController controllerWithContentsOfFile: applicationSupportLocalData];
			dataArrays = [tempController dataColumns];
            
            
            // NEW/TEST
                // Pull in only those data columns that are number columns
            int numberOfColumns = [tempController numberOfDataColumns];
            NSMutableDictionary *dataArraysDetails = [NSMutableDictionary dictionary];
            
            for (int i = 1; i < numberOfColumns - 1; ++i) {
                DGDataColumn *nextDataColumn = [tempController dataColumnAtIndex: i];
                
                if ([nextDataColumn isNumberColumn]) {
                    // nextDataColumn is a number column.  Add it and the index to the dictionary
                    NSString *key = [NSString stringWithFormat: @"%i", i];
                    [dataArraysDetails setObject: nextDataColumn forKey: key];               
                }
            }
			
            
			// 2) Pull canvas and axis titles from old applicationSupportLocalData file
			NSString *canvasTitle = [NSString stringWithFormat: @"%@ - %@", dataItem.treeNode.displayName, dataItem.displayName];
			
			// Get X axis titles and information
			NSMutableArray *xAxisArray = [NSMutableArray array];
			
			DLog(@"Number of X-axes = %i", [tempController howManyXAxes]);
			//for (int i = 0; i <= [tempController howManyXAxes]; ++i) {
			for (int i = 0; i < [tempController howManyXAxes]; ++i) {
				// TODO: Double check number of x-axis
				DGXAxisCommand *nextXAxis = [tempController xAxisNumber:i];
				[xAxisArray addObject: nextXAxis];
			}
			
			// Get Y axis titles and information
			NSMutableArray *yAxisArray = [NSMutableArray array];
			DLog(@"Number of y-axes = %i", [tempController howManyYAxes]);
			//for (int i = 0; i <= [tempController howManyYAxes]; ++i) {
			for (int i = 0; i < [tempController howManyYAxes]; ++i) {
				// TODO: Double check number of x-axis
				DGYAxisCommand *nextyAxis = [tempController yAxisNumber:i];
				[yAxisArray addObject: nextyAxis];
			}
            
			
			
			// 3) Overwrite self.datagraphController with new dataItem.graphTemplate file
			NSString *graphTemplateFilePath = dataItem.graphTemplate.filePath;
			BOOL success = NO;
			if ([fm fileExistsAtPath: graphTemplateFilePath]) {
                DGController *newDGController = [DGController controllerWithContentsOfFile: graphTemplateFilePath];
                NSDictionary *newGraphPropertyList = [newDGController propertyListForCommandsAndVariables];
                
                // CHANGED
				//success = [self.dataGraphController overwriteWithScriptFile: graphTemplateFilePath];
                success = [self.dataGraphController overwriteWithScriptFile: applicationSupportLocalData];
                
				if ( !success ) {
                    DLog(@"ERROR: could not overwrite dataGraphController with: %@", applicationSupportLocalData);
                    //DLog(@"ERROR: could not overwrite dataGraphController with: %@", graphTemplateFilePath);
                    return;
                }
                
                [self.dataGraphController restoreCommandsAndVariablesFromPropertyList: newGraphPropertyList];

			}
			else {
				DLog(@"ERROR: could not find %@, to overwrite dataGraphController", graphTemplateFilePath);
				return;
			}

			// 4) Put old data into self.datagraphController
			int count;
            
            // NEW/TEST
            for (NSString *nextIndexKey in dataArraysDetails) {
                DGDataColumn *nextReplacementColumn = [dataArraysDetails objectForKey: nextIndexKey];
                int nextIndex = [nextIndexKey intValue];
                
                DGDataColumn *nextColumnToRemove = [self.dataGraphController dataColumnAtIndex: nextIndex];
                [self.dataGraphController removeDataColumn: nextColumnToRemove];
                [self.dataGraphController addDataColumnByCopying: nextReplacementColumn];
                
                if (nextIndex <= [self.dataGraphController numberOfDataColumns]) {
                    [self.dataGraphController moveDataColumn: nextReplacementColumn toIndex: nextIndex];
                }
            
            }
            
            // OLD
            /*
            NSIndexSet *indexOfDataColumns = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [dataArrays count])];
            [self.dataGraphController removeDataColumnsAtIndexes: indexOfDataColumns];
            
            
			for (count = 0; count <= [dataArrays count] - 1; ++ count) {
                [self.dataGraphController addDataColumnByCopying: [dataArrays objectAtIndex: count]];
			}
            // Move Data Columns to front of the array
            for (count = 0; count <= [dataArrays count] - 1; ++ count) {
                [self.dataGraphController moveDataColumn: [dataArrays objectAtIndex: count] toIndex: count];
            }
             
             */
			// Set canvas title
			[[self.dataGraphController canvasSettings] setTitle: canvasTitle];
            
            // 5) Apply old canvas and axis titles
            if (canvasTitle) {
                DGCanvasCommand *canvasSettings = [self.dataGraphController canvasSettings];
                [canvasSettings setTitle: canvasTitle];
            }
            
            
            for (count = 0; (count < [self.dataGraphController howManyXAxes] ) && (count < [xAxisArray count]) ; ++count) {
                
            
            DGXAxisCommand *nextXAxis = [self.dataGraphController xAxisNumber: count];
            DGXAxisCommand *oldXAxis = [xAxisArray objectAtIndex: count];
            [nextXAxis  setAxisTitle: [oldXAxis axisTitle]];
            }

            // Finished Updating Graph
            [self.dataGraphController redrawNow];
			
            // Write out updated graph controller
			BOOL isDirectory;
			NSError *writeError;
			if (![fm fileExistsAtPath:dataItem.localizedResourcePath isDirectory: &isDirectory]) {
				[fm createDirectoryAtPath: dataItem.localizedResourcePath
			  withIntermediateDirectories:YES
							   attributes:nil
									error:&writeError];
			}
			if (![self.dataGraphController writeToPath: applicationSupportLocalData]) {
				DLog(@"ERROR: Failed to writeToPath");
			}
            return;
        }
	}
    // END: Data does not need to be reparsed
	
	
	// START: Data needs to be parsed
        // Use Graph Template from dataItem.graphTemplate.filePath
	if ( parseDataItemNeeded_yesNO == YES ) {
		DLog(@"File needs to be parsed");
		ParsedDataCollector *parsedData = [[ParsedDataCollector alloc] initWithDataObject: dataItem];
		NSString *dataFilePath = dataItem.filePath;
		
		//  1) Update Data Columns by parsing the data from the text file
		if ([fm fileExistsAtPath: dataFilePath]) {
			BOOL successfulParse = [parsedData parseEntireFile];
			
			if (!successfulParse) {
				// Could not parse data.  Cannot update graph
				return;
			}
			else {
				// CHANGED
				//dataArraySource = parsedData;
				//parseDataItemNeeded_yesNO = NO;
				
				fieldNames = [parsedData fieldNames];
				dataArrays = [parsedData dataArrays];
				
				
				// 2) Update DGController with new graph template
				NSString *graphTemplatePath = dataItem.graphTemplate.filePath;
				BOOL updateGraphSuccess = NO;
				if ([fm fileExistsAtPath: graphTemplatePath]) {
					// UPdate Graph Controller
					updateGraphSuccess = [self.dataGraphController overwriteWithScriptFile: graphTemplatePath];
				}
				
                
				if (updateGraphSuccess == YES) {
					// Apply Data Arrays to dataGraphControllers
					NSUInteger numberOfControllerDataColumns = [self.dataGraphController numberOfDataColumns];
					NSUInteger numberOfNewDataColumns = [dataArrays count];
					int i;
					
                   
					// Replace data for existing data columns
                    // CHANGED/TEST
					//for (i = 0; i < numberOfNewDataColumns && i < numberOfControllerDataColumns; ++i) {
                    for (i = 0; i < numberOfNewDataColumns && i < (numberOfControllerDataColumns - 1); ++i) {
						DGDataColumn *nextColumn = [self.dataGraphController dataColumnAtIndex: i+1];
						if (nextColumn) {
							[nextColumn emptyTheColumn];
							[nextColumn setDataFromArray: [dataArrays objectAtIndex: i]];
						}
					}
					
					// Add new data columns if necessary
					if (i < numberOfNewDataColumns) {
						for (; i < numberOfNewDataColumns; ++i) {
							DGDataColumn *newDataColumn = [[DGDataColumn alloc] init];
							[newDataColumn setDataFromArray: [dataArrays objectAtIndex: i]];
                            if ([newDataColumn numberOfRows] > 0) {
                                [self.dataGraphController addDataColumnByCopying: newDataColumn];
                            }
							DLog(@"Setting newDataColumn to nil");
							newDataColumn = nil;
						}
					}
					
					// Update Canvas title
					NSString *canvasTitle = [NSString stringWithFormat: @"%@ - %@", dataItem.treeNode.displayName, dataItem.displayName];
					DGCanvasCommand *canvasCommand = [self.dataGraphController canvasSettings];
					[canvasCommand setTitle: canvasTitle];
					
					
					// Set Axis titles from header fields if they exis
					NSUInteger numberOfHeaderFields = [fieldNames count];

					if (numberOfHeaderFields > 0) {
						
						NSUInteger numberOfXAxis = [self.dataGraphController howManyXAxes];
						NSUInteger numberOfYAxis = [self.dataGraphController howManyYAxes];

						
						
						if (numberOfHeaderFields >= 1) {
							NSString *xAxis = [fieldNames objectAtIndex: 0];
							DGXAxisCommand *rootXAxis = [self.dataGraphController xAxisNumber: 0];
							[rootXAxis setAxisTitle: xAxis];
						}
						
						if (numberOfHeaderFields >= 2) {
							NSString *yAxis = [fieldNames objectAtIndex: 1];
							DGYAxisCommand *rootYAxis = [self.dataGraphController yAxisNumber: 0];
							[rootYAxis setAxisTitle: yAxis];
						}
						
						
						if (numberOfXAxis >= 2) {
							for (int j = 2;  j < numberOfXAxis; ++j) {
								// Assume x-axis are the odd field headers
								DGXAxisCommand *nextXAxis = [self.dataGraphController xAxisNumber: j];
								int headerIndex = 2*(j-1) + 1;
								if (numberOfHeaderFields >= headerIndex ) {
									[nextXAxis setAxisTitle: [fieldNames objectAtIndex: j]];
								}
							}
						}
						
						if (numberOfYAxis >= 2) {
							for (int j = 2;  j < numberOfYAxis; ++j) {
								// Assume x-axis are the odd field headers
								DGXAxisCommand *nextYAxis = [self.dataGraphController xAxisNumber: j];
								int headerIndex = 2*j + 1;
								if (numberOfHeaderFields >= headerIndex ) {
									[nextYAxis setAxisTitle: [fieldNames objectAtIndex: j]];
								}
							}
						}
					}
                    [self.dataGraphController redrawNow];
					
					// Write out updated graph controller
					BOOL isDirectory;
					NSError *writeError;
					if (![fm fileExistsAtPath:dataItem.localizedResourcePath isDirectory: &isDirectory]) {
						[fm createDirectoryAtPath: dataItem.localizedResourcePath
					  withIntermediateDirectories:YES
									   attributes:nil
											error:&writeError];
					}
                    if (![self.dataGraphController writeToPath: applicationSupportLocalData]) {
                        DLog(@"ERROR: Failed to writeToPath");
                    }
				}
				else {
					NSBeep();
					DLog(@"ERROR: Trying to update graph with missing template");					
				}
				// CHANGED
				//[self updateGraphWithParsedDataCollector: parsedData];
				// Graph has been updated.  
				return;
			}
		}
		// Finished updating graph (if possible) exit.
		DLog(@"Exited updateGraphDrawingViewWithDataItem without updating");
		return;
	}
    // END: Data needs to be parsed
}



-(BOOL) dataFileExists:(HNDataItem *) dataItemIn {
	BOOL dataFileExists = YES;
	// Check to see if original data file still exists
	NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dataFilePath = dataItemIn.filePath;
	if ( ![fm fileExistsAtPath: dataFilePath]) {
		
		// Check user defaults see if Missing File alert should be shown
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL showMissingFileAlert = [[defaults valueForKey: HNShowMissingFileAlertKey] boolValue];
		if (showMissingFileAlert) {
			
			NSString *message = NSLocalizedString(@"Original data file is missing", @"QShow missing data file message question");
			NSString *info = NSLocalizedString(@"Always show this error?", @"Show missing data file  message info");
			NSString *dismissButton = NSLocalizedString(@"Dismiss", @"Dismiss button title");
			
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setMessageText:message];
			[alert setInformativeText:info];
			[alert addButtonWithTitle:dismissButton];
			//[alert addButtonWithTitle:dontShowErrorButton];
			[alert setAlertStyle: NSInformationalAlertStyle];
			[alert setShowsSuppressionButton: YES];
			
			[alert beginSheetModalForWindow: [[NSApplication sharedApplication] keyWindow]
							  modalDelegate: self
							 didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
								contextInfo:nil];
			
			//[alert runModal];
			// Check suppressButton state
			/*
			 BOOL alertSuppressButtonState = [[alert suppressionButton] state];
			 if (alertSuppressButtonState) {
			 showMissingFileAlert = NO;
			 [defaults setObject:[NSNumber numberWithBool: showMissingFileAlert] forKey: HNShowMissingFileAlertKey];
			 }
			 */
			
		}
		
		dataFileExists = NO;
	}
	
	return dataFileExists;
}


-(void) displayEmptyGraph {
	[label_graphWarning setStringValue: @"No Data Selected"];
	[label_graphWarning sizeToFit];
	[label_graphWarning setHidden: NO];
	
	//self.currentGraphTemplateFilePath = [[NSBundle mainBundle] pathForResource: @"EmptyGraph" ofType:@"dgraph"];
	[self.dataGraphController overwriteWithScriptFileInBundle: @"EmptyGraph"];
	[self.dataGraphController redrawNow];
}


-(void) displayMultipleGraphs {
	[label_graphWarning setStringValue: @"Multiple Data Selected"];
	[label_graphWarning sizeToFit];
	[label_graphWarning setHidden: NO];
	
	//self.currentGraphTemplateFilePath = [[NSBundle mainBundle] pathForResource: @"EmpthGraph" ofType:@"dgraph"];
	[self.dataGraphController overwriteWithScriptFileInBundle: @"EmptyGraph"];
	[self.dataGraphController redrawNow];
}



- (void)alertDidEnd:(NSAlert *)alert
		 returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo {
	
    // Check suppressButton state
		// if [suppressButton state] == YES, then record user preference
	BOOL alertSuppressButtonState = [[alert suppressionButton] state];
	if (alertSuppressButtonState) {
		BOOL showMissingFileAlert = NO;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[NSNumber numberWithBool: showMissingFileAlert] forKey: HNShowMissingFileAlertKey];
	}
	
}


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
    
    if ((int) [sender tag] == 1) {
        NSArrayController *fileSource = [self.datasource dataItemsArrayControllerFromSource];
        objectsArray = [fileSource selectedObjects];
    }
    else {
        DLog(@"[sender tag] != 1");
        DLog(@"Sender = %@", sender);
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
        
        /*
        if (nextFilePath) {
            [workSpace selectFile:nextFilePath inFileViewerRootedAtPath:nil];
        }
         */
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
    
    NSString *notificationType = hnOpenInDataGraphNotification;
    NSDictionary *userInfo = @{HNExportItemsArrayKey : arrayOfGraphTemplatesToOpen};
    
    [nc postNotificationName: notificationType
                      object: self
                    userInfo: userInfo];
    
    
    
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


-(IBAction) exportGraphTemplateNotification:(id) sender {
    
}

-(IBAction) exportParseTemplateNotification:(id) sender {
    
    NSArray *selectedParseTemplates = [[self.datasource allParserListArrayControllerFromSource] selectedObjects];
    
    
    NSDictionary *userInfo = @{HNExportItemsUsingKey : HNExportItemsUsingSavePanel, HNExportItemsArrayKey : selectedParseTemplates};
    
    [self postNotificationOfType: HNExportParseTemplateNotification
                     withDetails: userInfo];
}



@end







#pragma mark - TableView Delegate

@implementation HNDataViewController (NSTableViewDelegate)
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	DLog(@"CALLED - HNDataViewController: tableViewSelectionDidChange");
	
	if ([aNotification object] == self.dataListTableView) {
		
		NSArray *selectedItems = [[self.datasource dataItemsArrayControllerFromSource] selectedObjects];
		
        [self updateselectedCountTextField];
        [self updateWindowTitle];
        
		
		NSInteger numberOfItems = [selectedItems count];
        
		if (numberOfItems == 0) {
			[self displayEmptyGraph];
		}
		else if ( numberOfItems > 1) {
			[self displayMultipleGraphs];
			NSMutableSet *selectedGraphTemplates = [NSMutableSet set];
			NSMutableSet *selectedParseTemplates = [NSMutableSet set];
			
			
			for (HNDataItem *nextDataItem in selectedItems) {
				[selectedGraphTemplates addObject: nextDataItem.graphTemplate];
				[selectedParseTemplates addObject: nextDataItem.parseTemplate];
			}
		}
		else {
			HNDataItem *selectedDataItem = [selectedItems firstObject];
			
			if (selectedDataItem) {
				DLog(@"selectedDataItem = %@", selectedDataItem.displayName);
				[label_graphWarning setHidden: YES];
				[self newDataSelected: selectedDataItem];
				
				// Update selection of graphTemplates and parseTemplates to match that of selected HNDataItem
				HNGraphTemplate *selectedGraphTemplate = selectedDataItem.graphTemplate;
				HNParseTemplate *selectedParseTemplate = selectedDataItem.parseTemplate;
				
				NSArrayController *localGraphController = [self.datasource allGraphTemplateListArrayControllerFromSource];
				NSArrayController *localParseController = [self.datasource allParserListArrayControllerFromSource];
				
                if (selectedGraphTemplate != nil) {
                    [localGraphController setSelectedObjects: [NSArray arrayWithObject: selectedGraphTemplate]];
                }
                if (selectedParseTemplate != nil) {
                    [localParseController setSelectedObjects: [NSArray arrayWithObject: selectedParseTemplate]];
                }
			}
		}
	}
}


-(BOOL) tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
	return NO;
}


// END - NSTableViewDelegate
@end


#pragma mark -
#pragma mark TableView DataSource
@implementation HNDataViewController (NSTableViewDataSource)


- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
	DLog(@"CALLED - HNDataViewController: tableView: selectionIndexesForProposedSelection: %@", proposedSelectionIndexes);
    // We don't want to change the selection if the user clicked in the fill color area
	
	NSInteger row = [tableView clickedRow];
    if (row != -1 && ![self tableView:tableView isGroupRow:row]) {
		//DLog(@"column at index 0 = %@", [[tableView tableColumns] objectAtIndex: 0]);
		//DLog(@"cell = %@", [tableView viewAtColumn: 0 row: 1 makeIfNecessary: YES]);
		
        NSView *cellView = [tableView viewAtColumn:0 row:row makeIfNecessary: YES];
		//NSCell *cellView = [tableView preparedCellAtColumn: 0 row: row];
        if (cellView) {
			DLog(@"cellView");
            // Use hit testing to see if is a color view; if so, don't let it change the selection
            NSPoint windowPoint = [[NSApp currentEvent] locationInWindow];
            NSPoint point = [cellView.superview convertPoint:windowPoint fromView:nil];
            NSView *view = [cellView hitTest:point];
            if ([view isKindOfClass:[NSTableCellView class]]) {
                // Don't allow the selection change
                
				// CHANGED
				return [tableView selectedRowIndexes];
				//return proposedSelectionIndexes;
				
            }
			//return [tableView selectedRowIndexes];
        }
		else {
			DLog(@"NO cellView");
		}
    }
	return proposedSelectionIndexes;

}


- (NSDragOperation)tableView:(NSTableView *)aTableView
				validateDrop:(id < NSDraggingInfo >)info
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)operation {
	DLog(@"CALLED - HNDataViewController: tableView: validateDrop");
	
	
	/*
	if (row > [[[self.datasource dataItemsArrayControllerFromSource] arrangedObjects] count]) {
		return NSDragOperationNone;
	}
	 */
	//DLog(@"%@", [[info draggingPasteboard] types]);
	
	NSArray *pasteBoardTypes = [[info draggingPasteboard] types];
	
	if ([pasteBoardTypes containsObject: NSFilenamesPboardType]) {
		[aTableView setDropRow: row dropOperation: NSTableViewDropAbove];
		DLog(@"return NSDragOperationLink");
		return NSDragOperationLink;
	}
	
	else if ([info draggingSource] == nil) {
		DLog(@"[info dragginSource] == nil");
		return NSDragOperationNone;
	}
	
	else if ([info draggingSource] == aTableView ) {
		DLog(@"[info dragginSource] == aTableView");
		return NSDragOperationNone;
	}
	else {
		[aTableView setDropRow: row dropOperation: NSTableViewDropAbove];
		return NSDragOperationLink;
	}
	
}

-(BOOL) tableView:(NSTableView *)tableView
	   acceptDrop:(id<NSDraggingInfo>)info
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)dropOperation {
    
	NSPasteboard *pasteBoard = [info draggingPasteboard];
	//DLog(@"pasteBoard types = %@", [pasteBoard dataForType: NSFilenamesPboardType]);
	
	NSArray *pasteBoardTypes = [pasteBoard types];
	
	if ( [pasteBoardTypes containsObject: NSFilenamesPboardType] ) {
		NSArray *files = [pasteBoard propertyListForType: NSFilenamesPboardType];
		
		// Check files for appropriate type
		NSMutableSet *cleanedFiles = [NSMutableSet set];
        
            // Get Data File Types/Extensions from User Defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *dataFileTypeExtensions = [defaults objectForKey: HNExtensionsForDataFileTypesKey];
        
        // CHANGED
		//NSArray *fileExtensions = @[ @"txt", @"dat", @"text"];
		for (NSString *nextFilePath in files) {
			NSString *nextExtension = [nextFilePath pathExtension];
			
			for (NSString *nextExtentionToCheck in dataFileTypeExtensions) {
				if ([nextExtension isEqualToString: nextExtentionToCheck]) {
					[cleanedFiles addObject: nextFilePath];
				}
			}
		}
		
		if ([[cleanedFiles allObjects] count] > 0) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			NSString *notificationType = HNAddDataFilesNotification;
			NSDictionary *userInfo = @{ HNaddFilesFrom : HNAddFilePathsFromPasteBoard, HNArrayOfDataFilePathsToAddKey : cleanedFiles };
			
			[nc postNotificationName: notificationType
							  object: self
							userInfo: userInfo];
			return YES;
			
		}
		else {
			return NO;
		}
	}
	else {
		return NO;
	}

	return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)
rowIndexes toPasteboard:(NSPasteboard *)pboard {
	DLog(@"CALLED - HNDataViewController: writeRowsWithIndexes");
	
	// Get array of HNDataItems
	NSArrayController *localDataItemController = [self.datasource dataItemsArrayControllerFromSource];
	NSArray *indexedObjects = [[localDataItemController arrangedObjects] objectsAtIndexes: rowIndexes];
	NSMutableArray *URIOfIndexedObjects = [NSMutableArray arrayWithCapacity: [indexedObjects count]];
	
	if (indexedObjects == nil) {
		DLog(@"No indexedObjects");
		return NO;
	}
	
	for (HNDataItem *nextDataItem in indexedObjects) {
		[URIOfIndexedObjects addObject: [[nextDataItem objectID] URIRepresentation]];
	}
	
	
	
	// Declare P-board types
	// TODO: add drag/drop files/images 
	NSArray *pboardTypes = @[HNDataItemsPasteBoardType];
	[pboard declareTypes: pboardTypes owner: self];
	
	
	//NSDictionary *pasteBoardDictionary = @{HNDataItemsArrayKey : indexedObjects};
	//[pasteBoard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:HNNodeIndexPathPasteBoardType];
	
	[pboard setData: [NSArchiver archivedDataWithRootObject: URIOfIndexedObjects] forType:HNDataItemsArrayKey];
	DLog(@"Writing %lu objects to pasteboard", [indexedObjects count]);
	
	return YES;
}


@end



