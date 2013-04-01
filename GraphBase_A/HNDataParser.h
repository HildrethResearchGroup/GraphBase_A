//
//  HNDataParser.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/13/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HNDataItem;
@class HNParseTemplate;

@interface HNDataParser : NSObject {
	
	NSMutableDictionary *parseDictionary;
	
	
    NSString *dataFilePath;
    HNDataItem *dataItem;
    HNParseTemplate *parseTemplate;
    
	
	// Variables to hold the output data
    NSMutableArray      *dataArrays;
    NSArray             *fieldNames;
    NSMutableString		*experimentalDetails;
	NSString            *dataString;
	
	
	// Variables to settings
    BOOL            hasExperimentalDetails;
    BOOL            hasHeader;
    BOOL            hasData;
	
	// Local variables to monitor progress
    //NSScanner       *scanner;
    int             currentLineNumber;
	
}

@property (nonatomic, retain) NSMutableDictionary	*parseDictionary;
@property (nonatomic, retain) NSString			*dataFilePath;
@property (nonatomic, assign) HNDataItem		*dataItem;
@property (nonatomic, assign) HNParseTemplate	*parseTemplate;
@property (nonatomic, retain) NSMutableArray	*dataArrays;
@property (nonatomic, retain) NSArray			*fieldNames;
@property (nonatomic, retain) NSMutableString	*experimentalDetails;
@property BOOL hasExperimentalDetails;
@property BOOL hasHeader;
@property BOOL hasData;
@property int currentLineNumber;



#pragma mark -
#pragma mark Public Methods
-(id) initWithDataItem: (HNDataItem *)dataItemIn andParseTemplate: (HNParseTemplate *) parseTemplateIn;
-(BOOL) parseEntireFile;




@end
