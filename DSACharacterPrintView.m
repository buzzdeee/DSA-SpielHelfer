/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-10-20 17:58:36 +0200 by sebastia

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

#import "DSACharacterPrintView.h"
#import "DSACharacterHero.h"
#import "DSACharacterMagic.h"
#import "DSASpell.h"
#import "DSATrait.h"
#import "DSATalent.h"
#import "DSASpecialTalent.h"
#import "DSAProfession.h"
#import "DSAOtherTalent.h"
#import "NSFlippedView.h"


@implementation DSACharacterPrintView

- (instancetype)initWithFrame:(NSRect)frameRect
{
  self = [super initWithFrame:frameRect];
  if (self)
    {
      // Initialize the current page to 1 (or the desired starting page)
      self.currentPage = 1; // Assuming page numbers start from 1
      self.spellCategoriesAlreadyDone = [[NSMutableArray alloc] init];
    }
  return self;
}

// Knows how many pages the view spans
- (BOOL)knowsPageRange:(NSRangePointer)range
{
  // Set the page range for printing
  range->location = 1; // Pages start at 1
  range->length = [self calculateTotalPages]; // Implement your logic to calculate total pages
  return YES;
}

// Calculate the area that will be printed on each page
- (NSRect)rectForPage:(NSInteger)page
{
  // Set the height of each page (could be based on printer paper size or a custom size)
  CGFloat pageHeight = [self paperHeightForPage]; // Implement this as necessary

  // Calculate the y-offset for this page (higher page numbers correspond to lower content)
  NSRect pageRect = NSMakeRect(-MARGIN, (page - 1) * pageHeight, self.bounds.size.width + MARGIN - 4, pageHeight);

  NSLog(@"RECT FOR PAGE: %@", NSStringFromRect(pageRect));
  return pageRect;
}

// Draw content for each page
- (void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];

  NSLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX dirtyRect: %@", NSStringFromRect(dirtyRect));
  NSUInteger currentPage = [self calculateCurrentPageForDirtyRect:dirtyRect];
  self.currentPage = currentPage;
  //[self drawContentForPage:currentPage inRect:dirtyRect];
  [self drawContentForPage:currentPage inRect: [self rectForPage: currentPage]];
}


// Helper method to calculate the total number of pages
- (NSUInteger)calculateTotalPages
{
  CGFloat pageHeight = [self paperHeightForPage];
  CGFloat contentHeight = self.bounds.size.height;
  NSUInteger totalPages = ceil(contentHeight / pageHeight);
  return totalPages;
}

// Helper to determine which page corresponds to a particular rect (optional)
- (NSUInteger)calculateCurrentPageForDirtyRect:(NSRect)dirtyRect
{
  CGFloat pageHeight = [self paperHeightForPage];
  NSUInteger currentPage = ceil(NSMaxY(dirtyRect) / pageHeight);
  return currentPage;
}


// Example of drawing content for a specific page
- (void)drawContentForPage:(NSUInteger)page inRect:(NSRect)rect
{
  NSString *methodName;
  if (page == 1)
    {
      methodName = @"drawBasicsPageWithRect:";
    }
  else if (page == 2)
    {
      methodName = @"drawTalentsPageWithRect:";    
    }
  else if (page == 3)
    {
      methodName = @"drawBiographyPageWithRect:";    
    }    
  else
    {
      if (page == 4 && self.pages == 4)  // magical Dabbler
        {
          methodName = @"drawMagicalDabblerPageWithRect:";
        }
      else
        {
          methodName = @"drawSpellsWithRect:";
        }
    }
  
  SEL selector = NSSelectorFromString(methodName);  
  if ([self respondsToSelector:selector])
    {
      // Create an NSMethodSignature for the method
      NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    
      // Create an NSInvocation with the method signature
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:self];
    
      // Set the argument for the invocation
      [invocation setArgument:&rect atIndex:2]; // Index 2 for the first argument, since 0 is 'self' and 1 is the selector
    
      // Invoke the method
      [invocation invoke];
    }
  else
    {
      // Handle the case where self doesn't respond to the selector
      NSLog(@"self does not respond to the method %@", methodName);
    }
  // Draw page number at the bottom
  [self drawPageSeparator:page withWidth: rect.size.width - MARGIN];
}

// Example of how to get paper height (can be customized)
- (CGFloat)paperHeightForPage
{
  return PAGE_HEIGHT; 
}


- (void) drawBasicsPageWithRect: (NSRect)dirtyRect
{
  [super drawRect:dirtyRect];

  // Fill the background
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
            
  // Page size and margins
  CGFloat pageWidth = dirtyRect.size.width;
  NSLog(@"drawBasicsPageWithRect: pageTopY: 0");
  // Start drawing from the top
  CGFloat titleHeight = 20; // Height for the title
  CGFloat titleY = titleHeight; // Y position for the title    
  CGFloat tableY = titleY + 10; // Position for the table below the title

  // Draw the title
  [self drawTitleAtY:titleY withTitle: _(@"Charakterbogen")];

  // Draw the table
  CGFloat basicInfoTableBottomY = [self drawBasicCharacterInfoTableStartingAtY:tableY withWidth: pageWidth];
  [self drawLineAtY: basicInfoTableBottomY overPageWidth: pageWidth];

  CGFloat traitsTableBottomY = [self drawTraitsInfoTableStartingAtY: basicInfoTableBottomY + 30 ];
   
  [self drawPortraitAtY:basicInfoTableBottomY + 30 withHeight:(traitsTableBottomY - basicInfoTableBottomY - 20)];
  [self drawLineAtY: traitsTableBottomY overPageWidth: pageWidth];
}

- (void) drawTalentsPageWithRect: (NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  // Fill the background
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
    
  CGFloat pageTopY = [self paperHeightForPage] * (self.currentPage - 1);
  NSLog(@"drawTalentsPageWithRect: pageTopY %lu", (unsigned long) pageTopY);    
  // Page size and margins
//  CGFloat pageHeight = self.bounds.size.height;
//  CGFloat pageWidth = self.bounds.size.width;

  // Start drawing from the top
  CGFloat titleHeight = 20; // Height for the title
  CGFloat titleY = pageTopY + titleHeight; // Y position for the title    

  // Draw the title
  [self drawTitleAtY:titleY withTitle: _(@"Talentbogen")];
  CGFloat tableY = [self drawPositiveTraitsHeaderAtY: titleY];
  [self drawTalentsAtY: tableY];
}

- (void) drawMagicalDabblerPageWithRect: (NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  // Fill the background
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
    
  CGFloat pageTopY = [self paperHeightForPage] * (self.currentPage - 1);
  NSLog(@"drawMagicalDabblerPageWithRect: pageTopY %lu", (unsigned long) pageTopY);  

  // Start drawing from the top
  CGFloat titleHeight = 20; // Height for the title
  CGFloat titleY = pageTopY + titleHeight; // Y position for the title    

  // Draw the title
  [self drawTitleAtY:titleY withTitle: _(@"Magiedilettant")];
  CGFloat tableY = [self drawPositiveTraitsHeaderAtY: titleY];
  [self drawMagicalDabblerSpecials: tableY];
}

