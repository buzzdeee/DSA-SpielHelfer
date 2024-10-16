/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:45:46 +0200 by sebastia

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "DSACharacterDocument.h"
#import "DSACharacterWindowController.h"
#import "DSACharacter.h"
#import "DSATrait.h"
#import "NSFlippedView.h"

#import <execinfo.h>

@interface MyMultiPageView : NSFlippedView
@property (nonatomic, strong) DSACharacter *model; // This can hold your model properties or data
@end

#define PAGE_WIDTH 612
#define PAGE_HEIGHT 792
#define MARGIN 36 // Example margin

@implementation DSACharacterDocument

@synthesize model = _model;

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Initialize your document here
      self.model = [[DSACharacter alloc] init];
    }
  NSLog(@"DSACharacterDocument init was called");  
  return self;
}

- (void)dealloc
{
  NSLog(@"DSACharacterDocument is being deallocated.");
}

- (NSString *)windowNibName
{
  NSLog(@"DSACharacterDocument: windowNibName was called");
  // Return the name of the .gorm file that defines the document's UI
  return @"DSACharacter";
}

// we don't want the windows to pop up on startup
- (void)makeWindowControllers
{

// Log call stack
NSLog(@"DSACharacterDocument: makeWindowControllers self: %@, model: %@", self, [self.model class]);
/*    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);

    NSLog(@"Call stack:");
    for (int i = 0; i < frames; i++) {
        NSLog(@"%s", strs[i]);
    }
    free(strs);
  */  
NSLog(@"DSACharacterDocument: makeWindowControllers self: %@", self);
  
  if (self.windowControllersCreated)
    {
      NSLog(@"DSACharacterDocument: windowControllers already created");
      return; // Don't create again
    }
    self.windowControllersCreated = YES;

  // Characters are all some kind of subclass
  // prevents loading the window on startup
  NSLog(@"DSACharacterDocument makeWindowControllers called model class: %@", [self.model class]);
  
  if (![self.model isMemberOfClass:[DSACharacter class]])
    {
      DSACharacterWindowController *windowController = [[DSACharacterWindowController alloc] initWithWindowNibName:[self windowNibName]];
      [self addWindowController:windowController];
      
      NSLog(@"DSACharacterDocument makeWindowControllers called, and it was DSACharacter class" );
    }
}

/* 
// we don't want the windows to pop up on startup
- (void)makeWindowControllersForNewDocument
{
// Log call stack
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);

    NSLog(@"Call stack:");
    for (int i = 0; i < frames; i++) {
        NSLog(@"%s", strs[i]);
    }
    free(strs);


NSLog(@"DSACharacterDocument: makeWindowControllers self: %@", self);
  
  if (self.windowControllersCreated)
    {
      NSLog(@"DSACharacterDocument: windowControllers already created");
      return; // Don't create again
    }
    self.windowControllersCreated = YES;

  // Characters are all some kind of subclass
  // prevents loading the window on startup
  NSLog(@"DSACharacterDocument makeWindowControllers called model class: %@", [self.model class]);
  
  if (![self.model isMemberOfClass:[DSACharacter class]])
    {
      DSACharacterWindowController *windowController = [[DSACharacterWindowController alloc] initWithWindowNibName:[self windowNibName]];
      [self addWindowController:windowController];
      
      NSLog(@"DSACharacterDocument makeWindowControllers called, and it was DSACharacter class" );
    }
}

*/

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
  // Ensure the model exists       
  @try
    {
      if (!self.model)
        {
          if (outError)
            {
              *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:NSFileWriteUnknownError
                                          userInfo:@{NSLocalizedDescriptionKey: @"No data to save"}];
            }
          return nil;
        }
        
      // Archive model object to NSData
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model requiringSecureCoding:NO error:outError];
        
      if (!data && outError)
        {
          NSLog(@"Archiving failed with error: %@", *outError);
          return nil;
        }
        
      NSLog(@"Successfully encoded the data: %@", data);
      return data;
    }
  @catch (NSException *exception)
    {
      NSLog(@"Exception caught during archiving: %@", exception);
      if (outError)
        {
           *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileWriteUnknownError
                                       userInfo:@{NSLocalizedDescriptionKey: [exception reason]}];
        }
      return nil;
    } 

}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  // Unarchive the model from the data
  self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSACharacter class] fromData:data error:outError];
    
  // If unarchiving fails, return NO and pass the error
  if (!self.model && outError)
    {
      return NO;
    }
 
  return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{    
  // Load data from file
  NSData *data = [NSData dataWithContentsOfURL:url];
  if (!data)
    {
      NSLog(@"Failed to read data from URL: %@", url);
      return NO;
    }
    
  // Unarchive model object from NSData
  self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSACharacter class] fromData:data error:outError];
  if (!self.model)
    {
      NSLog(@"Failed to unarchive model");
      return NO;
    }
    
  // Notify that the document has been successfully loaded
  [self updateChangeCount:NSChangeCleared];
    
  // Force initialization of the UI if lazy loading is used
  if (self.windowControllersCreated)
    {
      NSLog(@"DSACharacterDocument: windowControllers already created");
      //[windowController showWindow:self];
      
      return YES; // Don't create again
    }  
  self.windowControllersCreated = YES;  
  DSACharacterWindowController *windowController = [[DSACharacterWindowController alloc] initWithWindowNibName:[self windowNibName]];
  [self addWindowController:windowController];
  [windowController showWindow:self];
    
  return YES;
}

