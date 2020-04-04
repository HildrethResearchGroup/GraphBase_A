//
//  ParsedDataCollector.m
//  GraphTest-A
//
//  Created by Owen Hildreth on 1/13/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "HNParsedDataCollector.h"
#import "HNDataItem.h"
#import "HNParseTemplate.h"
#import "HNUserDefaultStrings.h"

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





-(id) initWithDataObject:(HNDataItem *)dataObjectIn {
    self = [self init];
    //DLog(@"CALLED - ParsedDataCollector: initWithDataObject");

    
	
	
    self.dataObject = dataObjectIn;
    self.parseTemplateObject = [dataObject valueForKey: @"parseTemplate"];
    
    self.currentLineNumber = 0;
    
    self.contentString   = [[NSString alloc] init];
	self.contentArray	 = [[NSArray alloc] init];
    self.dataArrays      = [[NSMutableArray alloc] init];
    self.fieldNames      = [[NSArray alloc] init];
	
	self.parseDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"\t", @"Tab", @"\t", @"tab", @" ", @"Space", @" " , @"space", @" ", @" ", nil];
    
    [self setBoolValuesForScanning];
    
    
    return self;
}






-(BOOL) parseEntireFile {	
	BOOL success = YES;
	
    if ([self loadFileIntoContentString] == NO) {
		DLog(@"Failed to load file into contentString");

		
		success = NO;
		return success;
	}
	
	
	if ([self parseContentStringIntoContentArray] == NO) {
		DLog(@"Failed to parse contentString into contentArray");

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
    

    DLog(@"success = %i", success);
	DLog(@"experimentalDetails = %@", experimentalDetails);
	DLog(@"fieldNames = %@", fieldNames);
	DLog(@"[dataArrays count] = %lu", [dataArrays count]);

	
	return success;
}


#pragma mark Parse Settings
// This method loads the file from the dataObject into the contentString
-(BOOL) loadFileIntoContentString {
	//DLog(@"Called: ParsedDataCollector - loadFileIntoContentString");

	BOOL success = YES;
	
	
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dataFilePath = self.dataObject.filePath;
    NSMutableDictionary *dataContentAttributes = [NSMutableDictionary dictionary];
    
    if ([fm fileExistsAtPath: dataFilePath]) {
        NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc]
															  initWithPath:dataFilePath
															  documentAttributes: &dataContentAttributes];
        
        
        
        //DLog(@"dataContentAttributes Dictionary = %@", dataContentAttributes);
				
		if (contentAttributedString) {
			self.contentString = [contentAttributedString mutableString];
		}
		else {
			DLog(@"ERROR: no contentAttributedString");
		}
    }
    else {
		success = NO;
		
        //DLog(@"Datafile does NOT exist at path %@", dataFilePath);
    }
    
	
	
    // Check dataContent
    if (!self.contentString) {
		success = NO;
		
        DLog(@"NO attributedDataContent");

    }

    //DLog(@"contentString = %@", self.contentString);

	
	return success;
}

// This method parsees the contentString into an array using \n as the parser
-(BOOL) parseContentStringIntoContentArray {
	//DLog(@"Called: ParsedDataCollector - parseContentStringIntoContentArray")
	
	BOOL success = YES;
	
	self.contentArray = [self.contentString componentsSeparatedByString:@"\n"];
	
	if (!self.contentArray) {
		success = NO;
        DLog(@"contentString was not parsed by newLine character");
	}
    

    //DLog(@"success = %i", success);
    //DLog(@"contentArray = %@", contentArray);

	
	return success;
	
}


// This sets the BOOL values for whether or not to scan a section
-(BOOL) setBoolValuesForScanning {
	//DLog(@"Called: ParsedDataCollector - setBoolValuesForScanning");

	
	// Set values from
    hasExpDet = [self.parseTemplateObject.yesNo_hasExpDet boolValue];
    hasHeader = [self.parseTemplateObject.yesNo_hasHeader boolValue];
    hasData   = [self.parseTemplateObject.yesNo_hasData   boolValue];
    
    //DLog(@"hasExpDet = %i, hasHeader = %i, hasData = %i", hasExpDet, hasHeader, hasData);
	
	
	return YES;
}