- (void) drawBiographyPageWithRect: (NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  // Fill the background
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
    
  CGFloat pageTopY = [self paperHeightForPage] * (self.currentPage - 1);
  NSLog(@"drawMagicalDabblerPageWithRect: pageTopY %lu", (unsigned long) pageTopY);  

  // Start drawing from the top
  CGFloat titleHeight = 20; // Height for the title
  CGFloat titleY = pageTopY + titleHeight; // Y position for the title    

  // Draw the title
  [self drawTitleAtY:titleY withTitle: _(@"Biografie")];
  CGFloat tableY = [self drawPositiveTraitsHeaderAtY: titleY];
  [self drawBiography: tableY];
}

- (void) drawSpellsWithRect: (NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  // Fill the background
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
    
  CGFloat pageTopY = [self paperHeightForPage] * (self.currentPage - 1);
  NSLog(@"drawSpellsWithRect: pageTopY %lu", (unsigned long) pageTopY);    

  // Start drawing from the top
  CGFloat titleHeight = 20; // Height for the title
  CGFloat titleY = pageTopY + titleHeight; // Y position for the title    

  // Draw the title
  [self drawTitleAtY:titleY withTitle: _(@"Zauberbogen")];
  CGFloat tableY = [self drawPositiveTraitsHeaderAtY: titleY];
  
  [self drawSpellsAtY: tableY];
}

- (void) drawSpellsAtY: (CGFloat)y
{
  CGFloat cellHeight = 12; // Height for less space between rows
  CGFloat cellFontSize = 10;
  CGFloat tableWidth = self.bounds.size.width; // Total width of the table area

  CGFloat minY = y;
  CGFloat maxY = [self paperHeightForPage] * self.currentPage;

  NSInteger mainColumn = 0;
  CGFloat halfTableWidth = tableWidth / 2;
  CGFloat titleCellWidth = halfTableWidth * 0.95;
  CGFloat propertyCellWidth = halfTableWidth * 0.05;  
                     
  if ([(DSACharacterHero *)self.model spells])
    {
      NSMutableDictionary<NSString *, NSMutableArray<DSASpell *> *> *categoryDict = [NSMutableDictionary dictionary];
      for (NSString *key in [(DSACharacterHero *)self.model spells])
        {
          DSASpell *spell = [[(DSACharacterHero *)self.model spells] objectForKey: key];
    
          // Get the category of the current spell
          NSString *category = spell.category;
    
          // Check if the category already exists in the categoryDict
          if (!categoryDict[category])
            {
              // If the category doesn't exist, create a new array for it
              categoryDict[category] = [NSMutableArray array];
            }
          // Add the spell to the corresponding category array
          [categoryDict[category] addObject:spell];
        }
    
      NSArray<NSString *> *sortedCategories = [[categoryDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
      NSMutableArray *result = [NSMutableArray array];
      for (NSString *category in sortedCategories)
        {
          // Sort the spells within each category by name
          NSArray<DSASpell *> *sortedSpellsInCategory = [categoryDict[category] sortedArrayUsingComparator:^NSComparisonResult(DSASpell *spell1, DSASpell *spell2) {
            return [spell1.name compare:spell2.name];
          }];
    
          // Add the category and its sorted spells to the result
          [result addObject:@{
            @"category": category,
            @"spells": sortedSpellsInCategory
          }];
        }
   

      for (NSDictionary *categoryDict in result)
        {
          // Extract the category name
          NSString *category = categoryDict[@"category"];
          NSLog(@"Category: %@", category);
          if ([self.spellCategoriesAlreadyDone containsObject: category])
            {
              NSLog(@"CATEGORY ALREADY DEALT WITH: %@, continuing...", category);
              continue;  // we dealt with that category already on a previous page
            }
          // Extract the array of spells
          NSArray<DSASpell *> *spellsInCategory = categoryDict[@"spells"];
     
          if (y + cellHeight + cellHeight * [spellsInCategory count] > maxY)  // check if we arrived at the bottom, then continue in the second column.
            {
              y = minY;
              if (mainColumn == 0)
                {
                  mainColumn = 1;
                }
              else
                {
                  return;  // we already filled up both columns on that page
                }
            }
          [self.spellCategoriesAlreadyDone addObject: category];

          NSRect headerRect = NSMakeRect(0 + halfTableWidth * mainColumn , y, self.bounds.size.width / 2, cellHeight);
          NSLog(@"HEADER CELL RECT %@", NSStringFromRect(headerRect));
          [self drawCategoryHeaderInRect: headerRect withTitle: category];
          y += cellHeight;
 
          NSLog(@"halfTableWidth %lu, titleCellWidth %lu, propertyCellWidth, %lu, self.bounds.size.width %lu", (unsigned long)halfTableWidth, (unsigned long) titleCellWidth, (unsigned long) propertyCellWidth, (unsigned long)self.bounds.size.width);
       
          for (DSASpell *spell in spellsInCategory)
            {
               NSRect titleRect = NSMakeRect(
                 0 + halfTableWidth * mainColumn,
                 y + cellHeight,
                 titleCellWidth,
                 cellHeight
               );
               NSRect propertyRect = NSMakeRect(
                 titleCellWidth + halfTableWidth * mainColumn,
                 y + cellHeight,
                 propertyCellWidth,
                 cellHeight
               );
               [[NSColor blackColor] setFill];

               // Even column index, draw title
               NSString *title;
               title = [NSString stringWithFormat: @"%@ (%@)", [spell name], [[spell test] componentsJoinedByString:@"/"]];
               NSColor *fontColor;
               if ([spell isActiveSpell])
                 {
                   fontColor = [NSColor blackColor];
                 }
               else
                 {
                   fontColor = [NSColor redColor];
                 }
               NSDictionary *titleAttributes = @{
                 NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize],
                 NSForegroundColorAttributeName: fontColor
               };
               [title drawInRect:titleRect withAttributes:titleAttributes];

               NSString *propertyString = [NSString stringWithFormat: @"%lu", (unsigned long)[spell level]];
               NSDictionary *propertyAttributes = @{
                 NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize],
                 NSForegroundColorAttributeName: fontColor
               };
        
               NSSize textSize = [propertyString sizeWithAttributes:propertyAttributes];

               // Draw the property text right-aligned
               CGFloat propertyX = NSMinX(propertyRect) + (propertyCellWidth - textSize.width) - 5;
               [propertyString drawAtPoint:NSMakePoint(propertyX, y + cellHeight) withAttributes:propertyAttributes];       
               y += cellHeight;
            }    
         }  // outer for loop end  
      } // if self.model.spells
}


