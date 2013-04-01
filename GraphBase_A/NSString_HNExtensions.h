//
//  NSString_HNExtensions.h
//  GraphBase_A
//
//  Created by Owen Hildreth on 9/4/12.
//  Copyright (c) 2012 Owen Hildreth. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (HNExtensions)
-(NSString *) propertyKeyPathFromIdentifier: (NSString *) indentifierString;

@end

@implementation NSString (HNExtensions)

-(NSArray *) separateIdentifierComponents: (NSString *) indentifierString {
	// identifier string is set as selector<objectClass<detail1<detail2 ...

    NSString *separatorString = @"<";
	NSArray *identifierComponents = [indentifierString componentsSeparatedByString: separatorString];
	
	return identifierComponents;
}

-(NSString *) propertyKeyPathFromIdentifier: (NSString *) indentifierString {
	// strips "<objectClass" from identifier to leave behind selector
	
	NSArray *identifierComponents = [self separateIdentifierComponents: indentifierString];
	
	if ([identifierComponents count] >= 1) {
		return [identifierComponents objectAtIndex: 0];
	}
	
	return nil;;
}

-(NSString *) entityNameFromIdentifier: (NSString *) indentifierString {
	NSArray *identifierComponents = [self separateIdentifierComponents: indentifierString];
	
	if ([identifierComponents count] >= 2) {
		return [identifierComponents objectAtIndex: 1];
	}
	
	return nil;

}

@end
