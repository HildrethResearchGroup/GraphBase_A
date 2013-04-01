//
//  HNAppDelegateAsDataSource.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 8/30/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@class HNTreeController;

@protocol HNAppDelegateAsDataSource

@required
// TreeControllers
-(HNTreeController *)  treeControllerFromSource;

// ArrayControllers
-(NSArrayController *) dataItemsArrayControllerFromSource;

-(NSArrayController *) graphTemplateListArrayControllerFromSource;
-(NSArrayController *) allGraphTemplateListArrayControllerFromSource;

-(NSArrayController *) allParserListArrayControllerFromSource;
-(NSArrayController *) parseTemplateListArrayControllerFromSource;

//-(NSURL *) applicationFilesDirectoryFromSource;



@end
