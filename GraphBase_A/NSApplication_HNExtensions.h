//
//  NSApplication_HNExtensions.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 10/2/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface NSApplication (HNExtensions)
-(NSURL *) applicationFilesDirectory;

@end



@implementation  NSApplication (HNExtensions)

- (NSURL *)applicationFilesDirectory
{
    //DLog(@"Called - HNAppDelegate: applicationFilesDirectory");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    
    // For Dev Build
    //return [appSupportURL URLByAppendingPathComponent:@"H-Nano/GraphBase_A/DevBuild"];
    
    // For RELEASE build
    return [appSupportURL URLByAppendingPathComponent:@"H-Nano/GraphBase_A"];
}

@end


