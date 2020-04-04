//
//  HNDataItem.m
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/8/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import "PreCompiledHeaders.h"
#import "HNDataItem.h"
#import "HNGraphTemplate.h"
#import "HNParseTemplate.h"
#import "HNTreeNode.h"
#define makeFullDGRange DGMakeRange(-INFINITY, INFINITY);

NSString * const HNPropertyListFileName		= @"DataPropertyList.xml";

// DIP stands for DataItemProperty
NSString * const HNDIP_DGRangeCrop	= @"HNDIP_DGRangeCrop";
NSString * const HNDIP_maxValue		= @"HNDIP_maxValue";
NSString * const HNDIP_minValue		= @"HNDIP_minValue";



@implementation HNDataItem

@dynamic dateFileImported;
@dynamic dateFileLastModified;
@dynamic dateFileLastParsed;
@dynamic dateLocalizedResourceLastModified;
@dynamic displayName;
@dynamic experimentalDetailsFromHeader;
@dynamic experimentalNotes;
@dynamic fileName;
@dynamic filePath;
@dynamic localizedResourcePath;
@dynamic storedUUID;

@dynamic graphTemplate;
@dynamic parseTemplate;
@dynamic treeNode;

@synthesize propertyList = _propertyList;



-(void) awakeFromInsert {
	// Set initial dates
	[self setDateFileImported:      [NSDate date]];
    [self setDateFileLastModified:  [NSDate date]];
	NSString *UUID = [[NSProcessInfo processInfo] globallyUniqueString];
	[self setStoredUUID: UUID];
}


-(void) prepareForDeletion {
	//DLog(@"CALLED - HNDataItem: prepareForDeletion");
	// Remove any data files
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *directoryPath = self.localizedResourcePath;
	//DLog(@"localizedResourcePath = %@", directoryPath);
	BOOL isDirectory;
	if ([fm fileExistsAtPath: directoryPath isDirectory:&isDirectory]) {
		if (isDirectory) {
			//DLog(@"REMOVE DIRECTORY");
			NSError *error;
			
			[fm removeItemAtPath: directoryPath error:&error];
			if (error) {
				DLog(@"ERROR deleting Data Item Support Folder %@", error);
			}
			
		}
		else {
			DLog(@"%@ IS NOT a DIRECTORY", directoryPath);
		}
	}
    
    // Check parent directory to see if it needs to be removed
}




-(NSString *) fileName {
	
	/*
	if ([self fileExistsYesNo] == NO) {
        return [self fileDoesNotExistAlert];
    }
	 */
	
    return [[self filePath] lastPathComponent];
}


-(NSString *) applicationSupportLocalDataFileName {
	NSString *localDataFileName;
	NSString *dataFileName = self.fileName;
	dataFileName = [dataFileName stringByDeletingPathExtension];
	if (dataFileName) {
		localDataFileName = [@"Local - " stringByAppendingString:dataFileName];
		localDataFileName = [localDataFileName stringByAppendingPathExtension: @"dgraph"];
	}
	else {
		localDataFileName = @"Configured Data.dgraph";
	}
	//DLog(@"applicationSupportLocalDataFileName = %@", localDataFileName);
	return [localDataFileName copy];
}



-(NSMutableDictionary *) propertyList {
	if (!_propertyList) {
		_propertyList = [self _propertyListFromLocalizedResourcePath];
	}
	
	return _propertyList;
}


#pragma mark -
#pragma mark File Exists Responses
-(BOOL) fileExistsYesNo {
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if ([fm fileExistsAtPath: self.filePath]) {
		return YES;
	}
	else {
		return NO;
	}
}

-(NSColor *) fileExistsTextColor {
	// Return Black if file exists
	//        Red if file does not exist

	BOOL fileExists = [self fileExistsYesNo];
	
	if (fileExists) {
		return [NSColor blackColor];
	}
	else {
		return [NSColor redColor];
	}
}


-(NSString *) fileDoesNotExistAlert {
	return  @"File not found!";
}

-(BOOL) fileHasChanged {
	BOOL fileHasChanged = NO;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSError *error = nil;
	NSDictionary *fileAttributes = [fm attributesOfItemAtPath: self.filePath error:&error];
	
	if (!error) {
		NSDate *fileModificationDate = [fileAttributes objectForKey: NSFileModificationDate];
		if ( ![self.dateFileLastModified isEqualToDate: fileModificationDate]) {
			fileHasChanged = YES;
			[self setDateFileLastModified: fileModificationDate];
		}
	}
	return fileHasChanged;
}

