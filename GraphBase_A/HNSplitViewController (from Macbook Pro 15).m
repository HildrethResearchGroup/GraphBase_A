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


-(IBAction) toggleLeftColumn:(id)sender {
	[self toggleView: self.leftColumn
		   withWidth: lastLeftColumnWidth];
}


-(IBAction) toggleRightColumn:(id)sender {
	[self toggleView: self.rightColumn
		   withWidth:lastRightColumnWidth];
	if ( [self.rightColumn respondsToSelector: @selector(layoutSubviews)] ) {
		[self.rightColumn performSelector: @selector(layoutSubviews)];
	}
	
}

-(void) toggleView:(NSView *) viewToToggle withWidth:(CGFloat) lastWidth {
	NSLog(@"lastWidth = %f", lastWidth);
	
	
	if ([self.splitView isSubviewCollapsed: viewToToggle]) {
		// viewToToggle is collapsed -> expand viewToToggle
        // NSSplitView hides the collapsed subview
        viewToToggle.hidden = NO;
		
        NSMutableDictionary *expandMainAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
		/*
        [expandMainAnimationDict setObject:self.mainView forKey:NSViewAnimationTargetKey];
		
        NSRect newMainFrame = self.mainView.frame;
		
        newMainFrame.size.width =  self.splitView.frame.size.width - lastWidth;
		 */
		
		[expandMainAnimationDict setObject:self.middleColumn forKey:NSViewAnimationTargetKey];
		
        NSRect newMainFrame = self.middleColumn.frame;
		
        newMainFrame.size.width =  self.splitView.frame.size.width - lastWidth;
		
        [expandMainAnimationDict setObject:[NSValue valueWithRect:newMainFrame] forKey:NSViewAnimationEndFrameKey];
		
        NSMutableDictionary *expandInspectorAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [expandInspectorAnimationDict setObject: viewToToggle forKey:NSViewAnimationTargetKey];
		
        NSRect newInspectorFrame = viewToToggle.frame;
        newInspectorFrame.size.width = lastWidth;
		
		if (viewToToggle == self.leftColumn) {
			newInspectorFrame.origin.x = self.splitView.frame.origin.x;
		}
		else if (viewToToggle == self.rightColumn) {
			newInspectorFrame.origin.x = self.splitView.frame.size.width - lastWidth;
		}
		
        //newInspectorFrame.origin.x = self.splitView.frame.size.width - lastWidth;
        [expandInspectorAnimationDict setObject:[NSValue valueWithRect:newInspectorFrame] forKey:NSViewAnimationEndFrameKey];
		
        NSViewAnimation *expandAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:expandMainAnimationDict, expandInspectorAnimationDict, nil]];
        [expandAnimation setDuration:0.25f];
        [expandAnimation startAnimation];
		
    }
	else {
        // Store last width so we can jump back
		if (viewToToggle == self.leftColumn) {
			lastLeftColumnWidth = viewToToggle.frame.size.width;
		}
		else if (viewToToggle == self.rightColumn) {
			lastRightColumnWidth = viewToToggle.frame.size.width;
		}
        //lastWidth = viewToToggle.frame.size.width;
		
        NSMutableDictionary *collapseMainAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [collapseMainAnimationDict setObject:self.mainView forKey:NSViewAnimationTargetKey];
		
        NSRect newMainFrame = self.mainView.frame;
        newMainFrame.size.width =  self.splitView.frame.size.width;
        [collapseMainAnimationDict setObject:[NSValue valueWithRect:newMainFrame] forKey:NSViewAnimationEndFrameKey];
		
        NSMutableDictionary *collapseInspectorAnimationDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [collapseInspectorAnimationDict setObject:viewToToggle forKey:NSViewAnimationTargetKey];
		
        NSRect newInspectorFrame = viewToToggle.frame;
        newInspectorFrame.size.width = 0.0f;
		
		if (viewToToggle == self.leftColumn) {
			newInspectorFrame.origin.x = self.splitView.frame.origin.x;
		}
		else {
			newInspectorFrame.origin.x = self.splitView.frame.size.width;
		}

        [collapseInspectorAnimationDict setObject:[NSValue valueWithRect:newInspectorFrame] forKey:NSViewAnimationEndFrameKey];
		
        NSViewAnimation *collapseAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:collapseMainAnimationDict, collapseInspectorAnimationDict, nil]];
        [collapseAnimation setDuration:0.25f];
        [collapseAnimation startAnimation];
    }
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    BOOL result = NO;
	BOOL subviewIsMember = (subview == self.leftColumn) || (subview == self.rightColumn);
	
    if (splitView == self.splitView && subviewIsMember) {
        result = YES;
    }
	
	
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
    //NSLog(@"%@:%s returning YES",[self class], _cmd);
    return NO;
}


@end