- (void) drawMagicalDabblerSpecials: (CGFloat)y
{
  // CGFloat margin = 10.0; // Example margin
  CGFloat cellHeight = 12; // Height for less space between rows
  CGFloat cellFontSize = 10;
  CGFloat tableWidth = self.bounds.size.width; // Total width of the table area

  CGFloat minY = y;
  CGFloat maxY = [self paperHeightForPage] * self.currentPage;

  NSInteger mainColumn = 0;
  CGFloat halfTableWidth = tableWidth / 2;
  CGFloat titleCellWidth = halfTableWidth * 0.80;
  CGFloat propertyCellWidth = halfTableWidth * 0.20;  
                     
  if ([(DSACharacterHero *)self.model spells])
    {
      NSMutableDictionary<NSString *, NSMutableArray<DSASpell *> *> *categoryDict = [NSMutableDictionary dictionary];
      for (NSString *key in [(DSACharacterHero *)self.model spells])
        {
          DSASpell *spell = [[(DSACharacterHero *)self.model spells] objectForKey: key];
    
          // Get the category of the current spell
          NSString *category = spell.category;
    
          // Check if the category already exists in the categoryDict
          if (!categoryDict[category])
            {
              // If the category doesn't exist, create a new array for it
              categoryDict[category] = [NSMutableArray array];
            }
          // Add the spell to the corresponding category array
          [categoryDict[category] addObject:spell];
        }
    
      NSArray<NSString *> *sortedCategories = [[categoryDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
      NSMutableArray *result = [NSMutableArray array];
      for (NSString *category in sortedCategories)
        {
          // Sort the spells within each category by name
          NSArray<DSASpell *> *sortedSpellsInCategory = [categoryDict[category] sortedArrayUsingComparator:^NSComparisonResult(DSASpell *spell1, DSASpell *spell2) {
            return [spell1.name compare:spell2.name];
          }];
    
          // Add the category and its sorted spells to the result
          [result addObject:@{
            @"category": category,
            @"spells": sortedSpellsInCategory
          }];
        }
   

      for (NSDictionary *categoryDict in result)
        {
          // Extract the category name
          NSString *category = categoryDict[@"category"];
          NSLog(@"Category: %@", category);
    
          // Extract the array of spells
          NSArray<DSASpell *> *spellsInCategory = categoryDict[@"spells"];
     
          if (y + cellHeight + cellHeight * [spellsInCategory count] > maxY)  // check if we arrived at the bottom, then continue in the second column.
            {
              y = minY;
              mainColumn = 1;
            }        
          NSRect headerRect = NSMakeRect(0 + halfTableWidth * mainColumn , y, self.bounds.size.width / 2, cellHeight);
          NSLog(@"HEADER CELL RECT %@", NSStringFromRect(headerRect));
          [self drawCategoryHeaderInRect: headerRect withTitle: category];
          y += cellHeight;
 
          NSLog(@"halfTableWidth %lu, titleCellWidth %lu, propertyCellWidth, %lu, self.bounds.size.width %lu", (unsigned long)halfTableWidth, (unsigned long) titleCellWidth, (unsigned long) propertyCellWidth, (unsigned long)self.bounds.size.width);
       
          for (DSASpell *spell in spellsInCategory)
            {
               NSRect titleRect = NSMakeRect(
                 0 + halfTableWidth * mainColumn,
                 y + cellHeight,
                 titleCellWidth,
                 cellHeight
               );
               NSRect propertyRect = NSMakeRect(
                 titleCellWidth + halfTableWidth * mainColumn,
                 y + cellHeight,
                 propertyCellWidth,
                 cellHeight
               );
               [[NSColor blackColor] setFill];

               // Even column index, draw title
               NSString *title;
               title = [NSString stringWithFormat: @"%@ (%@)", [spell name], [[spell test] componentsJoinedByString:@"/"]];
               NSDictionary *titleAttributes = @{
                 NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize],
                 NSForegroundColorAttributeName: [NSColor blackColor]
               };
               [title drawInRect:titleRect withAttributes:titleAttributes];

               NSString *propertyString = [NSString stringWithFormat: @"%lu", (unsigned long)[spell level]];
               NSDictionary *propertyAttributes = @{
                 NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize],
                 NSForegroundColorAttributeName: [NSColor blackColor]
               };
        
               NSSize textSize = [propertyString sizeWithAttributes:propertyAttributes];

               // Draw the property text right-aligned
               CGFloat propertyX = NSMinX(propertyRect) + (propertyCellWidth - textSize.width) - 5;
               [propertyString drawAtPoint:NSMakePoint(propertyX, y + cellHeight) withAttributes:propertyAttributes];       
               y += cellHeight;
            }    
         }  // outer for loop end  
      } // if self.model.spells
      
  if ([(DSACharacterHero *)self.model specials])
    {
      NSLog (@"HERE IN SPECIALS");
      NSRect headerRect = NSMakeRect(0 + halfTableWidth * mainColumn , y, self.bounds.size.width / 2, cellHeight);
      [self drawCategoryHeaderInRect: headerRect withTitle: _(@"Spezielle Talente")];
      NSLog(@"after drawing header");
      y += cellHeight;
      for (DSASpecialTalent *talent in [[(DSACharacterHero *)self.model specials] allValues])
        {

           NSLog(@"THE SPECIAL TALENT: %@", talent);
           NSRect titleRect = NSMakeRect(
             0 + halfTableWidth * mainColumn,
             y + cellHeight,
             titleCellWidth,
             cellHeight
           );
           NSRect propertyRect = NSMakeRect(
             titleCellWidth + halfTableWidth * mainColumn,
             y + cellHeight,
             propertyCellWidth,
             cellHeight
           );
    
           [[NSColor blackColor] setFill];

           // Even column index, draw title
           NSString *title;
           if ([talent test])
             {
               title = [NSString stringWithFormat: @"%@ (%@)", [talent name], [[talent test] componentsJoinedByString:@"/"]];
             }
           else
             {
               title = [talent name];
             } 
           NSLog(@"THE TITLE: %@", title);
          
           NSDictionary *titleAttributes = @{
             NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize],
             NSForegroundColorAttributeName: [NSColor blackColor]
           };
           [title drawInRect:titleRect withAttributes:titleAttributes];

          NSString *propertyString = @"";  // nothing to display here...
          NSDictionary *propertyAttributes = @{
            NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize],
            NSForegroundColorAttributeName: [NSColor blackColor]
          };
        
          NSSize textSize = [propertyString sizeWithAttributes:propertyAttributes];

          // Draw the property text right-aligned
          CGFloat propertyX = NSMinX(propertyRect) + (propertyCellWidth - textSize.width) - 5;
          [propertyString drawAtPoint:NSMakePoint(propertyX, y + cellHeight) withAttributes:propertyAttributes];       
          y += cellHeight;
        }
    }
    
}