#pragma mark -
#pragma mark Set Default Methods
-(BOOL) setDefaultsFromParent {
	BOOL status = YES;
	
	// check to make sure parent tree node exists
	if (![self treeNode]) {
		status = NO;
		return status;
	}
	
	[self _setDefaultsFromTreeNode: [self treeNode]];
	
	return status;
}





-(void) _setDefaultsFromTreeNode: (HNTreeNode *) treeNodeIn {
    [self setGraphTemplate:     [treeNodeIn defaultGraphTemplate]];
    [self setParseTemplate:     [treeNodeIn defaultParseTemplate]];
}


-(BOOL) setLocalizedResourcePathFrom: (NSURL *) applicationSupportFolder {
	DLog(@"CALLED - HNDataItem: setLocalizedResourcePathFrom");
	NSURL *resourcePath = applicationSupportFolder;
	resourcePath = [resourcePath URLByAppendingPathComponent: @"Data" isDirectory:YES];
	BOOL success = YES;
	
	
	// Create directory structure as: Data/year/month/fileName - objectId
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDate *date;
	if ([fm fileExistsAtPath: self.filePath isDirectory: nil]) {
		NSDictionary *fileAttributes = [fm attributesOfItemAtPath: self.filePath error: nil];
		date = [fileAttributes objectForKey: NSFileCreationDate];
	}
	else {
		date = [NSDate date];
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit  | NSMonthCalendarUnit) fromDate: date];
    
	NSString *year = [NSString stringWithFormat: @"%ld", [dateComponents year]];
	NSString *month = [NSString stringWithFormat: @"%02li", [dateComponents month]];
	
	resourcePath = [[resourcePath URLByAppendingPathComponent: year isDirectory:YES] URLByAppendingPathComponent: month isDirectory: YES];
	NSString * shortFileName = [[self fileName] stringByDeletingPathExtension];
	
	//NSString *uniqueIDString = [NSString stringWithFormat: @"%@ - %@", shortFileName, [self objectID]];
	NSString *UUID = [self storedUUID];
	if (!UUID) {
		UUID = [[NSProcessInfo processInfo] globallyUniqueString];
	}
	NSString *uniqueIDString = [NSString stringWithFormat: @"%@ - %@", shortFileName, UUID];
	
	resourcePath = [resourcePath URLByAppendingPathComponent: uniqueIDString isDirectory:YES];
	
	NSError *error = nil;
	// Create directory if it does not exist
	
	
	BOOL isDir = YES;
	if ( ![fm fileExistsAtPath: [resourcePath path] isDirectory: &isDir]) {
		BOOL success = [fm createDirectoryAtURL: resourcePath
							withIntermediateDirectories: YES
											 attributes: nil
												  error: &error];
		
		if (success) {
			//[self setValue: [resourcePath relativePath] forKey: @"localizedResourcePath"];
			[self setLocalizedResourcePath: [resourcePath relativePath]];
		}
		else {
			success = NO;
			return success;
		}
	}
	
	else {
		//[self setValue: [resourcePath relativePath] forKey: @"localizedResourcePath"];
		[self setLocalizedResourcePath: [resourcePath relativePath]];
	}
	
	DLog(@"localizedResourcePath = %@", self.localizedResourcePath);
	return success;
}

-(void) setDefaultCropRange {
	DGRange fullRange = makeFullDGRange;
	
	// CHANGED
	/*
	NSDictionary *rangeDictionary = @{HNDIP_minValue : [NSNumber numberWithDouble: fullRange.minV], HNDIP_maxValue : [NSNumber numberWithDouble: fullRange.maxV]};
	 */
	
	[self quickCropRangeToPropertyList: fullRange];
	
	//[self setPropertyListValue: rangeDictionary forKey:HNDIP_DGRangeCrop];
}







#pragma mark -
#pragma mark Property Lists


