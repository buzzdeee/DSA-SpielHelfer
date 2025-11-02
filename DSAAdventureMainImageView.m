/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-11-01 22:42:13 +0100 by sebastia

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

#import "DSAAdventureMainImageView.h"

@implementation DSAAdventureMainImageView

- (void)updateLocationLabel:(NSString *)text {
    NSTextField *infoLabel = [self viewWithTag:1001];
    if (!infoLabel) {
        infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(5, 5, 12, 14)];
        infoLabel.backgroundColor = [NSColor blackColor];
        infoLabel.drawsBackground = YES;
        infoLabel.textColor = [NSColor whiteColor];
        infoLabel.font = [NSFont boldSystemFontOfSize:12];
        infoLabel.bordered = NO;
        infoLabel.bezeled = NO;
        infoLabel.editable = NO;
        infoLabel.selectable = NO;
        infoLabel.focusRingType = NSFocusRingTypeNone;
        infoLabel.tag = 1001;

        [self addSubview:infoLabel];
    }

    if (text && text.length > 0) {
        infoLabel.stringValue = text;

        NSDictionary *attrs = @{ NSFontAttributeName: infoLabel.font };
        NSSize size = [text sizeWithAttributes:attrs];

        infoLabel.frame = NSMakeRect(5, 5, size.width + 4, size.height);
        infoLabel.hidden = NO;
    } else {
        infoLabel.hidden = YES;
    }
}

@end