- (void) drawBiography:(CGFloat)y {
    CGFloat cellHeight = 12;         // Increased height for headers
    CGFloat cellFontSize = 10;       // Font size for content text
    CGFloat tableWidth = self.bounds.size.width;
    CGFloat maxY = [self paperHeightForPage] * self.currentPage;
    CGFloat bulletLineSpacing = 0.0; // Smaller line spacing for bullets to reduce extra space

    NSFont *font = [NSFont systemFontOfSize:cellFontSize];

    // Create paragraph style with bullet indentation
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat bulletIndent = 10.0; // Indent for bullets
    CGFloat textIndent = 15.0;   // Indent for wrapped lines to align with text

    [paragraphStyle setFirstLineHeadIndent:bulletIndent];
    [paragraphStyle setHeadIndent:textIndent];
    [paragraphStyle setLineSpacing:bulletLineSpacing]; // Tighter line spacing between bullets

    // Create attributes for the text with the paragraph style
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSParagraphStyleAttributeName: paragraphStyle,
        NSForegroundColorAttributeName: [NSColor blackColor]
    };

    // Define each section with title and content
    NSArray *sections = @[
        @{ @"title": _(@"Geburt"), @"content": [self birthContent] },
        @{ @"title": _(@"Kindheit"), @"content": [self childhoodContent] },
        @{ @"title": _(@"Jugend"), @"content": [self youthContent] }
    ];

    for (NSDictionary *section in sections) {
        NSString *title = section[@"title"];
        NSString *content = section[@"content"];

        // Draw section header
        NSRect headerRect = NSMakeRect(0, y, tableWidth, cellHeight);
        y += cellHeight + 16.0; // Add space after header for better separation
        [self drawCategoryHeaderInRect:headerRect withTitle:title];
        y += cellHeight + 16.0; // Add space after header for better separation

        // Draw section content using NSTextStorage, NSTextContainer, and NSLayoutManager for proper wrapping
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:content attributes:attributes];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(tableWidth, maxY - y)];
        textContainer.lineFragmentPadding = 0; // No padding around the lines

        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];

        NSUInteger glyphIndex = 0;
        while (glyphIndex < layoutManager.numberOfGlyphs && y < maxY) {
            NSRange glyphRange;
            NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&glyphRange];

            // Adjust line rect to the correct vertical position
            lineRect.origin.y = y;
            y += lineRect.size.height; // Adjust y based on actual line height
            
            // Ensure the content does not exceed the page height
            if (y + bulletLineSpacing < maxY) {
                [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:lineRect.origin];
            }
            glyphIndex = NSMaxRange(glyphRange);
        }

        // Additional space between sections
        y += 40.0; // Adjust this value for desired spacing between sections
    }
}

- (void) FASDFFdrawBiography:(CGFloat)y {
    CGFloat cellHeight = 12;         // Height for headers
    CGFloat cellFontSize = 10;       // Font size for content text
    CGFloat tableWidth = self.bounds.size.width;
    CGFloat maxY = [self paperHeightForPage] * self.currentPage;
    CGFloat lineSpacing = 0.0;       // Additional line spacing for readability

    NSFont *font = [NSFont systemFontOfSize:cellFontSize];

    // Create paragraph style with bullet indentation
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat bulletIndent = 10.0; // Indent for bullets
    CGFloat textIndent = 20.0;   // Indent for wrapped lines to align with text

    [paragraphStyle setFirstLineHeadIndent:bulletIndent];
    [paragraphStyle setHeadIndent:textIndent];
    [paragraphStyle setLineSpacing:lineSpacing];

    // Create attributes for the text with the paragraph style
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSParagraphStyleAttributeName: paragraphStyle,
        NSForegroundColorAttributeName: [NSColor blackColor]
    };

    // Define each section with title and content
    NSArray *sections = @[
        @{ @"title": _(@"Geburt"), @"content": [self birthContent] },
        @{ @"title": _(@"Kindheit"), @"content": [self childhoodContent] },
        @{ @"title": _(@"Jugend"), @"content": [self youthContent] }
    ];

    for (NSDictionary *section in sections) {
        NSString *title = section[@"title"];
        NSString *content = section[@"content"];

        // Draw section header
        NSRect headerRect = NSMakeRect(0, y, tableWidth, cellHeight);
        [self drawCategoryHeaderInRect:headerRect withTitle:title];
        y += 2 * (cellHeight + lineSpacing);

        // Draw section content using NSTextStorage, NSTextContainer, and NSLayoutManager for proper wrapping
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:content attributes:attributes];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(tableWidth, maxY - y)];
        textContainer.lineFragmentPadding = 0; // No padding around the lines

        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];

        NSUInteger glyphIndex = 0;
        while (glyphIndex < layoutManager.numberOfGlyphs && y < maxY) {
            NSRange glyphRange;
            NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&glyphRange];

            // Adjust line rect to the correct vertical position
            lineRect.origin.y = y;
            y += lineRect.size.height + lineSpacing;

            // Ensure the content does not exceed the page height
            if (y < maxY) {
                [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:lineRect.origin];
            }
            glyphIndex = NSMaxRange(glyphRange);
        }
    }
}


- (void) YUCKdrawBiography:(CGFloat)y {
    CGFloat cellHeight = 12;         // Adjusted height for headers
    CGFloat cellFontSize = 10;       // Font size for content text
    CGFloat tableWidth = self.bounds.size.width;
    CGFloat maxY = [self paperHeightForPage] * self.currentPage;
    CGFloat lineSpacing = 4.0;       // Additional line spacing for readability

    NSFont *font = [NSFont systemFontOfSize:cellFontSize];

    // Create paragraph style with bullet indentation
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat bulletIndent = 10.0; // Indent for bullets
    CGFloat textIndent = 20.0;   // Indent for wrapped lines to align with text

    [paragraphStyle setFirstLineHeadIndent:bulletIndent];
    [paragraphStyle setHeadIndent:textIndent];
    [paragraphStyle setLineSpacing:lineSpacing];

    // Create attributes for the text with the paragraph style
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSParagraphStyleAttributeName: paragraphStyle,
        NSForegroundColorAttributeName: [NSColor blackColor]
    };

    // Draw each section header and content
    NSArray *sections = @[
        @{ @"title": _(@"Geburt"), @"content": [self birthContent] },
        @{ @"title": _(@"Kindheit"), @"content": [self childhoodContent] },
        @{ @"title": _(@"Jugend"), @"content": [self youthContent] }
    ];

    for (NSDictionary *section in sections) {
        NSString *title = section[@"title"];
        NSString *content = section[@"content"];

        // Draw section header
        NSRect headerRect = NSMakeRect(0, y, tableWidth, cellHeight);
        [self drawCategoryHeaderInRect:headerRect withTitle:title];
        y += 2* (cellHeight + lineSpacing);

        // Draw section content
        if (y + cellHeight < maxY) {
            NSAttributedString *attrContent = [[NSAttributedString alloc] initWithString:content attributes:attributes];
            NSRect textRect = NSMakeRect(0, y, tableWidth, attrContent.size.height);
            [attrContent drawInRect:textRect];
            y += attrContent.size.height + lineSpacing;
        }
    }
}

