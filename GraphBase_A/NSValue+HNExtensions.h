//
//  NSValue+HNExtensions.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 10/2/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DataGraph/DataGraph.h>

@interface NSValue (HNExtensions)

+(NSValue *) valueWithDGRange:(DGRange) range;
-(DGRange) dgRangeValue;



@end
