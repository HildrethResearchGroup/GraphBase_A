//
//  HNAccessoryView.h
//  GraphBase_A
//
//  Created by Owen on 12/5/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HNAccessoryView : NSView <NSOpenSavePanelDelegate> {
    @public
    
    NSOpenPanel     *openPanel;
    NSArray         *fileTypes;
    NSInteger       selectedIndex;
    
    IBOutlet NSComboBox *filterDescriptions;
}

@property (assign) NSOpenPanel *openPanel;
@property (retain) NSComboBox  *filterDescriptions;

@end
