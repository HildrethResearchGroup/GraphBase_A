//
//  ParsedDataCollector.h
//  GraphTest-A
//
//  Created by Owen Hildreth on 1/13/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HNDataItem.h"
#import "HNParseTemplate.h"

@interface ParsedDataCollector : NSObject {
	NSMutableDictionary *parseDictionary;
	
    HNDataItem			*dataObject;
    HNParseTemplate		*parseTemplateObject;
    NSString			*contentString;
	NSArray				*contentArray;
    
    // Variables to hold the output data
    NSMutableArray  *dataArrays;
    NSArray			*fieldNames;
    NSString        *experimentalDetails;
    NSString        *dataString;
    
    
    // Variables to settings
    BOOL            hasExpDet;
    BOOL            hasHeader;
    BOOL            hasData;
    
    // Local variables to monitor progress
    NSScanner       *scanner;
    int             currentLineNumber;
}

@property (nonatomic, retain) NSMutableDictionary	*parseDictionary;

@property (nonatomic, retain) HNDataItem		*dataObject;
@property (nonatomic, retain) HNParseTemplate	*parseTemplateObject;

@property (retain) NSString         *contentString;
@property (retain) NSArray			*contentArray;

@property (retain) NSMutableArray   *dataArrays;
@property (retain) NSArray			*fieldNames;
@property (retain) NSString         *experimentalDetails;
@property (retain) NSString         *dataString;
@property (retain) NSScanner        *scanner;
@property int currentLineNumber;


// Designated Initilizer
-(id) initWithDataObject:(HNDataItem *) dataObjectIn;


// Parse all the data from the Data File
-(BOOL) parseEntireFile;
-(BOOL) loadFileIntoContentString;
-(BOOL) parseContentStringIntoContentArray;
-(BOOL) setBoolValuesForScanning;
-(NSString *) translateParseSeparator: (NSString *) userParseSeparatorIn;


// Parse Sections of Data File
-(BOOL) parseExperimentalDetailsSection;
-(BOOL) parseHeaderSection;
-(BOOL) parseDataSection;


// Deallocation
-(void) dealloc;

@end
