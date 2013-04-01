//
//  HNDataItem.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/8/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <DataGraph/DataGraph.h>


@class HNGraphTemplate, HNParseTemplate, HNTreeNode;


extern NSString * const HNPropertyListFileName;
// DIP stands for DataItemProperty
extern NSString * const HNDIP_DGRangeCrop;
extern NSString * const HNDIP_maxValue;
extern NSString * const HNDIP_minValue;



@interface HNDataItem : NSManagedObject {
	NSMutableDictionary *propertyList;
	
}

@property (nonatomic, retain) NSDate * dateFileImported;
@property (nonatomic, retain) NSDate * dateFileLastModified;
@property (nonatomic, retain) NSDate * dateFileLastParsed;
@property (nonatomic, retain) NSDate * dateLocalizedResourceLastModified;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * experimentalDetailsFromHeader;
@property (nonatomic, retain) NSString * experimentalNotes;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * localizedResourcePath;
@property (nonatomic, retain) NSString * storedUUID;

@property (nonatomic, retain) HNGraphTemplate *graphTemplate;
@property (nonatomic, retain) HNParseTemplate *parseTemplate;
@property (nonatomic, retain) HNTreeNode *treeNode;

@property (nonatomic, retain) NSMutableDictionary *propertyList;


// This sets the default graph template and parse template using the defaults from parent tree node as the source
-(BOOL) setDefaultsFromParent;
-(BOOL) setLocalizedResourcePathFrom: (NSURL *) applicationSupportFolder;
-(void) setDefaultCropRange;

// Used to store 
-(NSString *) applicationSupportLocalDataFileName;

#pragma mark -
#pragma mark Property Lists
-(id) propertyListValueForKey: (NSString *) key;
-(BOOL) setPropertyListValue: (id) value forKey: (NSString *) key;


#pragma mark -
#pragma mark Quick Access Property Lists
-(void) quickCropRangeToPropertyList: (DGRange) range;
-(DGRange) quickCropRangeFromPropertyList;

@end
