//
//  NSValue+HNExtensions.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 10/2/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "NSValue+HNExtensions.h"

@implementation NSValue (HNExtensions)

+(NSValue *) valueWithDGRange:(DGRange) range {
	DLog(@"CALLED - NSValue: valueWithDGRange");
	
	NSValue *newValue = [NSValue value: &range withObjCType: @encode(DGRange)];
	
	return newValue;
	
}

-(DGRange) dgRangeValue {
	DLog(@"CALLED - NSValue: dgRangeValue");
	DGRange value;
	
	[self getValue: &value];
	
	return value;
	
}


@end
