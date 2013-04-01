//
//  HNParseTemplate.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/18/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HNDataItem, HNTreeNode;

@interface HNParseTemplate : NSManagedObject

@property (nonatomic, retain) NSDate * dateImported;
@property (nonatomic, retain) NSDate * dateLastModified;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * lineEnd_data;
@property (nonatomic, retain) NSNumber * lineEnd_expDet;
@property (nonatomic, retain) NSNumber * lineEnd_header;
@property (nonatomic, retain) NSNumber * lineStart_data;
@property (nonatomic, retain) NSNumber * lineStart_expDet;
@property (nonatomic, retain) NSNumber * lineStart_header;
@property (nonatomic, retain) NSString * separator_dataFields;
@property (nonatomic, retain) NSString * separator_expDetFields;
@property (nonatomic, retain) NSString * separator_expDetUnits;
@property (nonatomic, retain) NSString * separator_headerFields;
@property (nonatomic, retain) NSString * separator_headerUnits;
@property (nonatomic, retain) NSNumber * yesNo_hasData;
@property (nonatomic, retain) NSNumber * yesNo_hasExpDet;
@property (nonatomic, retain) NSNumber * yesNo_hasHeader;
@property (nonatomic, retain) NSString * storedUUID;


@property (nonatomic, retain) NSSet *dataItems;
@property (nonatomic, retain) NSSet *defaultParseTemplateForCollections;
@property (nonatomic, retain) NSSet *treeNodes;
@end

@interface HNParseTemplate (CoreDataGeneratedAccessors)

- (void)addDataItemsObject:(HNDataItem *)value;
- (void)removeDataItemsObject:(HNDataItem *)value;
- (void)addDataItems:(NSSet *)values;
- (void)removeDataItems:(NSSet *)values;

- (void)addDefaultParseTemplateForCollectionsObject:(HNTreeNode *)value;
- (void)removeDefaultParseTemplateForCollectionsObject:(HNTreeNode *)value;
- (void)addDefaultParseTemplateForCollections:(NSSet *)values;
- (void)removeDefaultParseTemplateForCollections:(NSSet *)values;

- (void)addTreeNodesObject:(HNTreeNode *)value;
- (void)removeTreeNodesObject:(HNTreeNode *)value;
- (void)addTreeNodes:(NSSet *)values;
- (void)removeTreeNodes:(NSSet *)values;

-(NSDictionary *) propertiesForExport;

@end
