//
//  HNTreeNode.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/8/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HNDataItem, HNGraphTemplate, HNParseTemplate, HNTreeNode, HNCollectionType;

@interface HNTreeNode : NSManagedObject {
	NSDictionary *keys;
}

@property (nonatomic, retain) NSDictionary *keys;

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateLastModified;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * isLeaf;
@property (nonatomic, retain) NSNumber * isSelectable;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) NSNumber * canCollapse;
@property (nonatomic, retain) NSNumber * canExpand;
@property (nonatomic, retain) NSNumber * isExpanded;
@property (nonatomic, retain) NSNumber * isSpecialGroup;
@property (nonatomic, retain) NSString * storedUUID;


@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) HNTreeNode *parent;

@property (nonatomic, retain) NSSet *dataItems;
@property (nonatomic, retain) HNGraphTemplate *defaultGraphTemplate;
@property (nonatomic, retain) HNParseTemplate *defaultParseTemplate;
@property (nonatomic, retain) HNCollectionType *collectionType;

@property (nonatomic, retain) NSSet *graphTemplates;
@property (nonatomic, retain) NSSet *parseTemplates;
@property (readonly) NSSet *allGraphTemplates;
@property (readonly) NSSet *allDataItems;

@end

@interface HNTreeNode (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(HNTreeNode *)value;
- (void)removeChildrenObject:(HNTreeNode *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)addDataItemsObject:(HNDataItem *)value;
- (void)removeDataItemsObject:(HNDataItem *)value;
- (void)addDataItems:(NSSet *)values;
- (void)removeDataItems:(NSSet *)values;

- (void)addGraphTemplatesObject:(HNGraphTemplate *)value;
- (void)removeGraphTemplatesObject:(HNGraphTemplate *)value;
- (void)addGraphTemplates:(NSSet *)values;
- (void)removeGraphTemplates:(NSSet *)values;

- (void)addParseTemplatesObject:(HNParseTemplate *)value;
- (void)removeParseTemplatesObject:(HNParseTemplate *)value;
- (void)addParseTemplates:(NSSet *)values;
- (void)removeParseTemplates:(NSSet *)values;





-(NSArray *) allTreeNodeChildren;
-(NSSet *) allDataItems;
-(NSSet *) allGraphTemplates;
-(NSSet *) allParseTemplates;


-(BOOL) setDefaultsFromParent;



// EMPTY methods
-(void) addAllDataItems: (NSSet *) values;
-(void) addAllDataItemsObject: (HNDataItem *) value;
-(void) removeAllDataItems: (NSSet *) values;
-(void) removeAllDataItemsObject: (HNDataItem *) value;



@end
