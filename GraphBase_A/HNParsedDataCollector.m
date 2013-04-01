//
//  ParsedDataCollector.m
//  GraphTest-A
//
//  Created by Owen Hildreth on 1/13/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "HNParsedDataCollector.h"

@implementation ParsedDataCollector

@synthesize parseDictionary;

@synthesize dataObject;
@synthesize parseTemplateObject;
@synthesize contentString;
@synthesize contentArray;

@synthesize dataArrays;
@synthesize fieldNames;
@synthesize experimentalDetails;
@synthesize dataString;
@synthesize scanner;
@synthesize currentLineNumber;





-(id) initWithDataObject:(Data *)dataObjectIn {
    self = [self init];
    #ifdef DEBUG
    NSLog(@"CALLED - ParsedDataCollector: initWithDataObject");
    #endif
    
    dataObject = dataObjectIn;
    parseTemplateObject = [dataObject valueForKey: @"parseTemplate"];
    
    currentLineNumber = 0;
    
    contentString   = [[NSString alloc] init];
	contentArray	= [[NSArray alloc] init];
    dataArrays      = [[NSMutableArray alloc] init];
    fieldNames      = [[NSArray alloc] init];
	
	parseDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"\t", @"Tab", @"\t", @"tab", nil];
    
    [self setBoolValuesForScanning];
    
    
    return self;
}






#pragma mark Parse Entire File
-(BOOL) parseEntireFile {
	#ifdef DEBUG
	NSLog(@"Called: ParsedDataCollector - parseEntireFile");
	#endif
	
	
	/*
    NSMutableDictionary *parsedFile = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
                                        experimentalDetails, "experimentalDetails",
                                        fieldNames, @"fieldNames", 
                                        dataArrays, @"dataArrays", nil];
	 */
	
	BOOL success = YES;
	
    if ([self loadFileIntoContentString] == NO) {
		#ifdef DEBUG
		NSLog(@"Failed to load file into contentString");
		#endif
		
		success = NO;
		return success;
	}
	
	if ([self parseContentStringIntoContentArray] == NO) {
		#ifdef DEBUG
		NSLog(@"Failed to parse contentString into contentArray");
		#endif
		success = NO;
		return success;
	}
	
    
    // Parse the Experimental Details Section
    if (hasExpDet == YES) {
        success = [self parseExperimentalDetailsSection];
    }
	
	// Parse the Header
	if (hasHeader == YES) {
		success = [self parseHeaderSection];
	}
	
	// Parse the Data
	if (hasData == YES) {
		success = [self parseDataSection];
	}
    
#ifdef DEBUG
    NSLog(@"success = %i", success);
	NSLog(@"experimentalDetails = %@", experimentalDetails);
	NSLog(@"fieldNames = %@", fieldNames);
	//NSLog(@"dataArrays = %@", dataArrays);
#endif
	
	return success;
}


#pragma mark Parse Settings
// This method loads the file from the dataObject into the contentString
-(BOOL) loadFileIntoContentString {
#ifdef DEBUG
	NSLog(@"Called: ParsedDataCollector - loadFileIntoContentString");
#endif
	BOOL success = YES;
	
	
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dataFilePath = dataObject.filePath;
    NSMutableDictionary *dataContentAttributes = [NSMutableDictionary dictionary];
    
    if ([fm fileExistsAtPath: dataFilePath]) {
        NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] 
													initWithPath:dataFilePath 
													documentAttributes: &dataContentAttributes];
		#ifdef DEBUG
        NSLog(@"dataContentAttributes Dictionary = %@", dataContentAttributes);
		#endif
		contentString = [contentAttributedString string];
    }
    else {
		success = NO;
		
		#ifdef DEBUG
        NSLog(@"Datafile does exist at path %@", dataFilePath);
		#endif
    }
    
    [contentString retain];
	
	
    // Check dataContent
    if (!contentString) {
		success = NO;
		
		#ifdef DEBUG
        NSLog(@"NO attributedDataContent");
		#endif
    }
    