- (void) ABXdrawBiography:(CGFloat)y {
    CGFloat cellHeight = 12;         // Adjusted height for headers
    CGFloat cellFontSize = 10;       // Font size for content text
    CGFloat tableWidth = self.bounds.size.width;
    CGFloat maxY = [self paperHeightForPage] * self.currentPage;
    CGFloat lineSpacing = 4.0;       // Additional line spacing for readability

    NSFont *font = [NSFont systemFontOfSize:cellFontSize];

    // Create paragraph style with bullet indentation
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat bulletIndent = 10.0; // Indent for bullets
    CGFloat textIndent = 20.0;   // Indent for wrapped lines to align with text

    [paragraphStyle setFirstLineHeadIndent:bulletIndent];
    [paragraphStyle setHeadIndent:textIndent];
    [paragraphStyle setLineSpacing:lineSpacing];

    // Create attributes for the text with the paragraph style
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSParagraphStyleAttributeName: paragraphStyle,
        NSForegroundColorAttributeName: [NSColor blackColor]
    };

    // Draw each section header and content
    NSArray *sections = @[
        @{ @"title": _(@"Geburt"), @"content": [self birthContent] },
        @{ @"title": _(@"Kindheit"), @"content": [self childhoodContent] },
        @{ @"title": _(@"Jugend"), @"content": [self youthContent] }
    ];

    for (NSDictionary *section in sections) {
        NSString *title = section[@"title"];
        NSString *content = section[@"content"];

        // Draw section header
        NSRect headerRect = NSMakeRect(0, y, tableWidth, cellHeight);
        [self drawCategoryHeaderInRect:headerRect withTitle:title];
        y += 2* (cellHeight + lineSpacing);

        // Draw section content
        if (y + cellHeight < maxY) {
            NSAttributedString *attrContent = [[NSAttributedString alloc] initWithString:content attributes:attributes];
            NSRect textRect = NSMakeRect(0, y, tableWidth, attrContent.size.height);
            [attrContent drawInRect:textRect];
            y += attrContent.size.height + lineSpacing;
        }
    }
}

// Method to retrieve birth-related content as a bulleted string
- (NSString *)birthContent {
    return [NSString stringWithFormat:@"• %@\n• %@\n• %@\n• %@",
            [self.model birthPlace],
            [self.model birthEvent],
            [self.model legitimation],
            [self.model siblingsString]];
}

// Method to retrieve childhood events as a bulleted string
- (NSString *)childhoodContent {
    NSMutableString *childhoodBullets = [NSMutableString string];
    for (NSString *event in [self.model childhoodEvents]) {
        [childhoodBullets appendFormat:@"• %@\n", event];
    }
    return [childhoodBullets copy];
}

// Method to retrieve youth events as a bulleted string
- (NSString *)youthContent {   
    NSMutableString *youthBullets = [NSMutableString string];
    for (NSString *event in [self.model youthEvents]) {
        [youthBullets appendFormat:@"• %@\n", event];
    }
    return [youthBullets copy];
}

- (void) XXXdrawBiography: (CGFloat)y
{
  // CGFloat margin = 10.0; // Example margin
  CGFloat cellHeight = 12; // Height for less space between rows
  CGFloat tableWidth = self.bounds.size.width; // Total width of the table area
  
  NSRect headerRect = NSMakeRect(0, y, tableWidth, cellHeight);                   
  [self drawCategoryHeaderInRect: headerRect withTitle: _(@"Geburt")];
    
}


