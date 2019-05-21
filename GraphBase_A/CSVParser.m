//
//  CSVParser.m
//  CSVImporter
//
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "CSVParser.h"


@implementation CSVParser

@synthesize fieldNames;

//
// initWithString:separator:hasHeader:fieldNames:
//
// Parameters:
//    aCSVString - the string that will be parsed
//    aSeparatorString - the separator (normally "," or "\t")
//    header - if YES, treats the first row as a list of field names
//    names - a list of field names (will have no effect if header is YES)
//
// returns the initialized object (nil on failure)
//
- (id)initWithString:(NSString *)aCSVString
    separator:(NSString *)aSeparatorString
    hasHeader:(BOOL)header
    fieldNames:(NSArray *)names
{
    DLog(@"CALLED - CSVParser: initWithString");

	self = [super init];
	if (self)
	{
		csvString = aCSVString;
		separator = aSeparatorString ;
		
		NSAssert([separator length] > 0 &&
			[separator rangeOfString:@"\""].location == NSNotFound &&
			[separator rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound,
			@"CSV separator string must not be empty and must not contain the double quote character or newline characters.");
		
		NSMutableCharacterSet *endTextMutableCharacterSet =
			[[NSCharacterSet newlineCharacterSet] mutableCopy];
		[endTextMutableCharacterSet addCharactersInString:@"\""];
		[endTextMutableCharacterSet addCharactersInString:[separator substringToIndex:1]];
		endTextCharacterSet = endTextMutableCharacterSet;

		if ([separator length] == 1)
		{
			separatorIsSingleChar = YES;
		}
        
        DLog(@"csvString = %@", csvString);


		hasHeader = header;
		fieldNames = [names mutableCopy];
	}
    
    //DLog(@"separator = %@", separator);

	
	return self;
}

//
// dealloc
//
// Releases instance memory.
//



//
// arrayOfParsedRows
//
// Performs a parsing of the csvString, returning the entire result.
//
// returns the array of all parsed row records
//
- (NSArray *)arrayOfParsedRows
{
    DLog(@"CALLED - CSVParser: arrayOfParsedRows");

	scanner = [[NSScanner alloc] initWithString:csvString];
	[scanner setCharactersToBeSkipped:[[[NSCharacterSet alloc] init] autorelease]];
	
	NSArray *result = [self parseFile];
	[scanner release];
	scanner = nil;
	
	return result;
}

//
// parseRowsForReceiver:selector:
//
// Performs a parsing of the csvString, sending the entries, 1 row at a time,
// to the receiver.
//
// Parameters:
//    aReceiver - the target that will receive each row as it is parsed
//    aSelector - the selector that will receive each row as it is parsed
//		(should be a method that takes a single NSDictionary argument)
//
- (NSArray *)parseRowsForReceiver:(id)aReceiver selector:(SEL)aSelector
{
    DLog(@"CALLED - CSVParser: parseRowsForReceiver");

	scanner = [[NSScanner alloc] initWithString:csvString];
	[scanner setCharactersToBeSkipped:[[[NSCharacterSet alloc] init] autorelease]];
	receiver = [aReceiver retain];
	receiverSelector = aSelector;
	
    NSArray *parsedFile = [self parseFile];
	
	[scanner release];
	scanner = nil;
	[receiver release];
	receiver = nil;
    
    return parsedFile;
}

//
// parseFile
//
// Attempts to parse a file from the current scan location.
//
// returns the parsed results if successful and receiver is nil, otherwise
//	returns nil when done or on failure.
//
- (NSArray *)parseFile
{
    DLog(@"CALLED - CSVParser: parseFile");

	if (hasHeader)
	{
        DLog(@"has header = %i", hasHeader);
		if (fieldNames)
		{
			[fieldNames release];
		}
		
        // If it has a header, then get the fieldNames from the file and store in an NSMutableArray
		fieldNames = [[self parseHeader] retain];
		if (!fieldNames || ![self parseLineSeparator])
		{
            DLog(@"!fieldNames and ![self parseLineSeparator");
			return nil;
		}
	}
	
    // Create pointer to NSMutableArrya to hold records
	NSMutableArray *records = nil;
	if (!receiver)
	{
        DLog(@"!reciever");
        // If not receiver object has been desiganted, point records to an empty NSMutable Array
		records = [NSMutableArray array];
	}
	
    // Create an NSDictionary to hold Arrays with the FieldName as the key.  If no FieldName then it will default to "#"
	NSDictionary *record = [[self parseRecord] retain];
    
	if (!record)
	{
        DLog(@"no record");

		return nil;
	}
	
    // For loop through each Field (NSDictionary record key) and either perform a selector on the reciever using receiverSelector and the record object or add the obect to an array
	while (record)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if (receiver)
		{
            //DLog(@"[receiver performSelector:receiverSelector withObject:record]");
			[receiver performSelector:receiverSelector withObject:record];
		}
		else
		{
			[records addObject:record];
		}
		[record release];
		
		if (![self parseLineSeparator])
		{
			break;
		}
		
		record = [[self parseRecord] retain];
		
		[pool drain];
	}
    
    DLog(@"records = %@", records);
    DLog(@"receiver = %@", receiver);
	return records;
}

