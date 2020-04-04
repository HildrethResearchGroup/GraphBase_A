//
//  HNTextFieldLabel.m
//  GraphBase_A
//
//  Created by Owen on 4/10/13.
//  Copyright (c) 2013 Owen Hildreth. All rights reserved.
//

#import "HNTextFieldLabel.h"

@implementation HNTextFieldLabel


-(NSSize)intrinsicContentSize
{
    if ( ![self.cell wraps] ) {
        return [super intrinsicContentSize];
    }
    
    
    NSRect newFrame = [self frameWithWidth: self.frame.size.width];
    return newFrame.size;
}

-(void) sizeToFit {
    
    // Get current frame
    NSRect localFrame = [self frame];
    
    // Keep width constant but have height fit the contents
    //localFrame.size = [self sizeWithWidth: localFrame.size.width];
    
    localFrame = [self frameWithWidth: localFrame.size.width];
    
    [self setFrame: localFrame];
    [self setNeedsDisplay: YES];
}


-(NSRect) frameWithWidth: (float) width {
    NSRect localFrame = [self frame];
    CGFloat originalHeight = self.frame.size.height;    // Store original frame height
    
    // Make the frame very high, while keeping the width
    localFrame.size.height = CGFLOAT_MAX;
    
    // Calculate new height within the frame
    // with practically infinite height.
    CGFloat newHeight = [self.cell cellSizeForBounds: localFrame].height;
    localFrame.size.height = newHeight;
    
    CGFloat difference = originalHeight - newHeight;
    
    localFrame.origin.y = localFrame.origin.y + difference;
    
    
    return localFrame;
}

@end
