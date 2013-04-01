//
//  HNPreferencePanelWindowController.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 7/30/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMTabBarDelegate.h"
@class DMTabBar;

extern NSString *const HNGreyOrColorIconNotification;

@interface HNPreferencePanelWindowController : NSWindowController <DMTabBarDelegate> {
    
    // Tab Bar
    IBOutlet    DMTabBar    *tabBar;
    IBOutlet    NSTabView   *tabView;
    NSArray *tabBarElements;
    
    // UI Options
    IBOutlet NSButton *checkboxGreyOrColorIcons;
	IBOutlet NSButton *checkBoxResetCropOnNewSelection;
    
}
@property (retain, nonatomic) NSArray *tabBarElements;
@property (retain, nonatomic) DMTabBar *tabBar;



#pragma mark -
#pragma mark User Defaults
-(bool) greyOrColorIcons;
-(bool) resetCropOnNewSelection;


#pragma mark -
#pragma mark IBActions
-(IBAction)changeIconColor:(id)sender;
-(IBAction)changeResetCropOnNewSelection:(id)sender;

@end
