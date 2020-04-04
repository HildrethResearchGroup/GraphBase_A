//
//  DGBinaryDataColumn.h
//  Real Time tracker
//
//  Created by David Adalsteinsson on 5/2/09.
//  Copyright 2009-2013 Visual Data Tools, Inc. All rights reserved.
//

#import "DGDataColumn.h"

typedef enum _DGBinaryColumnDateFormat {
    DGBinaryColumnSeconds = 1,
    DGBinaryColumnYMD = 2,
    DGBinaryColumnYM = 3,
    DGBinaryColumnMD = 4,
    DGBinaryColumnDM = 5,
    
    DGBinaryColumnYMDhm = 6,
    DGBinaryColumnYMDhms = 7,
    DGBinaryColumnMDhms = 8,
    DGBinaryColumnDMhms = 9,
    DGBinaryColumnICU = 40
} DGBinaryColumnDateFormat;

@interface DGBinaryDataColumn : DGDataColumn {

}

// Thread safety:
// Only doubleValueInRow is not thread safe, since that would require all of the changes to be flushed.

- (void)appendValue:(double)val; // No undo.
- (void)appendValuesFromPointer:(double *)val length:(int)len; // No undo.

// Default is that the column is numerical, can set it to be a date column.
- (void)setDateColumn:(BOOL)yOrN;
- (BOOL)isDateColumn;

// Formatter
- (void)setDateFormatOption:(DGBinaryColumnDateFormat)t; // Need to call setDateColumn:YES
- (void)setICUFormat:(NSString *)str; // Will also need to call setDateColumn:YES.  This call will set the date format to DGBinaryColumnICU

- (double)doubleValueInRow:(int)i;
- (void)setDoubleValue:(double)val atIndex:(int)i;
- (void)setDoubleValue:(double)val atIndexSet:(NSIndexSet *)indexes;
- (void)setDataFromPointer:(const double *)val length:(int)len; // recUndo = NO
- (void)setDataFromPointer:(const double *)val length:(int)len recordUndo:(BOOL)recUndo;
- (void)setDataFromPointer:(const double *)val maskFromPointer:(const char *)mVal length:(int)len recordUndo:(BOOL)recUndo;

- (void)copyFromBinaryColumn:(DGBinaryDataColumn *)col;

- (void)removeAllEntries;

@end
