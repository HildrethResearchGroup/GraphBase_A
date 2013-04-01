//
//  HNGraphTemplate.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/8/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HNDataItem, HNTreeNode;

@interface HNGraphTemplate : NSManagedObject

@property (nonatomic, retain) NSDate * dateImported;
@property (nonatomic, retain) NSDate * dateLastModified;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * storedUUID;


@property (nonatomic, retain) NSSet *treeNodes;
@property (nonatomic, retain) NSSet *dataItems;
@property (nonatomic, retain) NSSet *defaultGraphForCollections;
@end

@interface HNGraphTemplate (CoreDataGeneratedAccessors)

- (void)addTreeNodesObject:(HNTreeNode *)value;
- (void)removeTreeNodesObject:(HNTreeNode *)value;
- (void)addTreeNodes:(NSSet *)values;
- (void)removeTreeNodes:(NSSet *)values;

- (void)addDataItemsObject:(HNDataItem *)value;
- (void)removeDataItemsObject:(HNDataItem *)value;
- (void)addDataItems:(NSSet *)values;
- (void)removeDataItems:(NSSet *)values;

- (void)addDefaultGraphForCollectionsObject:(HNTreeNode *)value;
- (void)removeDefaultGraphForCollectionsObject:(HNTreeNode *)value;
- (void)addDefaultGraphForCollections:(NSSet *)values;
- (void)removeDefaultGraphForCollections:(NSSet *)values;

@end