-(NSMutableDictionary *) _propertyListFromLocalizedResourcePath {
	DLog(@"CALLED - HNDataItem: _propertyListFromLocalizedResourcePath");
	NSMutableDictionary *localPropertyList;
	
	// Check to make sure localizedResourcePath exists
	if (!self.localizedResourcePath) {
		DLog(@"NO localized Resource Path");
		DLog(@"%@", self.localizedResourcePath);
		[self setLocalizedResourcePathFrom: [[NSApplication sharedApplication] applicationFilesDirectory]];
	}
	
	// Check to see if propertyList has been made yet
	NSFileManager *fm = [NSFileManager defaultManager];
	//NSURL *propertyListURL = [NSURL URLWithString: HNPropertyListFileName relativeToURL: [NSURL URLWithString: self.localizedResourcePath]];
	
	NSString *propertyListPath = [self.localizedResourcePath stringByAppendingPathComponent: HNPropertyListFileName];
	
	if (![fm fileExistsAtPath: propertyListPath] ) {
		DLog(@"propertyList does not exist");
		// No property list has been made yet
		// Create empty dictionary and save
		//localPropertyList = [NSMutableDictionary dictionaryWithDictionary: @{@"Root Object" : [NSNumber numberWithBool: YES]}];
		localPropertyList = [NSMutableDictionary dictionary];
		
		NSData *xmlData;
		NSString *error;
		
		xmlData = [NSPropertyListSerialization dataFromPropertyList: localPropertyList
															 format: NSPropertyListXMLFormat_v1_0
												   errorDescription: &error];
        
		
		if (xmlData) {
			[xmlData writeToFile: propertyListPath atomically: YES];
		}
		else {
            DLog(@"%@", error);
		}
		
		return localPropertyList;
	}
	
	// Get propertyList from file
	NSError *error;
	NSData *plistData = [NSData dataWithContentsOfFile: propertyListPath
											   options: NSDataReadingMappedAlways
												 error: &error];
	
	if (error) {
		return localPropertyList;
	}
	NSPropertyListFormat format;
	NSString *propertyListError;
	localPropertyList = [NSPropertyListSerialization propertyListFromData: plistData
														 mutabilityOption: NSPropertyListMutableContainersAndLeaves
																   format: &format
														 errorDescription: &propertyListError];
	
	if (!localPropertyList) {
		DLog(@"%@", propertyListError);
	}
	
	return localPropertyList;
}




-(id) propertyListValueForKey: (NSString *) key {
	NSMutableDictionary *localPropertyList = [self propertyList];
	
	id object = [localPropertyList valueForKey: key];
	
	return object;
}




-(BOOL) setPropertyListValue: (id)value forKey: (NSString *)key {
	DLog(@"CALLED - HNDataItem: setPropertyListValue");
	NSMutableDictionary *localPropertyList = [self propertyList];
	
	[localPropertyList setValue: value forKey: key];
	
	//DLog(@"%@", localPropertyList);
	
	
	// Update Saved Property List
	NSString *propertyListPath = [self.localizedResourcePath stringByAppendingPathComponent: HNPropertyListFileName];
	//NSURL *propertyListURL = [NSURL URLWithString: HNPropertyListFileName relativeToURL: [NSURL URLWithString: self.localizedResourcePath]];
	NSData *xmlData;
	NSString *error;
	
	xmlData = [NSPropertyListSerialization dataFromPropertyList:localPropertyList
														 format:NSPropertyListXMLFormat_v1_0
											   errorDescription: &error];
	
	if (xmlData) {
		[xmlData writeToFile: propertyListPath atomically: YES];
		return YES;
	}
	
	else {
        DLog(@"%@", error);
		return NO;
	}
}

#pragma mark -
#pragma mark Quick Access Property Lists
-(void) quickCropRangeToPropertyList: (DGRange) range {
	
	NSDictionary *rangeDictionary = @{HNDIP_minValue : [NSNumber numberWithDouble: range.minV], HNDIP_maxValue : [NSNumber numberWithDouble: range.maxV]};
	
	[self setPropertyListValue: rangeDictionary forKey:HNDIP_DGRangeCrop];
}


-(DGRange) quickCropRangeFromPropertyList {
	DGRange cropRange;
	NSDictionary *cropRangeDictionary = [self propertyListValueForKey: HNDIP_DGRangeCrop];
	
	if (cropRangeDictionary) {
		cropRange.minV = [[cropRangeDictionary valueForKey: HNDIP_minValue] doubleValue];
		cropRange.maxV = [[cropRangeDictionary valueForKey: HNDIP_maxValue] doubleValue];
	}
	
	return cropRange;
}


@end
