/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-09 22:49:05 +0200 by sebastia

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

#import "DSAShopItemButton.h"
#import "DSAObject.h"

@implementation DSAShopItemButton {
    NSTrackingRectTag _trackingTag;
}

- (void)updateTrackingAreas {
    if (_trackingTag) {
        [self removeTrackingRect:_trackingTag];
        _trackingTag = 0;
    }
    _trackingTag = [self addTrackingRect:self.bounds
                                  owner:self
                               userData:nil
                           assumeInside:NO];
}

// Method below may or may not be superfluous, or even erroneous???
- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self updateTrackingAreas];
}

- (void)mouseEntered:(NSEvent *)event {
    self.isHovered = YES;
    [self setNeedsDisplay:YES];
    // Option: Show tooltip or update detail view
}

- (void)mouseExited:(NSEvent *)event {
    self.isHovered = NO;
    [self setNeedsDisplay:YES];
    // Option: Hide tooltip or revert detail view
}

- (void)mouseDown:(NSEvent *)event {
    if (event.type == NSEventTypeRightMouseDown || (event.modifierFlags & NSEventModifierFlagControl)) {
        // Custom context menu?
        [self showContextMenuAtPoint:[self convertPoint:event.locationInWindow fromView:nil]];
    } else {
        [super mouseDown:event];
    }
}

- (void)showContextMenuAtPoint:(NSPoint)point {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu addItemWithTitle:@"Kaufen" action:@selector(buy:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Details anzeigen" action:@selector(showDetails:) keyEquivalent:@""];
    [NSMenu popUpContextMenu:menu withEvent:[NSApp currentEvent] forView:self];
}

- (void)updateDisplay {
    // Hier kannst du z.B. den Button-Titel setzen:
    if (self.object) {
        self.title = @"X"; // [NSString stringWithFormat:@"%@ x%ld", self.object.name, (long)self.cartCount];
    } else {
        self.title = @"";
    }
    [self setNeedsDisplay:YES];
}

// Optional: Eigene Darstellung
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

/*    if (self.object.icon) {
        NSImage *iconImage = [NSImage imageNamed:self.object.icon];
        [iconImage drawInRect:self.bounds];
    }

    if (self.isHovered) {
        [[NSColor colorWithCalibratedWhite:0 alpha:0.1] set];
        NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
    } */
}
@end