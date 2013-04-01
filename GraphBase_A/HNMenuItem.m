//
//  HNMenuItem.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/11/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNMenuItem.h"

@implementation HNMenuItem

@synthesize userInfo         = _userInfo;
@synthesize notificationType = _notificationType;


-(id) initWithTitle:(NSString *)aString
             action:(SEL)aSelector
keyEquivalent:(NSString *)charCode
keyEquivalentModifierMask: (NSUInteger) modifierMask {
    self = [super initWithTitle: aString action:aSelector keyEquivalent: charCode];
    
    if (self) {
        [self setKeyEquivalentModifierMask: modifierMask];
    }
    
    return self;
}


@end
