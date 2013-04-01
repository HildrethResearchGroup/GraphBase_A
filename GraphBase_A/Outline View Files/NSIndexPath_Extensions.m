//
//  NSIndexPath_Extension.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/6/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "NSIndexPath_Extensions.h"

@implementation NSIndexPath (ESExtensions)

- (NSUInteger)firstIndex;
{
	return [self indexAtPosition:0];
}

- (NSUInteger)lastIndex;
{
	return [self indexAtPosition:[self length] - 1];
}

- (NSIndexPath *)indexPathByIncrementingLastIndex;
{
	NSUInteger lastIndex = [self lastIndex];
	NSIndexPath *temp = [self indexPathByRemovingLastIndex];
	return [temp indexPathByAddingIndex:++lastIndex];
}

- (NSIndexPath *)indexPathByReplacingIndexAtPosition:(NSUInteger)position withIndex:(NSUInteger)index;
{
	NSUInteger indexes[[self length]];
	[self getIndexes:indexes];
	indexes[position] = index;
	return [[NSIndexPath alloc] initWithIndexes:indexes length:[self length]];
}

@end
