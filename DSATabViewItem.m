/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-16 19:59:06 +0200 by sebastia

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

#import "DSATabViewItem.h"

@implementation DSATabViewItem

- (void)drawTabTitleInRect:(NSRect)tabRect selected:(BOOL)isSelected {
    NSDictionary *attributes;
    
    // Set font and color based on whether the tab is selected
    if (isSelected) {
        attributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]],
                       NSForegroundColorAttributeName: [NSColor blackColor]};
    } else {
        attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]],
                       NSForegroundColorAttributeName: [NSColor grayColor]};
    }

    NSString *title = [self label];
    NSSize titleSize = [title sizeWithAttributes:attributes];

    // Position the title at the center of the tab, aligned with the original tab title area
    NSRect titleRect = NSMakeRect(NSMidX(tabRect) - titleSize.width / 2,
                                  NSMidY(tabRect) - titleSize.height / 2,
                                  titleSize.width,
                                  titleSize.height);

    // Draw the tab title with the appropriate attributes
    [title drawInRect:titleRect withAttributes:attributes];
}

@end
