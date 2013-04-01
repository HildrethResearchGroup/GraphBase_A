//
//  NSArray_Extension.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/6/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "NSArray_Extensions.h"

@implementation NSArray (HNExtension)

-(id) firstObject {
	if	([self count] == 0)	{
		return nil;
	}
	
return [self objectAtIndex: 0];
}

@end
