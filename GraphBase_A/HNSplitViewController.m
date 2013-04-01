//
//  HNSplitViewController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 12/29/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNSplitViewController.h"
#import "DMPaletteContainer.h"

@implementation HNSplitViewController

/*
-(IBAction) toggleLeftColumn:(id)sender {
	NSView *viewToToggle = self.leftColumn;
    [viewToToggle setAutoresizesSubviews: YES];
    CGFloat lastWidth = lastLeftColumnWidth;
	
	if ([self.splitView isSubviewCollapsed: viewToToggle]) {
		// viewToToggle is collapsed -> expand viewToToggle
        // NSSplitView hides the collapsed subview
        viewToToggle.hidden = NO;
        
        NSMutableDictionary *expandMiddleAnimationDict = [NSMutableDictionary dictionaryWithCapacity: 2];
        [expandMiddleAnimationDict setObject: self.middleColumn forKey: NSViewAnimationTargetKey];
        NSRect newMiddleFrame = self.middleColumn.frame;
        newMiddleFrame.origin.x = lastLeftColumnWidth;
        newMiddleFrame.size.width = self.splitView.frame.size.width - self.rightColumn.frame.size.width - lastWidth;
        [expandMiddleAnimationDict setObject: [NSValue valueWithRect: newMiddleFrame] forKey:NSViewAnimationEndFrameKey];
        
        
		
        NSMutableDictionary *expandInspectorAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [expandInspectorAnimationDict setObject: viewToToggle forKey:NSViewAnimationTargetKey];
		
        NSRect newInspectorFrame = viewToToggle.frame;
        newInspectorFrame.size.width = lastWidth;
        //newInspectorFrame.origin.x = self.splitView.frame.size.width - lastWidth;
        newInspectorFrame.origin.x = 0.0f;
        [expandInspectorAnimationDict setObject:[NSValue valueWithRect:newInspectorFrame] forKey:NSViewAnimationEndFrameKey];
		
        NSViewAnimation *expandAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects: expandMiddleAnimationDict, expandInspectorAnimationDict, nil]];
        
        [expandAnimation setDuration:0.25f];
        [expandAnimation startAnimation];
        //[self.splitView setPosition: lastWidth ofDividerAtIndex: 0];
        [viewToToggle setHidden: NO];
		
    }
	else {
        // Collapse left view
        // Store last width so we can jump back
        lastLeftColumnWidth = viewToToggle.frame.size.width;
		
        NSMutableDictionary *collapseMainAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [collapseMainAnimationDict setObject:self.mainView forKey:NSViewAnimationTargetKey];
		
        NSRect newMainFrame = self.mainView.frame;
        newMainFrame.size.width =  self.splitView.frame.size.width;
        [collapseMainAnimationDict setObject:[NSValue valueWithRect:newMainFrame] forKey:NSViewAnimationEndFrameKey];
        
        
        NSMutableDictionary *collapseCenterAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [collapseCenterAnimationDict setObject: self.middleColumn forKey: NSViewAnimationTargetKey];
        NSRect newCenterFrame = self.middleColumn.frame;
        
        
        newCenterFrame.size.width = newCenterFrame.size.width + lastLeftColumnWidth;
        newCenterFrame.origin.x = 0.0f;
        [collapseCenterAnimationDict setObject: [NSValue valueWithRect: newCenterFrame] forKey: NSViewAnimationEndFrameKey];
        
		
        NSMutableDictionary *collapseViewToToggleAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [collapseViewToToggleAnimationDict setObject:viewToToggle forKey:NSViewAnimationTargetKey];
        NSRect newInspectorFrame = viewToToggle.frame;
        newInspectorFrame.size.width = 0.0f;
        //newInspectorFrame.origin.x = self.splitView.frame.size.width;
        newInspectorFrame.origin.x = 0.0f;
        [collapseViewToToggleAnimationDict setObject:[NSValue valueWithRect:newInspectorFrame] forKey:NSViewAnimationEndFrameKey];
        
		
        NSViewAnimation *collapseAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:collapseCenterAnimationDict, collapseViewToToggleAnimationDict, nil]];
        [collapseAnimation setDuration:0.25f];
        [collapseAnimation startAnimation];
        
        
        [self.middleColumn setNeedsDisplay: YES];
        [viewToToggle setHidden: YES];
    }
    
    [self.splitView adjustSubviews];

}

*/

-(IBAction)toggleRightView:(id)sender;
{
    DLog(@"CALLED - toggleRightView");
    BOOL rightViewCollapsed = [self.splitView isSubviewCollapsed:[[self.splitView subviews] objectAtIndex: 2]];
    
    if (rightViewCollapsed) {
        [self uncollapseRightView];
    } else {
        [self collapseRightView];
    }
}


-(void)collapseRightView
{
    DLog(@"CALLED - collapseRightView");
    NSView *right = self.rightColumn;
    NSView *middle = self.middleColumn;
    NSView *left = self.leftColumn;
    
    lastRightColumnWidth    = right.frame.size.width;
    lastMiddleColumnWidth   = middle.frame.size.width;
    lastLeftColumnWidth     = left.frame.size.width;

    
    NSRect middleFrame = [middle frame];
    middleFrame.size.width += right.frame.size.width;
    
    [right setHidden: YES];
    [middle setFrameSize: NSMakeSize(middleFrame.size.width, middleFrame.size.height)];
    
    CGFloat dividerPosition = [self.splitView dividerThickness] + self.splitView.frame.size.width;
    
    [self.splitView setPosition: dividerPosition ofDividerAtIndex: 1];
    
    [self.splitView display];
    DLog(@"collapseRightView: isHidden = %i", right.isHidden);
    
}

