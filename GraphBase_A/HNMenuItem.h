//
//  HNMenuItem.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/11/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HNMenuItem : NSMenuItem {
    NSDictionary *userInfo;
    NSString     *notificationType;
}

@property (retain, nonatomic) NSDictionary *userInfo;
@property (retain, nonatomic) NSString     *notificationType;

-(id) initWithTitle:(NSString *)aString
             action:(SEL)aSelector
      keyEquivalent:(NSString *)charCode
keyEquivalentModifierMask: (NSUInteger) modifierMask;


@end