// This method translates the user inputed Parse Separator into a string;
-(NSString *) translateParseSeparator: (NSString *) userParseSeparatorIn {
	//DLog(@"Called: ParsedDataCollector - translateParseSeparator");
    
    if (!userParseSeparatorIn) {
        return @"\t";
    }
	
    NSString *outParseSeparator;
    
    // Get translatedParseSeparator
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *availableParseSeparators = [defaults objectForKey: hnUDParseSeparatorDictionaryKey];
    NSString *translatedParseSeparator = [availableParseSeparators objectForKey: userParseSeparatorIn];
    
    // CHANGED
    //NSString *translatedParseSeparator = [self.parseDictionary objectForKey: userParseSeparatorIn];
	
	    
    if (translatedParseSeparator) {
        outParseSeparator = translatedParseSeparator;
    }
	else {
		outParseSeparator = @"\t";
		DLog(@"No translatedParseSeparator");
		return @"\t";
	}

	//DLog(@"userParseSeparatorIn = %@, outParseSeparator = %@", userParseSeparatorIn, outParseSeparator);

	
    return outParseSeparator;
}



#pragma mark Parse Sections
-(BOOL) parseExperimentalDetailsSection {
	//DLog(@"Called: ParsedDataCollector - parseExperimentalDetailsSection");

	
	BOOL success = YES;
	
	// String to collect Experimental Data
	NSString *collectedString = [NSString string];
	
    int startingLine	= [self.parseTemplateObject.lineStart_expDet intValue] - 1;
	int endingLine		= [self.parseTemplateObject.lineEnd_expDet intValue] - 1;
	
	// Collect lines of Experimental Details
	// Check starting and ending line numbers
	if (endingLine < startingLine) {
		//DLog(@"ERROR: endingLine < startingLine, set endingline = startingLine");

		endingLine = startingLine;
	}
	
	// Make sure that the contentArray is larger than endingLine
	if ([self.contentArray count] < startingLine) {
		//DLog(@"ERROR: [contentArray count] < startingLine, set startingLine to [contentArray count]");
		startingLine = (int) [self.contentArray count] - 1;
	}
	if ([self.contentArray count] < endingLine) {
		DLog(@"ERROR: [contentArray count] < endingLine, set endingLine to [contentArray count]");
		endingLine = (int) [self.contentArray count];
	}
	
	for (self.currentLineNumber = startingLine; self.currentLineNumber <= endingLine; ++self.currentLineNumber) {
		NSString *nextLine;
		if ([self.contentArray count] >= currentLineNumber) {
			nextLine = [self.contentArray objectAtIndex: currentLineNumber];
			nextLine = [nextLine stringByAppendingString:@"\n"];
		}
		else {
			nextLine = @"\n";
		}
		collectedString = [collectedString stringByAppendingString: nextLine];
	}
	
	experimentalDetails = [NSString stringWithString: collectedString];
	if (experimentalDetails) {
		[dataObject setExperimentalDetailsFromHeader: experimentalDetails];
	}
	
	//DLog(@"currentLineNumber = %i", currentLineNumber);
	///DLog(@"experimentalDetails = %@", experimentalDetails);

	return success;
}



