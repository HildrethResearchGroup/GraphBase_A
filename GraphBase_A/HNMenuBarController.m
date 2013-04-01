//
//  HNMenuBarController.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/20/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "HNMenuBarController.h"
#import "HNNSNotificationStrings.h"

@implementation HNMenuBarController


#pragma mark -
#pragma mark Adding Items
-(IBAction) addDataItems:(id)sender {
	NSString *notificationType = HNAddDataFilesNotification;
	NSDictionary *userInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
	
}



-(IBAction) addGraphTemplates:(id)sender {
	NSString *notificationType = HNAddGraphTemplateNotification;
	NSDictionary *userInfo = @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
}



-(IBAction) newParseTemplate:(id)sender {
	NSString *notificationType = HNAddParseTemplateNotification;
	NSDictionary *userInfo = [NSDictionary dictionary];
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
}


-(IBAction) newProject:(id)sender {
	NSString *notificationType = HNAddCollectionNotification;
	NSDictionary *userInfo = @{HNCollectionOfType : HNProjectCollectionType };
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
}


-(IBAction) newExperiment:(id)sender {
	NSString *notificationType = HNAddCollectionNotification;
	NSDictionary *userInfo = @{HNCollectionOfType : HNExperimentCollectionType };
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
}

-(IBAction) newFolder:(id)sender {
	NSString *notificationType = HNAddCollectionNotification;
	NSDictionary *userInfo = @{HNCollectionOfType : HNFolderCollectionType };
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
}


-(IBAction) addWatchedFolder:(id)sender {
	NSString *notificationType	= HNAddWatchedFoldersNotification;
	NSDictionary *userInfo		= @{HNaddFilesFrom : HNAddFilesFromNSOpenPanel};
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
}



-(void) postNewAddOrRemoveNotificationOfType: (NSString *)notificationName withDetails: (NSDictionary *) userInfo {
	
	if (!notificationName) {
		return;
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName: notificationName
					  object: self
					userInfo: userInfo];
}



#pragma mark -
#pragma mark Removing Items
-(IBAction) removeDataItems:(id)sender {
	NSString *notificationType	= HNRemoveDataFilesNotification;
	NSDictionary *userInfo		= [NSDictionary dictionary];
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
}

-(IBAction) removeGraphTemplates:(id)sender {
	NSString *notificationType	= HNRemoveGraphTemplateNotification;
	NSDictionary *userInfo		= [NSDictionary dictionary];
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
	
}
-(IBAction) removeParseTemplate:(id)sender {
	NSString *notificationType	= HNRemoveParseTemplateNotification;
	NSDictionary *userInfo		= [NSDictionary dictionary];
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
	
}
-(IBAction) removeCollection: (id) sender {
	NSString *notificationType	= HNRemoveCollectionNotification;
	NSDictionary *userInfo		= [NSDictionary dictionary];
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
	
}
-(IBAction) removeWatchedFolder:(id)sender {
	NSString *notificationType	=  HNRemoveWatchedFolderNotification;
	NSDictionary *userInfo		= [NSDictionary dictionary];
	
	[self postNewAddOrRemoveNotificationOfType: notificationType
								   withDetails: userInfo];
	
}



@end