#ifdef DEBUG
    NSLog(@"contentString = %@", contentString);
#endif

	return success;
}

// This method parsees the contentString into an array using \n as the parser
-(BOOL) parseContentStringIntoContentArray {
	#ifdef DEBUG
	NSLog(@"Called: ParsedDataCollector - parseContentStringIntoContentArray");
	#endif
	
	BOOL success = YES;
	
	contentArray = [contentString componentsSeparatedByString:@"\n"];
	
	if (!contentArray) {
		success = NO;
		
		#ifdef DEBUG
        NSLog(@"contentString was not parsed by newLine character");
		#endif
	}
    
#ifdef DEBUG
    NSLog(@"success = %i", success);
    //NSLog(@"contentArray = %@", contentArray);
#endif
	
	return success;
	
}


// This sets the BOOL values for whether or not to scan a section 
-(BOOL) setBoolValuesForScanning {
	#ifdef DEBUG
	NSLog(@"Called: ParsedDataCollector - setBoolValuesForScanning");
	#endif
	
	// Set values from 
    hasExpDet = [parseTemplateObject.yesNo_expDet boolValue];
    hasHeader = [parseTemplateObject.yesNo_header boolValue];
    hasData   = [parseTemplateObject.yesNo_data   boolValue];
    
#ifdef DEBUG
    NSLog(@"hasExpDet = %i, hasHeader = %i, hasData = %i", hasExpDet, hasHeader, hasData);
#endif
	
	return YES;
}


// This method translates the user inputed Parse Separator into a string;
-(NSString *) translateParseSeparator: (NSString *) userParseSeparatorIn {
	
	BOOL success = YES;
    NSString *outParseSeparator = [NSString stringWithString:userParseSeparatorIn];
    
    NSString *translatedParseSeparator = [parseDictionary objectForKey: userParseSeparatorIn];
    
    if (translatedParseSeparator) {
        outParseSeparator = translatedParseSeparator;
    }
	else {
		success = NO;
	}
	
	#ifdef DEBUG
	NSLog(@"userParseSeparatorIn = %@, outParseSeparator = %@", userParseSeparatorIn, outParseSeparator);
	#endif
	
    return outParseSeparator;
}



#pragma mark Parse Sections
-(BOOL) parseExperimentalDetailsSection {
	#ifdef DEBUG
	NSLog(@"Called: ParsedDataCollector - parseExperimentalDetailsSection");
	#endif
	
	BOOL success = YES;
	
	// String to collect Experimental Data
	NSString *collectedString = [NSString string];
	
    int startingLine	= [parseTemplateObject.lineStart_expDet intValue] - 1;
	int endingLine		= [parseTemplateObject.lineEnd_expDet intValue] - 1;
	
	// Collect lines of Experimental Details
	// Check starting and ending line numbers
	if (endingLine < startingLine) {
		#ifdef DEBUG
		NSLog(@"ERROR: endingLine < startingLine, set endingline = startingLine");
		#endif
		endingLine = startingLine;
	}
	
	// Make sure that the contentArray is larger than endingLine
	if ([contentArray count] < startingLine) {
		#ifdef DEBUG
		NSLog(@"ERROR: [contentArray count] < startingLine, set startingLine to [contentArray count]");
		startingLine = (int) [contentArray count] - 1;
		#endif
	}
	if ([contentArray count] < endingLine) {
		#ifdef DEBUG
		NSLog(@"ERROR: [contentArray count] < endingLine, set endingLine to [contentArray count]");
		#endif
		endingLine = (int) [contentArray count];
	}
	
	for (currentLineNumber = startingLine; currentLineNumber <= endingLine; ++currentLineNumber) {
		NSString *nextLine;
		if ([contentArray count] >= currentLineNumber) {
			nextLine = [contentArray objectAtIndex: currentLineNumber];
			nextLine = [nextLine stringByAppendingString:@"\n"];
		}
		else {
			nextLine = @"\n";
		}
		collectedString = [collectedString stringByAppendingString: nextLine];
	}
	
	experimentalDetails = [NSString stringWithString: collectedString];
	//[collectedString release];
	
	
#ifdef DEBUG
	NSLog(@"currentLineNumber = %i", currentLineNumber);
	NSLog(@"experimentalDetails = %@", experimentalDetails);
#endif
	
	
	return success;
}



