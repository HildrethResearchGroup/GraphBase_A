//
//  HNAccessoryView.m
//  GraphBase_A
//
//  Created by Owen on 12/5/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNAccessoryView.h"
#import "PreCompiledHeaders.h"
#import "HNUserDefaultStrings.h"

@implementation HNAccessoryView
@synthesize openPanel = _openPanel;
@synthesize filterDescriptions = _filterDescriptions;


-(IBAction) selectFileTypes:(id)sender {
    NSInteger index = [sender indexOfSelectedItem];

    if (index > -1) {
        selectedIndex = index;
        [self.openPanel validateVisibleColumns];
    }
}


- (BOOL)panel:(id)sender  shouldEnableURL:(NSURL *)url {
    
    
    // currently assume only two levels for the combobox
    if (selectedIndex > 0) {
        return YES;
    }
    
    // Get current file Types
    
    
    if (!fileTypes) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        fileTypes = [defaults objectForKey: HNExtensionsForDataFileTypesKey];
    }
    
    BOOL dir;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm fileExistsAtPath: [url path] isDirectory: &dir];
    
    
    // Do not treat packages as directories
    BOOL isPackage = [[NSWorkspace sharedWorkspace] isFilePackageAtPath: [url path]];
    
    if (dir && !isPackage) {
        return YES;
    }
    
    else {
        NSString *extension = [url pathExtension];
        NSString *lcExt = [extension lowercaseString];
        NSString *ucExt = [extension uppercaseString];
        
        if ([fileTypes arrayContainsString: extension] || [fileTypes arrayContainsString: lcExt] || [fileTypes arrayContainsString: ucExt] ) {
            return YES;
        }
        
        return NO;       
    }
}

@end