- (void) drawTalentsAtY: (CGFloat)y 
{
  // CGFloat margin = 10.0; // Example margin
  CGFloat cellHeight = 12; // Height for less space between rows
  CGFloat cellFontSize = 10;
  CGFloat tableWidth = self.bounds.size.width; // Total width of the table area

  CGFloat minY = y;
  CGFloat maxY = [self paperHeightForPage] * self.currentPage;
                   
                                           
  NSMutableDictionary<NSString *, NSMutableArray<DSATalent *> *> *categoryDict = [NSMutableDictionary dictionary];
  for (NSString *key in [(DSACharacterHero *)self.model talents])
    {
      DSATalent *talent = [[(DSACharacterHero *)self.model talents] objectForKey: key];
    
      // Get the category of the current talent
      NSString *category = talent.category;
    
      // Check if the category already exists in the categoryDict
      if (!categoryDict[category])
        {
          // If the category doesn't exist, create a new array for it
          categoryDict[category] = [NSMutableArray array];
        }
    
      // Add the talent to the corresponding category array
      [categoryDict[category] addObject:talent];
    }
    
  NSArray<NSString *> *sortedCategories = [[categoryDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
  
  NSMutableArray *result = [NSMutableArray array];
  for (NSString *category in sortedCategories)
    {
      // Sort the talents within each category by name
      NSArray<DSATalent *> *sortedTalentsInCategory = [categoryDict[category] sortedArrayUsingComparator:^NSComparisonResult(DSATalent *talent1, DSATalent *talent2) {
        return [talent1.name compare:talent2.name];
      }];
    
      // Add the category and its sorted talents to the result
      [result addObject:@{
        @"category": category,
        @"talents": sortedTalentsInCategory
      }];
    }
   
  NSInteger mainColumn = 0;
  CGFloat halfTableWidth = tableWidth / 2;
  CGFloat titleCellWidth = halfTableWidth * 0.80;
  CGFloat propertyCellWidth = halfTableWidth * 0.20;
  for (NSDictionary *categoryDict in result)
    {
      // Extract the category name
      NSString *category = categoryDict[@"category"];
      NSLog(@"Category: %@", category);
    
      // Extract the array of talents
      NSArray<DSATalent *> *talentsInCategory = categoryDict[@"talents"];
     
      if (y + cellHeight + cellHeight * [talentsInCategory count] > maxY)  // check if we arrived at the bottom, then continue in the second column.
        {
          y = minY;
          mainColumn = 1;
        }        
      NSRect headerRect = NSMakeRect(0 + halfTableWidth * mainColumn , y, self.bounds.size.width / 2, cellHeight);
      NSLog(@"HEADER CELL RECT %@", NSStringFromRect(headerRect));
      [self drawCategoryHeaderInRect: headerRect withTitle: category];
      y += cellHeight;

       
      NSLog(@"halfTableWidth %lu, titleCellWidth %lu, propertyCellWidth, %lu, self.bounds.size.width %lu", (unsigned long)halfTableWidth, (unsigned long) titleCellWidth, (unsigned long) propertyCellWidth, (unsigned long)self.bounds.size.width);
       
       for (DSATalent *talent in talentsInCategory)
         {
           NSRect titleRect = NSMakeRect(
             0 + halfTableWidth * mainColumn,
             y + cellHeight,
             titleCellWidth,
             cellHeight
           );
           NSRect propertyRect = NSMakeRect(
             titleCellWidth + halfTableWidth * mainColumn,
             y + cellHeight,
             propertyCellWidth,
             cellHeight
           );
    
           [[NSColor blackColor] setFill];

           // Even column index, draw title
           NSString *title;    
          if ([talent isMemberOfClass: [DSAOtherTalent class]])
            {
              title = [NSString stringWithFormat: @"%@ (%@)", [talent name], [[(DSAOtherTalent *)talent test] componentsJoinedByString:@"/"]];
            }
          else
            {
              title = [talent name];
            }
          NSDictionary *titleAttributes = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize],
            NSForegroundColorAttributeName: [NSColor blackColor]
          };
          [title drawInRect:titleRect withAttributes:titleAttributes];

          NSString *propertyString = [NSString stringWithFormat: @"%ld", (signed long)talent.level];
          NSDictionary *propertyAttributes = @{
            NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize],
            NSForegroundColorAttributeName: [NSColor blackColor]
          };
        
          NSSize textSize = [propertyString sizeWithAttributes:propertyAttributes];

          // Draw the property text right-aligned
          CGFloat propertyX = NSMinX(propertyRect) + (propertyCellWidth - textSize.width) - 5;
          [propertyString drawAtPoint:NSMakePoint(propertyX, y + cellHeight) withAttributes:propertyAttributes];       
          y += cellHeight;
        }    
    }  // outer for loop end  
  if ([(DSACharacterHero *)self.model professions])
    {
      NSLog (@"HERE IN PROFESSIONS");
      NSRect headerRect = NSMakeRect(0 + halfTableWidth * mainColumn , y, self.bounds.size.width / 2, cellHeight);
      [self drawCategoryHeaderInRect: headerRect withTitle: _(@"Berufe und Hobbies")];
      NSLog(@"after drawing header");
      y += cellHeight;
      for (DSAProfession *profession in [[(DSACharacterHero *)self.model professions] allValues])
        {

           NSLog(@"THE PROFESSION: %@", profession);
           NSRect titleRect = NSMakeRect(
             0 + halfTableWidth * mainColumn,
             y + cellHeight,
             titleCellWidth,
             cellHeight
           );
           NSRect propertyRect = NSMakeRect(
             titleCellWidth + halfTableWidth * mainColumn,
             y + cellHeight,
             propertyCellWidth,
             cellHeight
           );
    
           [[NSColor blackColor] setFill];

           // Even column index, draw title
           NSString *title;    

          title = [NSString stringWithFormat: @"%@ (%@)", [profession name], [[profession test] componentsJoinedByString:@"/"]];

          NSLog(@"THE TITLE: %@", title);
          
          NSDictionary *titleAttributes = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize],
            NSForegroundColorAttributeName: [NSColor blackColor]
          };
          [title drawInRect:titleRect withAttributes:titleAttributes];

          NSString *propertyString = [NSString stringWithFormat: @"%ld", profession.level];
          NSDictionary *propertyAttributes = @{
            NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize],
            NSForegroundColorAttributeName: [NSColor blackColor]
          };
        
          NSSize textSize = [propertyString sizeWithAttributes:propertyAttributes];

          // Draw the property text right-aligned
          CGFloat propertyX = NSMinX(propertyRect) + (propertyCellWidth - textSize.width) - 5;
          [propertyString drawAtPoint:NSMakePoint(propertyX, y + cellHeight) withAttributes:propertyAttributes];       
          y += cellHeight;
        }
    }
    
}

- (void) drawCategoryHeaderInRect: (NSRect) rect withTitle: (NSString *) title {
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:10], // Bold and larger font
        NSForegroundColorAttributeName: [NSColor blackColor]
    };

    NSSize titleSize = [title sizeWithAttributes:attributes];
    NSRect titleRect = NSMakeRect(rect.origin.x + (rect.size.width - titleSize.width) / 2, 
                                   rect.origin.y + titleSize.height, // Start drawing title below the specified y position
                                   titleSize.width,
                                   titleSize.height);
    
    [title drawInRect:titleRect withAttributes:attributes];
}

- (CGFloat) drawPositiveTraitsHeaderAtY: (CGFloat)y {
    // CGFloat margin = 10.0; // Example margin
    CGFloat cellHeight = 12; // Height for less space between rows
    CGFloat tableWidth = self.bounds.size.width; // Total width of the table area
    

    CGFloat tableY = y; // Start from the provided y offset

    // Variable for font size
    CGFloat cellFontSize = 10.0; // Adjustable font size
    
    NSArray *titles = @[@"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK"];
    NSArray *properties = @[
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"MU"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"KL"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"IN"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"CH"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"FF"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"GE"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"KK"] level]]
    ];
    [[NSColor blackColor] setFill];
    NSInteger titlesCount = [titles count];
    NSInteger cellWidth = tableWidth / (titlesCount * 2);
for (NSInteger column = 0; column < [titles count] * 2; column++) {
    
   
    NSRect cellRect = NSMakeRect(
        cellWidth * column,
        y + cellHeight,
        cellWidth * column + cellWidth,
        cellHeight
    );
    NSLog(@"CELL RECT %@, %lu, %lu", NSStringFromRect(cellRect), (unsigned long)self.bounds.size.width, cellWidth);
    [[NSColor blackColor] setFill];

    if (column % 2 == 0) {
        // Even column index, draw title
        NSString *title = [titles objectAtIndex: column / 2];
        NSDictionary *titleAttributes = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize],
            NSForegroundColorAttributeName: [NSColor blackColor]
        };
        [title drawInRect:cellRect withAttributes:titleAttributes];
    } else {
        // Odd column index, draw property
        NSString *propertyString = [properties objectAtIndex: column / 2];
        NSDictionary *propertyAttributes = @{
            NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize],
            NSForegroundColorAttributeName: [NSColor blackColor]
        };
        
        NSSize textSize = [propertyString sizeWithAttributes:propertyAttributes];

        // Draw the property text right-aligned
        CGFloat propertyX = NSMinX(cellRect) + (cellWidth - textSize.width) - 10;
        [propertyString drawAtPoint:NSMakePoint(propertyX, y + cellHeight) withAttributes:propertyAttributes];       
    }
} 
  return tableY + cellHeight;   
}

