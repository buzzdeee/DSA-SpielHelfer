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
#import "DSAShoppingCart.h"
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

- (void)setObject:(DSAObject *)object {
    _object = object;

    NSMutableArray<NSString *> *tooltipLines = [NSMutableArray array];

    if (object.name.length > 0) {
        [tooltipLines addObject:object.name];
    }

    if (object.price > 0) {
        float price = [self priceForObject: object];
        [tooltipLines addObject:[NSString stringWithFormat:@"Preis: %.2f Silber", price]];
    }

    if (object.weight > 0) {
        [tooltipLines addObject:[NSString stringWithFormat:@"Gewicht: %.2f Unzen", object.weight]];
    }

    NSString *tooltipText = [tooltipLines componentsJoinedByString:@"\n"];
    [self setToolTip:tooltipText.length > 0 ? tooltipText : nil];

    [self setNeedsDisplay:YES];
}

- (float)priceForObject:(DSAObject *)object {
    NSLog(@"DSAShopViewController updatePage called!!!");
    float price = object.price;
    if (self.mode == DSAShopModeBuy) {
        return price;
    } else {
        return price * 0.2f;   // 20% of normal price is selling price
    }
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
    [super mouseDown:event];
    NSLog(@"DSAShopItemButton mouseDown detected, current button.mode = %ld BUY MODE: %ld", (long)self.mode, DSAShopModeBuy);
    [self addToShoppingCart];
}

- (void)rightMouseDown:(NSEvent *)event {
    [super rightMouseDown:event];

    [self removeFromShoppingCart];

}

-(void)addToShoppingCart
{
    if (self.mode == DSAShopModeSell && self.quantity == 0)
      {
        NSLog(@"Can't add more items to shopping cart, no more available.");
        return;
      }
    if (self.mode == DSAShopModeBuy && self.shoppingCart.totalSum + self.object.price > self.maxSilber)
      {
        NSLog(@"Can't add item to shopping cart, not enough money.");
        return;
      }
    float price = [self priceForObject: self.object];
    NSLog(@"DSAShopItemButton addToShoppingCart: the object: %@", self.object);
    [self.shoppingCart addObject:self.object count:1 price: price ?: 0 slot: self.slotID];
    if (self.mode == DSAShopModeSell)
      {
        self.quantity -= 1;
      }
    NSLog(@"DSAShopItemButton addToShoppingCart: %@ hinzugefügt, Count: %ld", self.object, (long)[self.shoppingCart countForObject:self.object andSlotID: self.slotID]);
    [self setNeedsDisplay:YES];
}

-(void)removeFromShoppingCart
{
    if ([self.shoppingCart countForObject:self.object andSlotID: self.slotID] > 0) {
        [self.shoppingCart removeObject:self.object count:1 slot: self.slotID];
        if (self.mode == DSAShopModeSell)
          {
            self.quantity += 1;
          }        
        NSLog(@"%@ entfernt – Count: %ld", self.object.name, (long)[self.shoppingCart countForObject:self.object andSlotID: self.slotID]);
        [self setNeedsDisplay:YES];
    } else {
        NSLog(@"%@ ist nicht im Warenkorb", self.object.name);
    }
    [self setNeedsDisplay:YES];
}

- (void)updateDisplay {
    [self updateQuantityLabel];
    [self setNeedsDisplay:YES];
}

- (void)updateQuantityLabel {
    NSTextField *quantityLabel = [self viewWithTag:999];
    if (!quantityLabel) {
        quantityLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(1, 1, 30, 19)];
        quantityLabel.editable = NO;
        quantityLabel.bordered = NO;
        quantityLabel.bezeled = NO;
        quantityLabel.focusRingType = NSFocusRingTypeNone;
        quantityLabel.backgroundColor = [NSColor blackColor];
        quantityLabel.drawsBackground = YES;
        quantityLabel.textColor = [NSColor redColor];
        quantityLabel.font = [NSFont boldSystemFontOfSize:12];
        quantityLabel.alignment = NSTextAlignmentLeft;
        quantityLabel.tag = 999;
        [self addSubview:quantityLabel];
    }

    NSInteger cartCount = [self.shoppingCart countForObject:self.object andSlotID: self.slotID];
    if (cartCount > 0) {
        NSString *quantityString = [NSString stringWithFormat:@"%ld", (long)cartCount];
        quantityLabel.stringValue = quantityString;
        quantityLabel.hidden = NO;

        NSDictionary *attributes = @{NSFontAttributeName: quantityLabel.font};
        NSSize textSize = [quantityString sizeWithAttributes:attributes];
        quantityLabel.frame = NSMakeRect(1, 1, textSize.width, textSize.height);
    } else {
        quantityLabel.hidden = YES;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // NSLog(@"DSAShopItemButton drawRect self.object: %@ %@", [self.object class], self.object);
    
    if (self.object.icon) {
        NSImage *iconImage = [NSImage imageNamed:[NSString stringWithFormat: @"%@-128x128", self.object.icon]];

        if (iconImage) {
            NSRect imageRect = self.bounds;

            // Save current graphics state
            [[NSGraphicsContext currentContext] saveGraphicsState];

            // Flip context vertically
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy:0 yBy:NSHeight(imageRect)];
            [transform scaleXBy:1.0 yBy:-1.0];
            [transform concat];

            // Draw flipped image
            [iconImage drawInRect:imageRect
                         fromRect:NSZeroRect
                        operation: NSCompositeSourceOver
                         fraction:1.0];

            // Restore original graphics state
            [[NSGraphicsContext currentContext] restoreGraphicsState];
        }
    }

    if (self.isHovered) {
        [[NSColor colorWithCalibratedWhite:0 alpha:0.1] set];
        NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
    }
    [self updateQuantityLabel];
}

@end