-(BOOL)    parseHeaderSection {
	//DLog(@"Called: ParsedDataCollector - parseHeaderSection");

	
	BOOL success = YES;
	
	NSArray *collectedHeaderNames;
	NSString *separator = [self translateParseSeparator: self.parseTemplateObject.separator_headerFields];
	if (!separator) {
		success = NO;
		DLog(@"NO parseTemplate.separator");
		return success;
	}
	
	int startingLine = [self.parseTemplateObject.lineStart_header intValue] - 1;
	int endingLine	 = [self.parseTemplateObject.lineEnd_header   intValue] - 1;
	
	//DLog(@"startingLing = %i", startingLine);
	
	
	//Check the, current, starting, and ending lines against the size of the contentArray
	if (endingLine < startingLine) {
		DLog(@"ERROR: endingLine < startingLine, set endingline = startingLine");
		endingLine = startingLine;
	}
	
	// Make sure that the contentArray is larger than endingLine
	if ([self.contentArray count] < startingLine) {
		DLog(@"ERROR: [contentArray count] < startingLine, set startingLine to [contentArray count]");
		startingLine = (int) [self.contentArray count];
	}
	if ([self.contentArray count] < endingLine) {
		DLog(@"ERROR: [contentArray count] < endingLine, set endingLine to [contentArray count]");

		endingLine = (int) [contentArray count];
	}
	
	// Set currentLineNumber if needed
	if (currentLineNumber < startingLine) {
		currentLineNumber = startingLine;
		//DLog(@"set currentLineNumber = startingLine = %i", currentLineNumber);

	}
	
	// Assume that only ONE header line exists
	NSString *currentLine = [NSString string];
	currentLine = [self.contentArray objectAtIndex: currentLineNumber];
    // Remove any newLine characters
    currentLine = [currentLine stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	collectedHeaderNames = [currentLine componentsSeparatedByString: separator];
	//DLog(@"CollectedHeaderNames = %@", collectedHeaderNames);
	
	fieldNames = [NSArray arrayWithArray: collectedHeaderNames];
	//[collectedHeaderNames release];
	
	
	// set currentLine to endingLine
	currentLineNumber = endingLine;
	
	//DLog(@"FINISHED");
	return success;
}




-(BOOL)    parseDataSection {
	//DLog(@"Called: ParsedDataCollector - parseDataSection");

	
	BOOL success = YES;
	
	NSMutableArray *collectedArrays = [[NSMutableArray alloc] init];
	NSString *separator = [self translateParseSeparator: self.parseTemplateObject.separator_dataFields];
	if (!separator) {
		success = NO;
		//DLog(@"NO parseTemplate.separator");
		return success;
	}
	
	int startingLine = [self.parseTemplateObject.lineStart_data intValue] - 1;
	//int endingLine	 = [parseTemplateObject.lineEnd_data   intValue];
	//int numberOfColumns = 0;
	
	
	//Check the, current, starting, and ending lines against the size of the contentArray
	
	// Make sure that the contentArray is larger than endingLine
	if ( (int)[self.contentArray count] < startingLine) {
		DLog(@"ERROR: %i < %i, [contentArray count] < startingLine, set startingLine to [contentArray count]",(int) [self.contentArray count], startingLine);
		startingLine = (int) [self.contentArray count] - 1;

	}
    
    
	
	// Set currentLineNumber if needed
	if (currentLineNumber < startingLine) {
		//DLog(@"set currentLineNumber = startingLine = %i", currentLineNumber);
		currentLineNumber = startingLine;
	}
    
	
	
    // Initilize iteration variables
	NSString *currentLine;
	NSArray  *currentData = [NSArray array];
    
    
    
    // Get the first line and parse it into an array
    currentLine = [self.contentArray objectAtIndex: currentLineNumber];
    currentData = [currentLine componentsSeparatedByString: separator];
    
    // Initilize the collecteData array with the first line
    //Check the number of datacolumns to the collectedArrays
    // If collected arrays has never been filled then the count will be zero; add all arrays
    if ([collectedArrays count] == 0) {
        //DLog(@"Initilize collectedArrays: [collectedArrays count] == 0");
        //DLog(@"currentLine = %@", currentLine);
        //DLog(@"currentData = %@", currentData);

        
        int currentColumn = 0;
        for (currentColumn = 0; currentColumn <= [currentData count] - 1; ++currentColumn) {
            NSMutableArray *newArray = [NSMutableArray arrayWithObject: [currentData objectAtIndex: currentColumn]];
            [collectedArrays addObject: newArray];
        }
        ++currentLineNumber;
        
        //DLog(@"[collectedArrays count] = %lu", [collectedArrays count]);

    }
    else {
        DLog(@"BAD: [collectedArrays count] != 0, should be 0");

    }
    
    
    // CHANGED
	//for (currentLineNumber = currentLineNumber; currentLineNumber <= [self.contentArray count] -1; ++currentLineNumber) {
    for ( ; currentLineNumber <= [self.contentArray count] -1; ++currentLineNumber) {

		//DLog(@"set currentLineNumber = %i", currentLineNumber);

		
		// Get the current line and parse it into an array
		currentLine = [self.contentArray objectAtIndex: currentLineNumber];
		currentData = [currentLine componentsSeparatedByString: separator];
        

        //DLog(@"currentLine = %@", currentLine);
        //DLog(@"currentData = %@", currentData);

		
		
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
            //DLog(@"ERROR: currentLine = %i", currentLineNumber);
            //DLog(@"ERROR: collectedArraysCount != currentDataCount; %i != %i", collectedArraysCount, currentDataCount);

        }
		
        int currentColumn;
        for (currentColumn = 0; currentColumn <= [currentData count] - 1; ++currentColumn) {
			
            [[collectedArrays objectAtIndex: currentColumn] addObject: [currentData objectAtIndex: currentColumn]];
        }
	}
	
	// Put collected arrays into dataArrays and return
	dataArrays = [NSMutableArray arrayWithArray: collectedArrays];
    //DLog(@"FINISHED: parseDataSection with %i", success);

	return success;
}


// Deallocation
#pragma mark Deallocation
-(void) dealloc {
    //[super dealloc];
}

@end