//
// parseHeader
//
// Attempts to parse a header row from the current scan location.
//
// returns the array of parsed field names or nil on parse failure.
//
- (NSMutableArray *)parseHeader
{
	NSString *name = [self parseName];
	if (!name)
	{
		return nil;
	}

	NSMutableArray *names = [NSMutableArray array];
	while (name)
	{
		[names addObject:name];

		if (![self parseSeparator])
		{
			break;
		}
		
		name = [self parseName];
	}
	return names;
}

//
// parseRecord
//
// Attempts to parse a record from the current scan location. The record
// dictionary will use the fieldNames as keys, or FIELD_X for each column
// X-1 if no fieldName exists for a given column.
//
// returns the parsed record as a dictionary, or nil on failure. 
//
- (NSDictionary *)parseRecord
{
    DLog(@"CALLED - CSVParser: parseRecord");

	//
	// Special case: return nil if the line is blank. Without this special case,
	// it would parse as a single blank field.
	//
	if ([scanner isAtEnd]) {
        DLog(@"failed [scanner isAtEnd]");
		return nil;
	}
    if([self parseLineSeparator]) {
        DLog(@"failed [self parseLineSeparator]");
		//return nil;
    }
	
	NSString *field = [self parseField];
	if (!field)
	{
        DLog(@"parseRecord, !field");
		return nil;
	}

	NSInteger fieldNamesCount = [fieldNames count];
	NSInteger fieldCount = 0;
	
	NSMutableDictionary *record =
		[NSMutableDictionary dictionaryWithCapacity:[fieldNames count]];
	while (field)
	{
		NSString *fieldName;
		if (fieldNamesCount > fieldCount)
		{
			fieldName = [fieldNames objectAtIndex:fieldCount];
		}
		else
		{
			fieldName = [NSString stringWithFormat:@"%ld", fieldCount + 1];
			[fieldNames addObject:fieldName];
			fieldNamesCount++;
		}
		
		[record setObject:field forKey:fieldName];
		fieldCount++;

		if (![self parseSeparator])
		{
			break;
		}
		
		field = [self parseField];
	}

	return record;
}

//
// parseName
//
// Attempts to parse a name from the current scan location.
//
// returns the name or nil.
//
- (NSString *)parseName
{
	return [self parseField];
}

//
// parseField
//
// Attempts to parse a field from the current scan location.
//
// returns the field or nil
//
- (NSString *)parseField
{
	NSString *escapedString = [self parseEscaped];
	if (escapedString)
	{
		return escapedString;
	}
	
	NSString *nonEscapedString = [self parseNonEscaped];
	if (nonEscapedString)
	{
		return nonEscapedString;
	}
	
	//
	// Special case: if the current location is immediately
	// followed by a separator, then the field is a valid, empty string.
	//
	NSInteger currentLocation = [scanner scanLocation];
	if ([self parseSeparator] || [self parseLineSeparator] || [scanner isAtEnd])
	{
		[scanner setScanLocation:currentLocation];
		return @"";
	}

	return nil;
}

