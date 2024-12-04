/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-03 20:47:44 +0100 by sebastia

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

#import "DSAPannableScrollView.h"

@implementation DSAPannableScrollView

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"DSAPannableScrollView mouseDown");
    self.isDragging = YES;
    self.dragStartPoint = [event locationInWindow];
    self.initialOrigin = [self.contentView bounds].origin;
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.isDragging) return;

    NSLog(@"DSAPannableScrollView mouseDragged");
    NSPoint currentPoint = [event locationInWindow];
    CGFloat dx = currentPoint.x - self.dragStartPoint.x;
    CGFloat dy = currentPoint.y - self.dragStartPoint.y;

    // Calculate the new origin
    NSPoint newOrigin = NSMakePoint(self.initialOrigin.x - dx, self.initialOrigin.y - dy);

    // Clamp to ensure within bounds
    NSRect imageBounds = [self.documentView bounds];
    NSRect visibleRect = [self.contentView bounds];
    
    newOrigin.x = MIN(MAX(newOrigin.x, 0), imageBounds.size.width - visibleRect.size.width);
    newOrigin.y = MIN(MAX(newOrigin.y, 0), imageBounds.size.height - visibleRect.size.height);

    // Scroll the content view to the new origin
    [self.contentView scrollToPoint:newOrigin];
    [self reflectScrolledClipView:[self contentView]];
}

- (void)mouseUp:(NSEvent *)event {
    NSLog(@"DSAPannableScrollView mouseUp");
    self.isDragging = NO;
}

@end