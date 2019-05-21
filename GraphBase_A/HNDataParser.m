//
//  HNDataParser.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/13/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNDataParser.h"
#import "HNDataItem.h"
#import "HNParseTemplate.h"


@implementation HNDataParser
@synthesize parseDictionary			= _parseDictionary;
@synthesize dataFilePath			= _dataFilePath;
@synthesize dataItem				= _dataItem;
@synthesize parseTemplate			= _parseTemplate;
@synthesize dataArrays				= _dataArrays;
@synthesize fieldNames				= _fieldNames;
@synthesize experimentalDetails		= _experimentalDetails;
@synthesize hasExperimentalDetails	= _hasExperimentalDetails;
@synthesize hasHeader				= _hasHeader;
@synthesize hasData					= _hasData;
@synthesize currentLineNumber		= _currentLineNumber;


#pragma mark -
#pragma mark Initializers
// Designated Initializer
-(id) initWithDataItem: (HNDataItem *)dataItemIn andParseTemplate: (HNParseTemplate *) parseTemplateIn {
    DLog(@"CALLED - HNDataParser: initWithDataItem");

    self = [super init];
    
    if (!self) {
        return nil;
    }
    
	if (dataItemIn) {
		[self setDataItem: dataItemIn];
		[self setDataFilePath: dataItemIn.filePath];
	}
	
    if (parseTemplateIn) {
		[self setParseTemplate: parseTemplateIn];
	}
   
    experimentalDetails = [NSMutableString string];
    
	parseDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"\t", @"Tab", @"\t", @"tab", @" ", @"Space", @" " , @"space", @" ", @" ", @",", @"Comma", @",", @"comma", @";", @"Semicolon", @";", @"semicolon", @":", @"Colon", @":", @"colon", nil];

	//[self setBoolValuesForScanning];
	 
    return self;

}

-(id) initWithDataItem:(HNDataItem *)dataItemIn {
	
	self = [self initWithDataItem: dataItemIn andParseTemplate: [dataItemIn parseTemplate]];
	
	if (!self) {
		return nil;
	}
	
	return self;
}

-(id) init {
	self = [self initWithDataItem: nil andParseTemplate:nil];
	
	return self;
}


-(BOOL) setBoolValuesForScanning {

	if (!parseTemplate) {
		return NO;
	}
    

	
	// Set values from
    hasExperimentalDetails	= [parseTemplate.yesNo_hasExpDet boolValue];
    hasHeader				= [parseTemplate.yesNo_hasHeader boolValue];
    hasData					= [parseTemplate.yesNo_hasData   boolValue];
    //DLog(@"hasExpDet = %i, hasHeader = %i, hasData = %i", hasExperimentalDetails, hasHeader, hasData);
	
	return YES;
}



#pragma mark -
#pragma mark Parsing Routines
NSString *readLineAsNSString(FILE *file)
{
    char buffer[4096];
    
    // tune this capacity to your liking -- larger buffer sizes will be faster, but
    // use more memory
    NSMutableString *result = [NSMutableString stringWithCapacity:256];
    
    // Read up to 4095 non-newline characters, then read and discard the newline
    int charsRead;
    do
    {
        if(fscanf(file, "%4095[^\n]%n%*c", buffer, &charsRead) == 1)
            [result appendFormat:@"%s", buffer];
        else
            break;
    } while(charsRead == 4095);
    
    return result;
}


-(BOOL) parseEntireFile {
	DLog(@"Called: ParsedDataCollector - parseEntireFile");

	
	BOOL success = YES;
	/*
	hasExperimentalDetails = YES;
	hasHeader				= YES;
	hasData					= YES;
	
    int lineEnd_data		= 100;
	int lineEnd_expDet		= 13;
	int lineEnd_header		= 14;
	int lineStart_data		= 17;
	int lineStart_expDet	= 1;
	int lineStart_header	= 14;
	*/
	//NSString *seporatorFields_data = @"\t";
	//DLog(@"seporatorFields_data = %@", seporatorFields_data);
	
    
    
    dataFilePath = @"/Users/OwenHildreth/Documents/Code/GraphBase/GraphBase_A/GraphBase_A/TestData.txt";
    
	
	NSFileManager *fm = [NSFileManager defaultManager];
	//NSMutableDictionary *dataContentAttributes = [NSMutableDictionary dictionary];
	
	if (![fm fileExistsAtPath:dataFilePath]) {
        DLog(@"File does not exist at %@", dataFilePath);
        
        success = NO;
        return success;
    }
   
    const char *cStringPointer = [dataFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    
    //FILE *file = fopen("/Users/OwenHildreth/Documents/Code/GraphBase/GraphBase_A/GraphBase_A/TestData.txt", "r");
    FILE *file = fopen(cStringPointer, "r");
    if (!file) {
        DLog(@"Failed to translate NSString to c string");
        success = NO;
        return success;
    }

    int lineCount = 1;
    while(!feof(file))
    {
        //NSString *line = readLineAsNSString(file);
        
        // do stuff with line; line is autoreleased, so you should NOT release it (unless you also retain it beforehand)
        ++lineCount;
        //DLog(@"%i:  %@",lineCount, line);
        
    }
    fclose(file);
    
	
	DLog(@"Finished First Parser");
	DLog(@"Experimental Details = %@", experimentalDetails);
    
	return success;
}




@end
