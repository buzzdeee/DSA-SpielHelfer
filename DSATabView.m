/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-15 22:48:08 +0200 by sebastia

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

#import "DSATabView.h"
#import "DSATabViewItem.h"

@implementation DSATabView
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSUInteger tabCount = [self numberOfTabViewItems];
    CGFloat xPosition = 0;
    
    NSDictionary *boldAttributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]};
    NSDictionary *regularAttributes = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};
    
    // Draw custom tab labels
    for (NSUInteger index = 0; index < tabCount; index++) {
        NSTabViewItem *item = [self tabViewItemAtIndex:index];
        NSString *title = [item label];
        
        // Calculate title size
        NSDictionary *attributes = ([item isEqual:self.selectedTabViewItem]) ? boldAttributes : regularAttributes;
        NSSize titleSize = [title sizeWithAttributes:attributes];
        
        CGFloat tabWidth = titleSize.width + 20.0; // Add padding
        NSRect tabRect = NSMakeRect(xPosition, 0, tabWidth, 22.0); // Adjust height if needed
        
        // Adjust for flipped view
        NSRect titleRect = [self flippedRectForRect:tabRect withTitleSize:titleSize];
        
        // Draw custom label
        [[NSColor blackColor] set];
        [title drawInRect:titleRect withAttributes:attributes];
        
        // Move position for next tab
        xPosition += tabWidth;
    }
}

- (NSRect)flippedRectForRect:(NSRect)rect withTitleSize:(NSSize)titleSize {
    // Adjust the rect for flipped coordinate system
    NSRect flippedRect = rect;
    flippedRect.origin.y = NSHeight(self.bounds) - (NSMaxY(rect) + titleSize.height); // Invert Y coordinate and adjust for title height
    return flippedRect;
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    
    NSUInteger tabCount = [self numberOfTabViewItems];
    CGFloat xPosition = 0;
    
    for (NSUInteger index = 0; index < tabCount; index++) {
        NSTabViewItem *item = [self tabViewItemAtIndex:index];
        
        // Calculate tab width
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};
        NSString *title = [item label];
        NSSize titleSize = [title sizeWithAttributes:attributes];
        CGFloat tabWidth = titleSize.width + 20.0; // Add padding
        
        NSRect tabRect = NSMakeRect(xPosition, 0, tabWidth, 22.0);
        NSRect flippedTabRect = [self flippedRectForRect:tabRect withTitleSize:titleSize];
        
        // Check if click location is within tab bounds
        if (NSPointInRect(clickLocation, flippedTabRect)) {
            [self selectTabViewItemAtIndex:index];
            [self setNeedsDisplay:YES];
            break;
        }
        
        // Move position for next tab
        xPosition += tabWidth;
    }
}

@end
