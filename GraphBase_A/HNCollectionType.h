//
//  HNCollectionType.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 11/14/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HNTreeNode;

@interface HNCollectionType : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) NSSet *treeNodes;
@end

@interface HNCollectionType (CoreDataGeneratedAccessors)

- (void)addTreeNodesObject:(HNTreeNode *)value;
- (void)removeTreeNodesObject:(HNTreeNode *)value;
- (void)addTreeNodes:(NSSet *)values;
- (void)removeTreeNodes:(NSSet *)values;

@end
