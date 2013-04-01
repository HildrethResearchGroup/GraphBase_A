//
//  HNMenuBarController.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/20/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNMenuBarController : NSObject {
}


#pragma mark -
#pragma mark Adding Items
-(IBAction) addDataItems:(id)sender;
-(IBAction) addGraphTemplates:(id)sender;
-(IBAction) newParseTemplate:(id)sender;
-(IBAction) newProject:(id)sender;
-(IBAction) newExperiment:(id)sender;
-(IBAction) newFolder:(id)sender;
-(IBAction) addWatchedFolder:(id)sender;


#pragma mark -
#pragma mark Removing Items
-(IBAction) removeDataItems:(id)sender;
-(IBAction) removeGraphTemplates:(id)sender;
-(IBAction) removeParseTemplate:(id)sender;
-(IBAction) removeCollection: (id) sender;
-(IBAction) removeWatchedFolder:(id)sender;

@end
