//
//  HNPreferencePanelWindowController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 7/30/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNPreferencePanelWindowController.h"
#import "PreCompiledHeaders.h"

#import "DMTabBar.h"

//NSString *const HNGreyOrColorIconKey = @"GreyOrColorIcons";

//NSString *const HNGreyOrColorIconNotification = @"HNGreyOrColorIconChanged";

@interface HNPreferencePanelWindowController ()

@end



@implementation HNPreferencePanelWindowController

@synthesize tabBarElements;
@synthesize tabBar;


- (id)init {
    self = [super initWithWindowNibName: @"HNPreferencePanelWindowController"];
    if (!self) {
        return nil;
    }
    
    tabBarElements = [NSArray arrayWithObjects:@{ @"image" : [NSImage imageNamed: NSImageNamePreferencesGeneral], @"title" : @"Edit General Preferences"},
                      @{ @"image" : [NSImage imageNamed:NSImageNameInfo], @"title" : @"Edit Text Preferences" }, nil];
    
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [checkboxGreyOrColorIcons setState: [self greyOrColorIcons]];
    
}

-(void) awakeFromNib {
	DLog(@"Called - HNPreferencePanelWindowController: awakeFromNib");
	
    [self loadTabBarWithTemplate: YES];
}



#pragma mark -
#pragma mark User Defaults
-(bool) greyOrColorIcons {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *greyOrColorIconState = [defaults objectForKey:HNGreyOrColorIconKey];

    return [greyOrColorIconState integerValue];
}

-(bool) resetCropOnNewSelection {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *resetCropOnNewSelection = [defaults objectForKey: HNResetCropOnNewSelectionKey];
	
	return [resetCropOnNewSelection boolValue];
}


#pragma mark -
#pragma mark Tab Bar
-(void) loadTabBarWithTemplate: (bool)templateState {
    //DLog(@"Called - HNAppDelegate: loadTabBarWithTemplate");
	
	if (!tabBar) {
		DLog(@"No tabBar");
	}
	
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];
    
    // Create an array of DMTabBarItem objects
    [tabBarElements enumerateObjectsUsingBlock:^(NSDictionary* objDict, NSUInteger idx, BOOL *stop) {
        NSImage *iconImage = [objDict objectForKey:@"image"];
        //[iconImage setTemplate:YES];
        [iconImage setTemplate: templateState];
        
        DMTabBarItem *item1 = [DMTabBarItem tabBarItemWithIcon:iconImage tag:idx];
        item1.toolTip = [objDict objectForKey:@"title"];
        item1.keyEquivalent = [NSString stringWithFormat:@"%ld",idx];
        item1.keyEquivalentModifierMask = NSEventModifierFlagCommand;
        [items addObject:item1];
    }];
    

    
	
    // Load them
    tabBar.tabBarItems = items;

	
	
    
    // Handle selection events
    [tabBar handleTabBarItemSelection:^(DMTabBarItemSelectionType selectionType, DMTabBarItem *targetTabBarItem, NSUInteger targetTabBarItemIndex) {
        if (selectionType == DMTabBarItemSelectionType_WillSelect) {
            //DLog(@"Will select %lu/%@",targetTabBarItemIndex,targetTabBarItem);
            [self->tabView selectTabViewItem:[self->tabView.tabViewItems objectAtIndex:targetTabBarItemIndex]];
        } else if (selectionType == DMTabBarItemSelectionType_DidSelect) {
            //DLog(@"Did select %lu/%@",targetTabBarItemIndex,targetTabBarItem);
        }
    }];
	
    //DLog(@"finisehd loadTablBarWithTemplate");
}


#pragma mark -
#pragma mark IBActions
-(IBAction)changeIconColor:(id)sender {
    NSNumber *greyOrColorIconState = [NSNumber numberWithInteger: [checkboxGreyOrColorIcons state]];
    
    // Update user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: greyOrColorIconState forKey: HNGreyOrColorIconKey];
    
    // Post change to Notification Center
    NSNotificationCenter *iconColorChangeNotifiation = [NSNotificationCenter defaultCenter];
    NSDictionary *iconChangeDictionary = [NSDictionary dictionaryWithObject: greyOrColorIconState forKey:@"greyOrColorIconState"];
    
    
    [iconColorChangeNotifiation postNotificationName:HNGreyOrColorIconNotification
                                              object: self
                                            userInfo: iconChangeDictionary];
}

-(IBAction)changeResetCropOnNewSelection:(id)sender {
	DLog(@"CALLED - HNPreferencePanelWindowController: changeResetCropOnNewSelection");
	NSNumber *resetCropOnNewSelection = [NSNumber numberWithBool: [checkBoxResetCropOnNewSelection state]];
	
	// Update UserDefaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: resetCropOnNewSelection forKey: HNResetCropOnNewSelectionKey];
	
	// Post Change to Notification Center
	NSNotificationCenter *nc= [NSNotificationCenter defaultCenter];
	NSDictionary *userInfo = [NSDictionary dictionary];
	[nc postNotificationName: HNResetCropOnNewSelectionNotification
					  object: self
					userInfo:userInfo];
}


#pragma mark -
#pragma mark DMTabBarDelegate Methods
-(CGFloat) dMTabBarWillSetTabBarItemWidth {
	DLog(@"CALLED - HNPreferencePanelWindowController: dMTabBarWillSetTabBarItemWidth");
	CGFloat tabBarWidth = 50.0;
	return  tabBarWidth;
}

@end