- (void)printDocument:(id)sender {
    MyMultiPageView *printView = [[MyMultiPageView alloc] initWithFrame:NSMakeRect(0, 0, PAGE_WIDTH, PAGE_HEIGHT)];
    printView.model = self.model; // Fill with your model data

    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printView];
    [printOperation runOperation];
}

@end



@implementation MyMultiPageView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Fill the background
    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);

    // Page size and margins
    CGFloat pageHeight = self.bounds.size.height;
    CGFloat pageWidth = self.bounds.size.width;
    CGFloat margin = 36.0; // Example margin

    // Start drawing from the top
    CGFloat titleHeight = 30; // Height for the title
    CGFloat titleY = margin; // Y position for the title    
    CGFloat tableY = titleY + 10; // Position for the table below the title

    // Draw the title
    [self drawTitleAtY:titleY];

    // Draw the table
    CGFloat basicInfoTableBottomY = [self drawBasicCharacterInfoTableStartingAtY:tableY];
    [self drawLineAtY: basicInfoTableBottomY overPageWidth: pageWidth withMargin: margin];

    CGFloat traitsTableBottomY = [self drawTraitsInfoTableStartingAtY: basicInfoTableBottomY + 30 ];
    
    [self drawPortraitAtY:basicInfoTableBottomY + 340 withHeight:(traitsTableBottomY - basicInfoTableBottomY - 20)];
    [self drawLineAtY: traitsTableBottomY + 130 overPageWidth: pageWidth withMargin: margin];
    // Draw the last page number if needed
    [self drawPageSeparator:1]; // Use appropriate page count
}

- (void)drawPortraitAtY:(CGFloat)y withHeight:(CGFloat)height {
    NSImage *portrait = [self.model portrait]; // Get the portrait image from your model

    if (!portrait) return; // Ensure there's an image to draw

    CGFloat margin = 36.0; // Example margin
    CGFloat imageMargin = 10.0; // Extra margin around the image
    CGFloat imageWidth = 300.0; // Set the width for the image area (as you mentioned XXX)

    // Calculate the available space for the image area
    CGFloat availableWidth = self.bounds.size.width - (2 * margin + imageWidth); 

    // Calculate the rectangle to draw the image in, with proportional scaling
    // NSRect imageRect = NSMakeRect(availableWidth + imageMargin, y, imageWidth, height);
    NSRect imageRect = NSMakeRect(self.bounds.size.width - 2 * margin, y, imageWidth, height);
    
    // Ensure proportional scaling
    NSSize imageSize = [portrait size];
    CGFloat imageAspectRatio = imageSize.width / imageSize.height;
    CGFloat scaledHeight = height;
    CGFloat scaledWidth = height * imageAspectRatio; // Scale width based on height

    // If the scaled width exceeds the designated image area, adjust the height to maintain aspect ratio
    if (scaledWidth > imageWidth) {
        scaledWidth = imageWidth;
        scaledHeight = imageWidth / imageAspectRatio;
    }

    // Flipping context to handle NSFlippedView
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0 yBy:self.bounds.size.height];
    [transform scaleXBy:1 yBy:-1]; // Flip the y-axis
    [transform concat]; // Apply the transformation    
    
    // Draw the image in the calculated rect
    NSRect finalImageRect = NSMakeRect(self.bounds.size.width - 2 * margin - 200, y + (height - scaledHeight) / 2, scaledWidth, scaledHeight);
    [portrait drawInRect:finalImageRect];
}

