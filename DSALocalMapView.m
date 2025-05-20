/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-18 22:54:38 +0200 by sebastia

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

#import "DSALocalMapView.h"
#import "Utils.h"

@implementation DSALocalMapView

- (void)setMapArray:(NSArray<NSArray<NSDictionary *> *> *)mapArray {
    _mapArray = mapArray;
    [self updateTooltips];
    [self setNeedsDisplay:YES]; // Neuzeichnen erzwingen
}

- (NSSize)intrinsicContentSize {
    NSInteger rows = self.mapArray.count;
    NSInteger cols = (rows > 0) ? [self.mapArray[0] count] : 0;
    return NSMakeSize(cols * 32.0, rows * 32.0);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGFloat tileSize = 32.0;
    NSInteger rows = self.mapArray.count;
    if (rows == 0) return;

    NSInteger cols = self.mapArray[0].count;

    // Optional: Antialiasing ausschalten für pixelgenaue Kanten
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];

    for (NSInteger y = 0; y < rows; y++) {
        NSArray *row = self.mapArray[y];
        for (NSInteger x = 0; x < row.count; x++) {
            NSDictionary *tile = row[x];
            NSString *type = tile[@"type"];
            NSString *door = tile[@"door"];

            NSColor *color = [self colorForTileType:type];
            NSRect tileRect = NSMakeRect(x * tileSize, (rows - 1 - y) * tileSize, tileSize, tileSize);

            // Fläche füllen
            [color set];
            NSBezierPath *fillPath = [NSBezierPath bezierPathWithRect:tileRect];
            [fillPath fill];

            // Kachelrahmen zeichnen – komplett innerhalb der Kachel
            NSRect strokeRect = NSInsetRect(tileRect, 0.5, 0.5);
            [[NSColor blackColor] setStroke];
            NSBezierPath *strokePath = [NSBezierPath bezierPathWithRect:strokeRect];
            [strokePath setLineWidth:1.0];
            [strokePath stroke];

            // Tür zeichnen
            if (door) {
                [self drawDoorInRect:tileRect direction:door];
            }
        }
    }
}

- (NSColor *)colorForTileType:(NSString *)type {
    if ([type isEqualToString:@"Gras"]) return [NSColor greenColor];
    if ([type isEqualToString:@"Weg"]) return [NSColor darkGrayColor];
    if ([type isEqualToString:@"Wasser"]) return [NSColor blueColor];
    if ([type isEqualToString:@"Wegweiser"]) return [NSColor redColor];        
    if ([type isEqualToString:@"Haus"]) return [NSColor brownColor];
    if ([type isEqualToString:@"Krämer"]) return [NSColor lightGrayColor];
    if ([type isEqualToString:@"Heiler"]) return [NSColor purpleColor];
    if ([type isEqualToString:@"Taverne"]) return [NSColor orangeColor];
    if ([type isEqualToString:@"Herberge"]) return [NSColor cyanColor];
    return [NSColor blackColor]; // Default für unbekannte Tiles
}

- (void)drawDoorInRect:(NSRect)rect direction:(NSString *)dir {
    CGFloat size = 6.0;
    NSRect doorRect;

    if ([dir isEqualToString:@"N"]) {
        doorRect = NSMakeRect(NSMidX(rect) - size / 2, NSMaxY(rect) - size, size, size);
    } else if ([dir isEqualToString:@"S"]) {
        doorRect = NSMakeRect(NSMidX(rect) - size / 2, NSMinY(rect), size, size);
    } else if ([dir isEqualToString:@"W"]) {
        doorRect = NSMakeRect(NSMinX(rect), NSMidY(rect) - size / 2, size, size);
    } else if ([dir isEqualToString:@"O"]) {
        doorRect = NSMakeRect(NSMaxX(rect) - size, NSMidY(rect) - size / 2, size, size);
    } else {
        return; // Ungültige Richtung
    }

    [[NSColor blackColor] set];
    NSBezierPath *doorPath = [NSBezierPath bezierPathWithRect:doorRect];
    [doorPath fill];
}

- (void)updateTooltips {
    [self removeAllToolTips];

    CGFloat tileSize = 32.0;
    NSInteger rows = self.mapArray.count;

    for (NSInteger y = 0; y < rows; y++) {
        NSArray *row = self.mapArray[y];
        for (NSInteger x = 0; x < row.count; x++) {
            NSDictionary *tile = row[x];
            NSString *tooltip = [self tooltipForTile:tile];
            if (tooltip) {
                // Y-Koordinaten beachten, da y = 0 oben ist!
                NSRect tileRect = NSMakeRect(x * tileSize, (rows - 1 - y) * tileSize, tileSize, tileSize);
                [self addToolTipRect:tileRect owner:tooltip userData:NULL];
            }
        }
    }
}

- (NSString *)tooltipForTile:(NSDictionary *)tile {
    NSString *type = tile[@"type"];
    if ([type isEqualToString:@"Krämer"]) {
        NSString *npc = tile[@"npc"] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"Krämer: %@", npc];
    }
    if ([type isEqualToString:@"Haus"]) {
        NSString *npc = tile[@"npc"] ?: nil;
        return npc ? [NSString stringWithFormat:@"Haus: %@", npc] : nil;
    }    
    if ([type isEqualToString:@"Herberge"]) {
        NSString *name = tile[@"name"] ?: @"(unbenannt)";
        return [NSString stringWithFormat:@"Herberge: %@", name];
    }
    if ([type isEqualToString:@"Taverne"]) {
        NSString *name = tile[@"name"] ?: @"(unbenannt)";
        return [NSString stringWithFormat:@"Taverne: %@", name];
    }
    if ([type isEqualToString:@"Heiler"]) {
        NSString *npc = tile[@"npc"] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"Heiler: %@", npc];
    }       
    if ([type isEqualToString:@"Wegweiser"]) {
        NSArray *destinations = tile[@"destinations"];
        if (destinations.count > 0) {
            return [NSString stringWithFormat:@"Wegweiser nach: %@", [destinations componentsJoinedByString:@", "]];
        }
    }
    return nil;
}

@end