-(void)uncollapseRightView
{
    DLog(@"CALLED - uncollapseRightView");
    NSView *right = self.rightColumn;
    NSView *middle = self.middleColumn;
    NSView *left = self.leftColumn;
    
    [self.rightColumn setHidden:NO];
    
    CGFloat dividerThickness = [[self splitView] dividerThickness];
    // get the different frames
    NSRect leftFrame    = [left frame];
    NSRect middleFrame  = [middle frame];
    NSRect rightFrame   = [right frame];
    
    // Adjust left frame size
    //leftFrame.size.width = (leftFrame.size.width - rightFrame.size.width-dividerThickness);
    
     middleFrame.size.width = (middleFrame.size.width - rightFrame.size.width - dividerThickness);
    
    rightFrame.origin.x = leftFrame.size.width + middleFrame.size.width + dividerThickness;
    
    //[left setFrameSize:leftFrame.size];
    [middle setFrameSize: middleFrame.size];
    [right setFrame:rightFrame];
    
    [self.splitView setPosition: (self.splitView.frame.size.width - lastRightColumnWidth) ofDividerAtIndex: 1];
    
    [self.splitView display];
    [self.splitView setNeedsLayout: YES];
    [self.splitView setNeedsDisplay: YES];
    [self.middleColumn setNeedsDisplay: YES];
    [self.middleColumn setNeedsLayout: YES];
}


-(IBAction)toggleLeftColumn:(id)sender;
{
    BOOL leftViewCollapsed = [self.splitView isSubviewCollapsed: self.leftColumn];
    
    if (leftViewCollapsed) {
        [self uncollapseLeftView];
    } else {
        [self collapseLeftView];
    }
}


-(void)collapseLeftView
{
    NSView *right = self.rightColumn;
    NSView *middle = self.middleColumn;
    NSView *left = self.leftColumn;
    
    
    lastRightColumnWidth    = right.frame.size.width;
    lastMiddleColumnWidth   = middle.frame.size.width;
    lastLeftColumnWidth     = left.frame.size.width;
     
    
    
    NSRect middleFrame = [middle frame];
    middleFrame.size.width += left.frame.size.width;
    
    [left setHidden:YES];
    [middle setFrameSize: NSMakeSize(middleFrame.size.width, middleFrame.size.height)];
    
    
    [self.splitView setPosition: 0.0f ofDividerAtIndex: 1];
    
    [self.splitView display];
    
}

-(void)uncollapseLeftView
{
    NSView *right = self.rightColumn;
    NSView *middle = self.middleColumn;
    NSView *left = self.leftColumn;
    
    [self.rightColumn setHidden:NO];
    
    CGFloat dividerThickness = [[self splitView] dividerThickness];
    // get the different frames
    NSRect leftFrame    = [left frame];
    NSRect middleFrame  = [middle frame];
    NSRect rightFrame   = [right frame];
    
    // Adjust left frame size
    //leftFrame.size.width = (leftFrame.size.width - rightFrame.size.width-dividerThickness);
    middleFrame.size.width = (middleFrame.size.width - rightFrame.size.width - dividerThickness);
    rightFrame.origin.x = leftFrame.size.width + middleFrame.size.width + dividerThickness;
    //[left setFrameSize:leftFrame.size];
    [middle setFrameSize: middleFrame.size];
    [right setFrame:rightFrame];
    
    [self.splitView setPosition: (self.splitView.frame.size.width - lastRightColumnWidth) ofDividerAtIndex: 1];
    
    [self.splitView display];
    [self.splitView setNeedsLayout: YES];
    [self.splitView setNeedsDisplay: YES];
    [self.middleColumn setNeedsDisplay: YES];
    [self.middleColumn setNeedsLayout: YES];
}




- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    BOOL result = NO;
	BOOL subviewIsMember = (subview == self.leftColumn) || (subview == self.rightColumn);
	
    if (splitView == self.splitView && subviewIsMember) {
        result = YES;
    }
    /*
    lastRightColumnWidth    = self.rightColumn.frame.size.width;
    lastMiddleColumnWidth   = self.middleColumn.frame.size.width;
    lastLeftColumnWidth     = self.leftColumn.frame.size.width;
     */
    
    //DLog(@"shouldCollapse %@  = %i", subview.identifier, subviewIsMember);
    
    // TEST
    return YES;
    
    return result;
}



- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    BOOL result = NO;
	BOOL subviewIsMember = (subview == self.leftColumn) || (subview == self.rightColumn);
    if (splitView == self.splitView && subviewIsMember) {
        result = YES;
    }
    
    
    return result;
}


- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex;
{
    BOOL isCollapsed = NO;
    /*
    DLog(@"dividerIndex = %lu", dividerIndex);
    DLog(@"leftColumn.isHidden = %i", self.leftColumn.isHidden);
    DLog(@"rightColumn.isHidden = %i", self.rightColumn.isHidden);
     */
    
    if (dividerIndex == 0) {
        isCollapsed = self.rightColumn.isHidden;
        }
    else if (dividerIndex == 1) {
        isCollapsed = self.leftColumn.isHidden;
    }
    
    //DLog(@"isCollapsed = %i", isCollapsed);
    
    return isCollapsed;
    
    //return NO;
}


@end
