//
//  HNSplitViewController.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 12/29/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNSplitViewController : NSObject <NSSplitViewDelegate> {
	CGFloat lastRightColumnWidth;
	CGFloat lastLeftColumnWidth;
	
	
}

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *leftColumn;
@property (weak) IBOutlet NSView *middleColumn;
@property (weak) IBOutlet NSView *rightColumn;
@property (weak) IBOutlet NSView *mainView;


-(IBAction) toggleLeftColumn:(id)sender;
-(IBAction) toggleRightColumn:(id)sender;


@end