//
// parseEscaped
//
// Attempts to parse an escaped field value from the current scan location.
//
// returns the field value or nil.
//
- (NSString *)parseEscaped
{
	if (![self parseDoubleQuote])
	{
		return nil;
	}
	
	NSString *accumulatedData = [NSString string];
	while (YES)
	{
		NSString *fragment = [self parseTextData];
		if (!fragment)
		{
			fragment = [self parseSeparator];
			if (!fragment)
			{
				fragment = [self parseLineSeparator];
				if (!fragment)
				{
					if ([self parseTwoDoubleQuotes])
					{
						fragment = @"\"";
					}
					else
					{
						break;
					}
				}
			}
		}
		
		accumulatedData = [accumulatedData stringByAppendingString:fragment];
	}
	
	if (![self parseDoubleQuote])
	{
		return nil;
	}
	
	return accumulatedData;
}

//
// parseNonEscaped
//
// Attempts to parse a non-escaped field value from the current scan location.
//
// returns the field value or nil.
//
- (NSString *)parseNonEscaped
{
	return [self parseTextData];
}

//
// parseTwoDoubleQuotes
//
// Attempts to parse two double quotes from the current scan location.
//
// returns a string containing two double quotes or nil.
//
- (NSString *)parseTwoDoubleQuotes
{
	if ([scanner scanString:@"\"\"" intoString:NULL])
	{
		return @"\"\"";
	}
	return nil;
}

//
// parseDoubleQuote
//
// Attempts to parse a double quote from the current scan location.
//
// returns @"\"" or nil.
//
- (NSString *)parseDoubleQuote
{
	if ([scanner scanString:@"\"" intoString:NULL])
	{
		return @"\"";
	}
	return nil;
}

//
// parseSeparator
//
// Attempts to parse the separator string from the current scan location.
//
// returns the separator string or nil.
//
- (NSString *)parseSeparator
{
	if ([scanner scanString:separator intoString:NULL])
	{
		return separator;
	}
	return nil;
}

//
// parseLineSeparator
//
// Attempts to parse newline characters from the current scan location.
//
// returns a string containing one or more newline characters or nil.
//
- (NSString *)parseLineSeparator
{

	NSString *matchedNewlines = nil;
	[scanner
		scanCharactersFromSet:[NSCharacterSet newlineCharacterSet]
		intoString:&matchedNewlines];
    DLog(@"matchedNewLines = %@", matchedNewlines);
	return matchedNewlines;
}

//
// parseTextData
//
// Attempts to parse text data from the current scan location.
//
// returns a non-zero length string or nil.
//
- (NSString *)parseTextData
{
    //DLog(@"CALLED - CSVParser: parseTextData");
	NSString *accumulatedData = [NSString string];
	while (YES)
	{
		NSString *fragment;
		if ([scanner scanUpToCharactersFromSet:endTextCharacterSet intoString:&fragment])
		{
			accumulatedData = [accumulatedData stringByAppendingString:fragment];
		}
		
		//
		// If the separator is just a single character (common case) then
		// we know we've reached the end of parseable text
		//
		if (separatorIsSingleChar)
		{
			break;
		}
		
		//
		// Otherwise, we need to consider the case where the first character
		// of the separator is matched but we don't have the full separator.
		//
		NSUInteger location = [scanner scanLocation];
		NSString *firstCharOfSeparator;
		if ([scanner scanString:[separator substringToIndex:1] intoString:&firstCharOfSeparator])
		{
			if ([scanner scanString:[separator substringFromIndex:1] intoString:NULL])
			{
				[scanner setScanLocation:location];
				break;
			}
			
			//
			// We have the first char of the separator but not the whole
			// separator, so just append the char and continue
			//
			accumulatedData = [accumulatedData stringByAppendingString:firstCharOfSeparator];
			continue;
		}
		else
		{
			break;
		}
	}
	
	if ([accumulatedData length] > 0)
	{
		return accumulatedData;
	}
	
	return nil;
}

@end
