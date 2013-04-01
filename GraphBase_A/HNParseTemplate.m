//
//  HNParseTemplate.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/18/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNParseTemplate.h"
#import "HNDataItem.h"
#import "HNTreeNode.h"


@implementation HNParseTemplate

@dynamic dateImported;
@dynamic dateLastModified;
@dynamic displayName;
@dynamic lineEnd_data;
@dynamic lineEnd_expDet;
@dynamic lineEnd_header;
@dynamic lineStart_data;
@dynamic lineStart_expDet;
@dynamic lineStart_header;
@dynamic separator_dataFields;
@dynamic separator_expDetFields;
@dynamic separator_expDetUnits;
@dynamic separator_headerFields;
@dynamic separator_headerUnits;
@dynamic yesNo_hasData;
@dynamic yesNo_hasExpDet;
@dynamic yesNo_hasHeader;
@dynamic storedUUID;


@dynamic dataItems;
@dynamic defaultParseTemplateForCollections;
@dynamic treeNodes;



-(void) awakeFromInsert {
	[self addObserver: self forKeyPath: @"dateLastModified"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
    [self setDateImported: [NSDate date]];
    [self setDateLastModified: [NSDate date]];
	
	NSString *UUID = [[NSProcessInfo processInfo] globallyUniqueString];
	[self setStoredUUID: UUID];
}

-(void) awakeFromFetch {
	 [self addObserver:self forKeyPath:@"dateLastModified"
			   options:NSKeyValueObservingOptionNew
			   context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if( [keyPath isEqualToString:@"dateLastModified"] ){
		[self setPrimitiveValue:[NSDate date] forKey: @"dateLastModified"];
        //[self setValue: [NSDate date] forKey: @"dateLastModified"];
	}
}

-(NSDictionary *) propertiesForExport {
    NSDictionary *propertyValues = @{ @"displayName":self.displayName, @"lineEnd_data":self.lineEnd_data, @"lineEnd_expDet":self.lineEnd_expDet, @"lineEnd_header":self.lineEnd_header, @"lineStart_data":self.lineStart_data, @"lineStart_expDet" : self.lineStart_expDet, @"lineStart_header":self.lineStart_header, @"separator_dataFields":self.separator_dataFields, @"separator_expDetFields":self.separator_expDetFields, @"separator_expDetUnits":self.separator_expDetUnits, @"separator_headerFields":self.separator_headerFields, @"yesNo_hasData":self.yesNo_hasData, @"yesNo_hasExpDet":self.yesNo_hasExpDet, @"yesNo_hasHeader":self.yesNo_hasHeader };

    return propertyValues;
    
}


+(NSSet *) keyPathsForValuesAffectingDateLastModified {
	DLog(@"CALLED - HNParseTemplate: keyPathsForValuesAffectingDateLastModified");
	return [NSSet setWithObjects: @"lineEnd_data", @"lineEnd_expDet", @"lineEnd_header", @"lineStart_data", @"lineStart_expDet", @"lineStart_header", @"separator_dataFields", @"separator_expDetFields", @"separator_expDetUnits", @"separator_headerFields", @"separator_headerUnits", @"yesNo_hasData", @"yesNo_hasExpDet", @"yesNo_hasHeader", nil];
}




@end
