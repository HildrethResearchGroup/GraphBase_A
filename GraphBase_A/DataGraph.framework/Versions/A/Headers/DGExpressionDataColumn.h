//  Created by David Adalsteinsson on 10/5/09.
//  Copyright 2009-2013 Visual Data Tools, Inc. All rights reserved.
//
#import "DGDataColumn.h"

@interface DGExpressionDataColumn : DGDataColumn {

}

- (NSString *)expressionString;
- (void)setExpressionString:(NSString *)str;

- (NSString *)errorString; // nil if the expression is OK.  Same error as is displayed in DataGraph.

@end