-(BOOL)    parseHeaderSection {
	#ifdef DEBUG
	NSLog(@"Called: ParsedDataCollector - parseHeaderSection");
	#endif
	
	BOOL success = YES;
	
	NSArray *collectedHeaderNames;
	NSString *separator = [self translateParseSeparator: parseTemplateObject.seporatorFields_header];
	
	
	int startingLine = [parseTemplateObject.lineStart_header intValue] - 1;
	int endingLine	 = [parseTemplateObject.lineEnd_header   intValue] - 1;
	
	
	//Check the, current, starting, and ending lines against the size of the contentArray
	if (endingLine < startingLine) {
		#ifdef DEBUG
		NSLog(@"ERROR: endingLine < startingLine, set endingline = startingLine");
		#endif
		endingLine = startingLine;
	}
	
	// Make sure that the contentArray is larger than endingLine
	if ([contentArray count] < startingLine) {
		#ifdef DEBUG
		NSLog(@"ERROR: [contentArray count] < startingLine, set startingLine to [contentArray count]");
		startingLine = (int) [contentArray count];
		#endif
	}
	if ([contentArray count] < endingLine) {
		#ifdef DEBUG
		NSLog(@"ERROR: [contentArray count] < endingLine, set endingLine to [contentArray count]");
		#endif
		endingLine = (int) [contentArray count];
	}
	
	// Set currentLineNumber if needed
	if (currentLineNumber < startingLine) {
		currentLineNumber = startingLine;
		#ifdef DEBUG
		//NSLog(@"set currentLineNumber = startingLine = %i", currentLineNumber);
		#endif
	}
	
	// Assume that only ONE header line exists
	NSString *currentLine = [NSString string];
	currentLine = [contentArray objectAtIndex: currentLineNumber];
    // Remove any newLine characters
    currentLine = [currentLine stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	collectedHeaderNames = [currentLine componentsSeparatedByString: separator];
	
	fieldNames = [NSArray arrayWithArray: collectedHeaderNames];
	//[collectedHeaderNames release];
	
	
	// set currentLine to endingLine
	currentLineNumber = endingLine;
	
	return success;
}




-(BOOL)    parseDataSection {
	#ifdef DEBUG
	NSLog(@"Called: ParsedDataCollector - parseDataSection");
	#endif
	
	BOOL success = YES;
	
	NSMutableArray *collectedArrays = [[NSMutableArray alloc] init];
	NSString *separator = [self translateParseSeparator: parseTemplateObject.seporatorFields_data];
	
	int startingLine = [parseTemplateObject.lineStart_data intValue] - 1;
	//int endingLine	 = [parseTemplateObject.lineEnd_data   intValue];
	//int numberOfColumns = 0;
	
	
	//Check the, current, starting, and ending lines against the size of the contentArray
	
	// Make sure that the contentArray is larger than endingLine
	if ( (int)[contentArray count] < startingLine) {
		#ifdef DEBUG
		NSLog(@"ERROR: %i < %i, [contentArray count] < startingLine, set startingLine to [contentArray count]",(int) [contentArray count], startingLine);
		startingLine = (int) [contentArray count] - 1;
		#endif
	}
    
    
	
	// Set currentLineNumber if needed
	if (currentLineNumber < startingLine) {
		#ifdef DEBUG
		NSLog(@"set currentLineNumber = startingLine = %i", currentLineNumber);
		#endif
		currentLineNumber = startingLine;
	}
    

	
    // Initilize iteration variables
	NSString *currentLine = [NSString string];
	NSArray  *currentData = [NSArray array];
    
    
    
    // Get the first line and parse it into an array
    currentLine = [contentArray objectAtIndex: currentLineNumber];
    currentData = [currentLine componentsSeparatedByString: separator];
    
    // Initilize the collecteData array with the first line
    //Check the number of datacolumns to the collectedArrays
    // If collected arrays has never been filled then the count will be zero; add all arrays
    if ([collectedArrays count] == 0) {
        #ifdef DEBUG
        NSLog(@"Initilize collectedArrays: [collectedArrays count] == 0");
        //NSLog(@"currentLine = %@", currentLine);
        //NSLog(@"currentData = %@", currentData);
        #endif
        
        int currentColumn = 0;
        for (currentColumn = 0; currentColumn <= [currentData count] - 1; ++currentColumn) {
            NSMutableArray *newArray = [NSMutableArray arrayWithObject: [currentData objectAtIndex: currentColumn]];
            [collectedArrays addObject: newArray];
        }
        ++currentLineNumber;
        
        #ifdef DEBUG
        NSLog(@"[collectedArrays count] = %lu", [collectedArrays count]);
        #endif
    }
    else {
        #ifdef DEBUG
        NSLog(@"BAD: [collectedArrays count] != 0, should be 0");
        #endif
    }
    
    
    
	for (currentLineNumber = currentLineNumber; currentLineNumber <= [contentArray count] -1; ++currentLineNumber) {
        #ifdef DEBUG
		NSLog(@"set currentLineNumber = %i", currentLineNumber);
        #endif
		
		// Get the current line and parse it into an array
		currentLine = [contentArray objectAtIndex: currentLineNumber];
		currentData = [currentLine componentsSeparatedByString: separator];
        
        #ifdef DEBUG
        NSLog(@"currentLine = %@", currentLine);
        //NSLog(@"currentData = %@", currentData);
        #endif
		
		
		// If an new columns starts late, then need to add a new columns and fill the empty values with zero
		if ([currentData count] > [collectedArrays count]) {
			int currentColumn = (int) [collectedArrays count] - 1;
			int currentLength = (int) [[collectedArrays objectAtIndex: 0] count] - 1;
			
			for (currentColumn = (int) [collectedArrays count] - 1; currentColumn <= [currentData count] -1; ++currentColumn) {
				NSMutableArray *newArray = [NSMutableArray array];
				for (int i = 0; i <= currentLength; ++i) {
					[newArray addObject: [NSNumber numberWithDouble: 0.0]];
				}
				[collectedArrays addObject: newArray];
			}
		}
		
		
		// Parse the data from each line in the contentArray into the collectedArrays
        int collectedArraysCount = (int) [collectedArrays count];
        int currentDataCount     = (int) [currentData count];
        if (collectedArraysCount != currentDataCount) {
            #ifdef DEBUG
            NSLog(@"ERROR: currentLine = %i", currentLineNumber);
            NSLog(@"ERROR: collectedArraysCount != currentDataCount; %i != %i", collectedArraysCount, currentDataCount);
            #endif
        }

        int currentColumn;
        for (currentColumn = 0; currentColumn <= [currentData count] - 1; ++currentColumn) {

            [[collectedArrays objectAtIndex: currentColumn] addObject: [currentData objectAtIndex: currentColumn]];
        }
	}
	
	// Put collected arrays into dataArrays and return
	dataArrays = [NSMutableArray arrayWithArray: collectedArrays];
#ifdef DEBUG
    NSLog(@"FINISHED: parseDataSection with %i", success);
#endif
	return success;
}


// Deallocation
#pragma mark Deallocation
-(void) dealloc {
    
}

@end