- (void)drawPortraitAtY:(CGFloat)y withHeight:(CGFloat)height {
    NSImage *portrait = [self.model portrait]; // Get the portrait image from your model

    if (!portrait) return; // Ensure there's an image to draw

    CGFloat imageWidth = 300.0; // Set the width for the image area
    
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

    // Save the current graphics state
    [NSGraphicsContext saveGraphicsState];

    // Flipping context for proper image rendering
    NSAffineTransform *transform = [NSAffineTransform transform];
    
    // Move the origin to the bottom-left of the final image rect
    [transform translateXBy:self.bounds.size.width - imageWidth yBy:y + scaledHeight];

    // Flip vertically
    [transform scaleXBy:1.0 yBy:-1.0];
    
    // Apply the transformation
    [transform concat];

    // Draw the image with the flipped transformation applied
    NSRect finalImageRect = NSMakeRect(130, 0, scaledWidth, scaledHeight); // Origin set to (0,0) after transformation
    [portrait drawInRect:finalImageRect];

    // Restore the previous graphics state
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawLineAtY:(CGFloat)y overPageWidth:(CGFloat)pageWidth {
    // Set the color to red for the line
    [[NSColor blackColor] setStroke];

    // Create a new bezier path
    NSBezierPath *linePath = [NSBezierPath bezierPath];

    // Start the line from the left margin and draw it to the right margin
    [linePath moveToPoint:NSMakePoint(0, y + 20)]; // Start at y + 10 for a small gap
    [linePath lineToPoint:NSMakePoint(pageWidth, y + 20)]; // End at the right margin

    // Set the line width
    [linePath setLineWidth:1.0];

    // Draw the line
    [linePath stroke];
}

- (void)drawTitleAtY:(CGFloat)y withTitle: (NSString *) title {
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
    CGFloat cellHeight = 16; // Height for less space between rows
    CGFloat tableWidth = self.bounds.size.width - 300; // Total width of the table area, leaving XXX for the image

    // Define column widths, adjusted for less space between them
    CGFloat firstColumnWidth = tableWidth * 0.40; // 15% of total width for odd columns (1st column)
    CGFloat secondColumnWidth = tableWidth * 0.08; // 15% of total width for even columns (2nd column)
    CGFloat thirdColumnWidth = tableWidth * 0.30; // 14% of total width for odd columns (3rd column)
    CGFloat fourthColumnWidth = tableWidth * 0.08; // 10% of total width for even columns (4th column)
    CGFloat fifthColumnWidth = tableWidth * 0.40; // 15% of total width for odd columns (5th column)
    CGFloat sixthColumnWidth = tableWidth * 0.08; // 20% of total width for even columns (6th column)

    CGFloat tableY = y; // Start from the provided y offset

    // Variable for font size
    CGFloat cellFontSize = 10.0; // Adjustable font size

    // Example data for the odd columns (static)
    NSArray *titles = @[@"Mut", @"Klugheit", @"Intuition", @"Charisma", @"Fingerfertigkeit", @"Gewandheit", @"Körperkraft", @"Tragkraft", @"Last"];
    NSArray *properties = @[
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"MU"] level]], // Using nil-coalescing to handle nil values
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"KL"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"IN"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"CH"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"FF"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"GE"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.positiveTraits objectForKey: @"KK"] level]],
        [NSNumber numberWithInteger: self.model.carryingCapacity] ?: @(0),
        self.model.encumbrance ? [NSString stringWithFormat: @"%.0f", self.model.encumbrance] : @""
    ];

    NSArray *secondTitles = @[@"Aberglaube", @"Höhenangst", @"Raumangst", @"Totenangst", @"Neugier", @"Goldgier", @"Jähzorn", @"Attacke", @"Parade"];
    NSArray *secondProperties = @[
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.negativeTraits objectForKey: @"AG"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.negativeTraits objectForKey: @"HA"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.negativeTraits objectForKey: @"RA"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.negativeTraits objectForKey: @"TA"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.negativeTraits objectForKey: @"NG"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.negativeTraits objectForKey: @"GG"] level]],
        [NSNumber numberWithInteger: [(DSATrait *)[self.model.negativeTraits objectForKey: @"JZ"] level]],
        [NSNumber numberWithInteger: self.model.attackBaseValue] ?: @(0),
        [NSNumber numberWithInteger: self.model.parryBaseValue] ?: @(0)
    ];

    NSArray *thirdTitles = @[@"Stufe", @"Abenteuerpunkte", @"Lebensenergie", @"Astralenergie", @"Karmaenergie", @"Magieresistenz", @"Ausdauer", @"Fernkampf", @"Ausweichen"];
    NSArray *thirdProperties = @[
        [NSNumber numberWithInteger: self.model.level],
        [NSNumber numberWithInteger: self.model.adventurePoints],        
        [NSNumber numberWithInteger: self.model.lifePoints],
        [NSNumber numberWithInteger: self.model.astralEnergy],
        [NSNumber numberWithInteger: self.model.karmaPoints],
        [NSNumber numberWithInteger: self.model.magicResistance],
        [NSNumber numberWithInteger: self.model.endurance],
        [NSNumber numberWithInteger: self.model.rangedCombatBaseValue],
        [NSNumber numberWithInteger: self.model.dodge]
    ];

    // Loop through all sets (assuming they all have the same count)
    NSInteger numberOfRows = titles.count; // Assuming all titles and properties arrays have the same count
    CGFloat currentRowY;
    for (NSInteger row = 0; row < numberOfRows; row++) {
        // Calculate y position for the current row
        currentRowY = tableY + row * (cellHeight + 2); // Reduce space between rows

        // Draw title (odd columns)
        NSRect titleRect1 = NSMakeRect(0, currentRowY, firstColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [titles[row] drawInRect:titleRect1 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw property (even columns) - right aligned
        NSRect propertyRect1 = NSMakeRect(5 + firstColumnWidth, currentRowY, secondColumnWidth, cellHeight);
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]};
        NSString *propertyString = properties[row];

        // Calculate the size of the string
        NSSize textSize = [propertyString sizeWithAttributes:attributes];

        // Draw the property text right-aligned
        CGFloat propertyX = NSMinX(propertyRect1) + (secondColumnWidth - textSize.width);
        [propertyString drawAtPoint:NSMakePoint(propertyX, currentRowY) withAttributes:attributes];

        // Draw second title (odd columns)
        NSRect titleRect2 = NSMakeRect(2 * 5 + firstColumnWidth + secondColumnWidth, currentRowY, thirdColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [secondTitles[row] drawInRect:titleRect2 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw second property (even columns) - right aligned
        NSRect propertyRect2 = NSMakeRect(3 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth, currentRowY, fourthColumnWidth, cellHeight);
        NSString *secondPropertyString = secondProperties[row];
        NSSize secondTextSize = [secondPropertyString sizeWithAttributes:attributes];
        CGFloat secondPropertyX = NSMinX(propertyRect2) + (fourthColumnWidth - secondTextSize.width);
        [secondPropertyString drawAtPoint:NSMakePoint(secondPropertyX, currentRowY) withAttributes:attributes];

        // Draw third title (odd columns)
        NSRect titleRect3 = NSMakeRect(4 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth, currentRowY, fifthColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [thirdTitles[row] drawInRect:titleRect3 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw third property (even columns) - right aligned
        NSRect propertyRect3 = NSMakeRect(5 * 5 + firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth + fifthColumnWidth, currentRowY, sixthColumnWidth, cellHeight);
        NSString *thirdPropertyString = thirdProperties[row];
        NSSize thirdTextSize = [thirdPropertyString sizeWithAttributes:attributes];
        CGFloat thirdPropertyX = NSMinX(propertyRect3) + (sixthColumnWidth - thirdTextSize.width);
        [thirdPropertyString drawAtPoint:NSMakePoint(thirdPropertyX, currentRowY) withAttributes:attributes];
    }
  return currentRowY;
}

// returns the current Y at the end
- (CGFloat) drawBasicCharacterInfoTableStartingAtY:(CGFloat)y withWidth: (CGFloat) tableWidth
{
//    CGFloat margin = 10.0; // Example margin
    CGFloat cellHeight = 16; // Height for less space between rows
//    CGFloat tableWidth = self.bounds.size.width - 2 * margin; // Total width of the table area

    // Define column widths, adjusted for less space between them
    CGFloat firstColumnWidth = tableWidth * 0.12; // 15% of total width for odd columns (1st column)
    CGFloat secondColumnWidth = tableWidth * 0.25; // 15% of total width for even columns (2nd column)
    CGFloat thirdColumnWidth = tableWidth * 0.13; // 14% of total width for odd columns (3rd column)
    CGFloat fourthColumnWidth = tableWidth * 0.08; // 10% of total width for even columns (4th column)
    CGFloat fifthColumnWidth = tableWidth * 0.15; // 15% of total width for odd columns (5th column)
    CGFloat sixthColumnWidth = tableWidth * 0.24; // 20% of total width for even columns (6th column)

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
        self.model.height ? [NSString stringWithFormat: @"%f", self.model.height] : @"",
        self.model.weight ? [NSString stringWithFormat: @"%f", self.model.weight] : @"",
        @""
    ];  
    
    NSArray *thirdTitles = @[@"Geburtstag", @"Geburtsgott", @"Sterne", @"Glaube", @"Stand", @"Eltern"];
    NSArray *thirdProperties = @[
        [NSString stringWithFormat: @"%lu. %@ %lu %@", 
                                          (unsigned long)[[self.model birthday] day], 
                                          [[self.model birthday] monthName], 
                                          (unsigned long)[[self.model birthday] year], 
                                          [[self.model birthday] year] > 0 ? @"AF" : @"BF"],
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
        NSRect titleRect1 = NSMakeRect(0, currentRowY, firstColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [titles[row] drawInRect:titleRect1 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw property (even columns) - right aligned
        NSRect propertyRect1 = NSMakeRect(firstColumnWidth, currentRowY, secondColumnWidth, cellHeight);
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]};
        NSString *propertyString = properties[row];

        // Calculate the size of the string
        NSSize textSize = [propertyString sizeWithAttributes:attributes];

        // Draw the property text right-aligned
        CGFloat propertyX = NSMinX(propertyRect1) + (secondColumnWidth - textSize.width);
        [propertyString drawAtPoint:NSMakePoint(propertyX - 5, currentRowY) withAttributes:attributes];

        // Draw second title (odd columns)
        NSRect titleRect2 = NSMakeRect(firstColumnWidth + secondColumnWidth, currentRowY, thirdColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [secondTitles[row] drawInRect:titleRect2 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw second property (even columns) - right aligned
        NSRect propertyRect2 = NSMakeRect(firstColumnWidth + secondColumnWidth + thirdColumnWidth, currentRowY, fourthColumnWidth, cellHeight);
        NSString *secondPropertyString = secondProperties[row];
        NSSize secondTextSize = [secondPropertyString sizeWithAttributes:attributes];
        CGFloat secondPropertyX = NSMinX(propertyRect2) + (fourthColumnWidth - secondTextSize.width);
        [secondPropertyString drawAtPoint:NSMakePoint(secondPropertyX - 5, currentRowY) withAttributes:attributes];

        // Draw third title (odd columns)
        NSRect titleRect3 = NSMakeRect(firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth, currentRowY, fifthColumnWidth, cellHeight);
        [[NSColor blackColor] setFill];
        [thirdTitles[row] drawInRect:titleRect3 withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:cellFontSize], NSForegroundColorAttributeName: [NSColor blackColor]}];

        // Draw third property (even columns) - right aligned
        NSRect propertyRect3 = NSMakeRect(firstColumnWidth + secondColumnWidth + thirdColumnWidth + fourthColumnWidth + fifthColumnWidth, currentRowY, sixthColumnWidth, cellHeight);
        NSString *thirdPropertyString = thirdProperties[row];
        NSSize thirdTextSize = [thirdPropertyString sizeWithAttributes:attributes];
        CGFloat thirdPropertyX = NSMinX(propertyRect3) + (sixthColumnWidth - thirdTextSize.width);
        [thirdPropertyString drawAtPoint:NSMakePoint(thirdPropertyX - 5, currentRowY) withAttributes:attributes];
    }
  return currentRowY;
}

- (void)drawPageSeparator:(NSUInteger)pageNumber withWidth:(CGFloat) pageWidth
{
  // Save the current graphics state
  [NSGraphicsContext saveGraphicsState];
    
  // No need for a flip transformation for the page number
  NSString *footerTextLeft = [self.model name];
  NSString *footerTextRight = [NSString stringWithFormat:_(@"Seite %lu"), (unsigned long)pageNumber];    
  // Calculate the position to draw the text
  NSSize footerRightSize = [footerTextRight sizeWithAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:8]}];
  NSPoint footerPositionLeft = NSMakePoint(0, // Adjusted for margin
                                     [self paperHeightForPage] * pageNumber - footerRightSize.height); // Adjusted for vertical positioning

  NSPoint footerPositionRight = NSMakePoint(pageWidth - footerRightSize.width, // Adjusted for margin
                                     [self paperHeightForPage] * pageNumber - footerRightSize.height); // Adjusted for vertical positioning
                                         
  [footerTextLeft drawAtPoint:footerPositionLeft
         withAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:8]}];
  [footerTextRight drawAtPoint:footerPositionRight
         withAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:8]}];
    
  // Restore the previous graphics state
  [NSGraphicsContext restoreGraphicsState];
}

@end
