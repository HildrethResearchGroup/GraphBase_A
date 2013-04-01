//
//  NSArrayController_HNExtensions.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/5/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface NSArrayController (HNExtensions)

@end


@implementation NSArrayController (HNExtensions)

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    [super bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options];
    DLog(@"\n\nNSArrayController Bindings\n");
    DLog(@"binding      = %@", binding);
    DLog(@"toObject     = %@", observableController);
    DLog(@"withKeyPath  = %@", keyPath);
    DLog(@"options      = %@", options);
}


@end
