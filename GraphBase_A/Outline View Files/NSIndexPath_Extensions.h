//
//  NSIndexPath_Extension.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/6/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSIndexPath (HNExtensions)

-(NSUInteger) firstIndex;
-(NSUInteger) lastIndex;
-(NSIndexPath *) indexPathByIncrementingLastIndex;
-(NSIndexPath *) indexPathByReplacingIndexAtPosition:(NSUInteger) position withIndex:(NSUInteger)index;

@end
