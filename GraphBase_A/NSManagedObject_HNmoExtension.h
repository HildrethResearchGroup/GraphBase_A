//
//  NSManagedObject_HNmoExtension.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 10/23/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (HNmoExtension)
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context;

@end

@implementation NSManagedObject (HNmoExtension)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
{
    NSEntityDescription *entityDescription;
    if ( [self respondsToSelector:@selector(entityInManagedObjectContext:)]) {
        entityDescription = [self performSelector:@selector(entityInManagedObjectContext:) withObject:context];
    }
    else {
        entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
    }
    return entityDescription;
}

+ (NSArray *)findAllObjects;
{
    NSManagedObjectContext *context;
    
    id nsApplicationDelegate = [[NSApplication sharedApplication] delegate];
    
    if (nsApplicationDelegate) {
        SEL contextSelector = NSSelectorFromString(@"managedObjectContext");
        
        if ([nsApplicationDelegate respondsToSelector: contextSelector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            context = [nsApplicationDelegate performSelector: contextSelector];
            #pragma clang diagnostic pop
        }
                       
                      
    }
    
    return [self findAllObjectsInContext:context];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context;
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        //handle errors
    }
    return results;
}

@end
