/*
 Contains:   Master include file for the DataGraph framework
 
 Copyright:  � 2007 by Visual Data Tools, Inc., all rights reserved.
 */

#ifndef __DataGraphFramework__
#define __DataGraphFramework__

#import <Cocoa/Cocoa.h>

#import "DGStructures.h"
#import "DGToken.h"

#import "DGController.h"

// Variables
#import "DGVariable.h"
#import "DGParameter.h"
#import "DGStringParameter.h"
#import "DGColorScheme.h"

// Columns
#import "DGBinaryDataColumn.h"
#import "DGStandardDataColumn.h"
#import "DGStringDataColumn.h"
#import "DGDateDataColumn.h"
#import "DGExpressionDataColumn.h"

// Settings
#import "DGStylesCommand.h"
#import "DGCanvasCommand.h"
#import "DGXAxisCommand.h"
#import "DGYAxisCommand.h"

// Drawing commands
#import "DGBarCommand.h"
#import "DGBarsCommand.h"
#import "DGBoxCommand.h"
#import "DGColorsCommand.h"
#import "DGExtraAxisCommand.h"
#import "DGFitCommand.h"
#import "DGFunctionCommand.h"
#import "DGGraphicCommand.h"
#import "DGHistogramCommand.h"
#import "DGLabelCommand.h"
#import "DGLegendCommand.h"
#import "DGLinesCommand.h"
#import "DGMagnifyCommand.h"
#import "DGPlotCommand.h"
#import "DGPlotsCommand.h"
#import "DGPointsCommand.h"
#import "DGRangeCommand.h"
#import "DGStockCommand.h"
#import "DGTextCommand.h"

// Detailed settings.  These are composite objects that you can then query or change.
#import "DGFillSettings.h"
#import "DGLineStyleSettings.h"
#import "DGMaskSettings.h"

#endif
