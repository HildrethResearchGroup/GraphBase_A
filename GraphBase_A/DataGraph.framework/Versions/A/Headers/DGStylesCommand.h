//
//  DGStylesCommand.h
//  DataGraphFrameworkTest
//
//  Created by David Adalsteinsson on 1/7/09.
//  Copyright 2009-2013 Visual Data Tools, Inc. All rights reserved.
//

#import "DGCommand.h"

// This class is based on the DGCommand class.  All this class does is to simplify setting
// a few entries for the Styles.  For getters, and to connect UI elements use methods for the base class.

@interface DGStylesCommand : DGCommand
{
}

// Presets
- (NSString *)currentStyleSetName;
- (NSArray *)styleSetNames;
- (void)selectStyleSet:(NSString *)style;

@end