- (void)drawLineAtY:(CGFloat)y overPageWidth:(CGFloat)pageWidth withMargin:(CGFloat)margin {
    // Set the color to red for the line
    [[NSColor redColor] setStroke];

    // Create a new bezier path
    NSBezierPath *linePath = [NSBezierPath bezierPath];

    // Start the line from the left margin and draw it to the right margin
    [linePath moveToPoint:NSMakePoint(0, y + 20)]; // Start at y + 10 for a small gap
    [linePath lineToPoint:NSMakePoint(pageWidth - margin, y + 20)]; // End at the right margin

    // Set the line width
    [linePath setLineWidth:1.0];

    // Draw the line
    [linePath stroke];
}

- (void)drawTitleAtY:(CGFloat)y {
    NSString *title = @"Charakterbogen";
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:18], // Bold and larger font
        NSForegroundColorAttributeName: [NSColor blackColor]
    };

    NSSize titleSize = [title sizeWithAttributes:attributes];
    NSRect titleRect = NSMakeRect((self.bounds.size.width - titleSize.width) / 2, 
                                   y - titleSize.height, // Start drawing title below the specified y position
                                   titleSize.width,
                                   titleSize.height);
    
    [title drawInRect:titleRect withAttributes:attributes];
}

// returns the current Y at the end
- (CGFloat) drawTraitsInfoTableStartingAtY:(CGFloat)y {
    CGFloat margin = 10.0; // Example margin
    CGFloat cellHeight = 16; // Height for less space between rows
    CGFloat tableWidth = self.bounds.size.width - 2 * margin - 300; // Total width of the table area, leaving XXX for the image

    // Define column widths, adjusted for less space between them
    CGFloat firstColumnWidth = tableWidth * 0.12; // 15% of total width for odd columns (1st column)
    CGFloat secondColumnWidth = tableWidth * 0.18; // 15% of total width for even columns (2nd column)
    CGFloat thirdColumnWidth = tableWidth * 0.15; // 14% of total width for odd columns (3rd column)
    CGFloat fourthColumnWidth = tableWidth * 0.08; // 10% of total width for even columns (4th column)
    CGFloat fifthColumnWidth = tableWidth * 0.12; // 15% of total width for odd columns (5th column)
    CGFloat sixthColumnWidth = tableWidth * 0.27; // 20% of total width for even columns (6th column)

    CGFloat tableY = y; // Start from the provided y offset

    // Variable for font size
    CGFloat cellFontSize = 10.0; // Adjustable font size

    // Example data for the odd columns (static)
    NSArray *titles = @[@"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK", @"TK", @"Last"];
    NSArray *properties = @[
        [[(DSATrait *)[self.model.positiveTraits objectForKey: @"MU"] level] stringValue] ?: @"", // Using nil-coalescing to handle nil values
        [[(DSATrait *)[self.model.positiveTraits objectForKey: @"KL"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.positiveTraits objectForKey: @"IN"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.positiveTraits objectForKey: @"CH"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.positiveTraits objectForKey: @"FF"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.positiveTraits objectForKey: @"GE"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.positiveTraits objectForKey: @"KK"] level] stringValue] ?: @"",
        [self.model.carryingCapacity  stringValue] ?: @"",
        [self.model.encumbrance  stringValue] ?: @""
    ];

    NSArray *secondTitles = @[@"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ", @"AT", @"PA"];
    NSArray *secondProperties = @[
        [[(DSATrait *)[self.model.negativeTraits objectForKey: @"AG"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.negativeTraits objectForKey: @"HA"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.negativeTraits objectForKey: @"RA"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.negativeTraits objectForKey: @"TA"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.negativeTraits objectForKey: @"NG"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.negativeTraits objectForKey: @"GG"] level] stringValue] ?: @"",
        [[(DSATrait *)[self.model.negativeTraits objectForKey: @"JZ"] level] stringValue] ?: @"",
        [self.model.attackBaseValue  stringValue] ?: @"",
        [self.model.parryBaseValue  stringValue] ?: @""
    ];

    NSArray *thirdTitles = @[@"Stufe", @"AP", @"LE", @"AE", @"KE", @"MR", @"AU", @"FK", @"AUW"];
    NSArray *thirdProperties = @[
        [self.model.level  stringValue] ?: @"",
        [self.model.adventurePoints  stringValue] ?: @"",        
        [self.model.lifePoints  stringValue] ?: @"",
        [self.model.astralEnergy  stringValue] ?: @"",
        [self.model.karmaPoints  stringValue] ?: @"",
        [self.model.magicResistance  stringValue] ?: @"",
        [self.model.endurance  stringValue] ?: @"",
        [self.model.rangedCombatBaseValue  stringValue] ?: @"",
        [self.model.dodge  stringValue] ?: @""
    ];

    // Loop through all sets (assuming they all have the same count)
    NSInteger numberOfRows = titles.count; // Assuming all titles and properties arrays have the same count
    CGFloat currentRowY;
    for (NSInteger row = 0; row < numberOfRows; row++) {
        // Calculate y position for the current row
        currentRowY = tableY + row * (cellHeight + 2); // Reduce space between rows

        // Draw title (odd columns)
        NSRect titleRect1 = NSMakeRect(margin, currentRowY, firstColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [titles[row] drawInRect:titleRect1 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw property (even columns) - right aligned
        NSRect propertyRect1 = NSMakeRect(margin + 5 + firstColumnWidth, currentRowY, secondColumnWidth, cellHeight);
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]};
        NSString *propertyString = properties[row];

        // Calculate the size of the string
        NSSize textSize = [propertyString sizeWithAttributes:attributes];

        // Draw the property text right-aligned
        CGFloat propertyX = NSMinX(propertyRect1) + (secondColumnWidth - textSize.width);
        [propertyString drawAtPoint:NSMakePoint(propertyX, currentRowY) withAttributes:attributes];

        // Draw second title (odd columns)
        NSRect titleRect2 = NSMakeRect(margin + 2 * 5 + firstColumnWidth + secondColumnWidth, currentRowY, thirdColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [secondTitles[row] drawInRect:titleRect2 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw second property (even columns) - right aligned
        NSRect propertyRect2 = NSMakeRect(margin + 3 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth, currentRowY, fourthColumnWidth, cellHeight);
        NSString *secondPropertyString = secondProperties[row];
        NSSize secondTextSize = [secondPropertyString sizeWithAttributes:attributes];
        CGFloat secondPropertyX = NSMinX(propertyRect2) + (fourthColumnWidth - secondTextSize.width);
        [secondPropertyString drawAtPoint:NSMakePoint(secondPropertyX, currentRowY) withAttributes:attributes];

        // Draw third title (odd columns)
        NSRect titleRect3 = NSMakeRect(margin + 4 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth, currentRowY, fifthColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [thirdTitles[row] drawInRect:titleRect3 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw third property (even columns) - right aligned
        NSRect propertyRect3 = NSMakeRect(margin + 5 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth + fifthColumnWidth, currentRowY, sixthColumnWidth, cellHeight);
        NSString *thirdPropertyString = thirdProperties[row];
        NSSize thirdTextSize = [thirdPropertyString sizeWithAttributes:attributes];
        CGFloat thirdPropertyX = NSMinX(propertyRect3) + (sixthColumnWidth - thirdTextSize.width);
        [thirdPropertyString drawAtPoint:NSMakePoint(thirdPropertyX, currentRowY) withAttributes:attributes];
    }
  return currentRowY;
}

// returns the current Y at the end
- (CGFloat) drawBasicCharacterInfoTableStartingAtY:(CGFloat)y {
    CGFloat margin = 10.0; // Example margin
    CGFloat cellHeight = 16; // Height for less space between rows
    CGFloat tableWidth = self.bounds.size.width - 2 * margin; // Total width of the table area

    // Define column widths, adjusted for less space between them
    CGFloat firstColumnWidth = tableWidth * 0.12; // 15% of total width for odd columns (1st column)
    CGFloat secondColumnWidth = tableWidth * 0.18; // 15% of total width for even columns (2nd column)
    CGFloat thirdColumnWidth = tableWidth * 0.13; // 14% of total width for odd columns (3rd column)
    CGFloat fourthColumnWidth = tableWidth * 0.08; // 10% of total width for even columns (4th column)
    CGFloat fifthColumnWidth = tableWidth * 0.15; // 15% of total width for odd columns (5th column)
    CGFloat sixthColumnWidth = tableWidth * 0.23; // 20% of total width for even columns (6th column)

    CGFloat tableY = y; // Start from the provided y offset

    // Variable for font size
    CGFloat cellFontSize = 10.0; // Adjustable font size

    // Example data for the odd columns (static)
    NSArray *titles = @[@"Name", @"Titel", @"Typus", @"Herkunft", @"Schule", @"Magiedilettant"];
    NSArray *properties = @[
        self.model.name ?: @"", // Using nil-coalescing to handle nil values
        self.model.title ?: @"",
        self.model.archetype ?: @"",
        self.model.origin ?: @"",
        self.model.mageAcademy ?: @"",
        self.model.isMagicalDabbler ? _(@"Ja") : _(@"Nein")
    ];

    NSArray *secondTitles = @[@"Geschlecht", @"Haarfarbe", @"Augenfarbe", @"Größe", @"Gewicht", @""];
    NSArray *secondProperties = @[
        self.model.sex ?: @"",
        self.model.hairColor ?: @"",
        self.model.eyeColor ?: @"",
        self.model.height ?: @"",
        self.model.weight ?: @"",
        @""
    ];

    NSArray *thirdTitles = @[@"Geburtstag", @"Geburtsgott", @"Sterne", @"Glaube", @"Stand", @"Eltern"];
    NSArray *thirdProperties = @[
        [self.model.birthday objectForKey:@"date"] ?: @"",
        self.model.god ?: @"",
        self.model.stars ?: @"",
        self.model.religion ?: @"",
        self.model.socialStatus ?: @"",
        self.model.parents ?: @""
    ];

    // Loop through all sets (assuming they all have the same count)
    NSInteger numberOfRows = titles.count; // Assuming all titles and properties arrays have the same count
    CGFloat currentRowY;
    for (NSInteger row = 0; row < numberOfRows; row++) {
        // Calculate y position for the current row
        currentRowY = tableY + row * (cellHeight + 2); // Reduce space between rows

        // Draw title (odd columns)
        NSRect titleRect1 = NSMakeRect(margin, currentRowY, firstColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [titles[row] drawInRect:titleRect1 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw property (even columns) - right aligned
        NSRect propertyRect1 = NSMakeRect(margin + 5 + firstColumnWidth, currentRowY, secondColumnWidth, cellHeight);
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]};
        NSString *propertyString = properties[row];

        // Calculate the size of the string
        NSSize textSize = [propertyString sizeWithAttributes:attributes];

        // Draw the property text right-aligned
        CGFloat propertyX = NSMinX(propertyRect1) + (secondColumnWidth - textSize.width);
        [propertyString drawAtPoint:NSMakePoint(propertyX, currentRowY) withAttributes:attributes];

        // Draw second title (odd columns)
        NSRect titleRect2 = NSMakeRect(margin + 2 * 5 + firstColumnWidth + secondColumnWidth, currentRowY, thirdColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [secondTitles[row] drawInRect:titleRect2 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw second property (even columns) - right aligned
        NSRect propertyRect2 = NSMakeRect(margin + 3 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth, currentRowY, fourthColumnWidth, cellHeight);
        NSString *secondPropertyString = secondProperties[row];
        NSSize secondTextSize = [secondPropertyString sizeWithAttributes:attributes];
        CGFloat secondPropertyX = NSMinX(propertyRect2) + (fourthColumnWidth - secondTextSize.width);
        [secondPropertyString drawAtPoint:NSMakePoint(secondPropertyX, currentRowY) withAttributes:attributes];

        // Draw third title (odd columns)
        NSRect titleRect3 = NSMakeRect(margin + 4 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth, currentRowY, fifthColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [thirdTitles[row] drawInRect:titleRect3 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw third property (even columns) - right aligned
        NSRect propertyRect3 = NSMakeRect(margin + 5 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth + fifthColumnWidth, currentRowY, sixthColumnWidth, cellHeight);
        NSString *thirdPropertyString = thirdProperties[row];
        NSSize thirdTextSize = [thirdPropertyString sizeWithAttributes:attributes];
        CGFloat thirdPropertyX = NSMinX(propertyRect3) + (sixthColumnWidth - thirdTextSize.width);
        [thirdPropertyString drawAtPoint:NSMakePoint(thirdPropertyX, currentRowY) withAttributes:attributes];
    }
  return currentRowY;
}

- (void)drawPageSeparator:(NSUInteger)pageNumber {
    NSString *pageText = [NSString stringWithFormat:_(@"Seite %lu"), (unsigned long)pageNumber];
    [pageText drawAtPoint:NSMakePoint(self.bounds.size.width - 100, 10) 
            withAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:8]}];
}
@end
