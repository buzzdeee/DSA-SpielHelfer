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
#import "DSALocations.h"
#import "DSALocation.h"
#import "DSAMapCoordinate.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"

#define TILE_SIZE 32.0

@implementation DSALocalMapView

- (void)setMapArray:(NSArray<NSArray<DSALocalMapTile *> *> *)mapArray {
    _mapArray = mapArray;
    NSLog(@"DSALocalMapView setMapArray after setting mapArray");
    [self updateTooltips];
    NSLog(@"DSALocalMapView setMapArray after setting tooltips");
    [self setNeedsDisplay:YES]; // Neuzeichnen erzwingen
    NSLog(@"DSALocalMapView setMapArray after setNeedsDisplay");
    
}

- (NSSize)intrinsicContentSize {
    NSInteger rows = self.mapArray.count;
    NSInteger cols = (rows > 0) ? [self.mapArray[0] count] : 0;
    return NSMakeSize(cols * TILE_SIZE, rows * TILE_SIZE);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGFloat tileSize = TILE_SIZE;
    NSInteger rows = self.mapArray.count;
    if (rows == 0) return;

    // Optional: Antialiasing ausschalten für pixelgenaue Kanten
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];

    for (NSInteger y = 0; y < rows; y++) {
        NSArray *row = self.mapArray[y];
        for (NSInteger x = 0; x < row.count; x++) {
            DSALocalMapTile *tile = row[x];
            NSString *type = tile.type;
            DSADirection door = DSADirectionInvalid;
            if ([tile isKindOfClass: [DSALocalMapTileBuilding class]])
              {
                door = [(DSALocalMapTileBuilding *)tile door];
              }

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
            if (door != DSADirectionInvalid) {
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
    if ([type isEqualToString:@"Hafen"]) return [NSColor redColor];       
    if ([type isEqualToString:@"Haus"]) return [NSColor brownColor];
    if ([type isEqualToString:@"Krämer"]) return [NSColor lightGrayColor];
    if ([type isEqualToString:@"Waffenhändler"]) return [NSColor lightGrayColor];
    if ([type isEqualToString:@"Heiler"]) return [NSColor purpleColor];
    if ([type isEqualToString:@"Schmied"]) return [NSColor colorWithCalibratedRed:0.0
                                                                            green:0.39
                                                                             blue:0.0
                                                                            alpha:1.0];
    if ([type isEqualToString:@"Tempel"]) return [NSColor magentaColor];    
    if ([type isEqualToString:@"Taverne"]) return [NSColor orangeColor];
    if ([type isEqualToString:@"Herberge"]) return [NSColor cyanColor];
    return [NSColor blackColor]; // Default für unbekannte Tiles
}

- (void)drawDoorInRect:(NSRect)rect direction:(DSADirection)dir {
    CGFloat size = 6.0;
    NSRect doorRect;

    if (dir == DSADirectionNorth) {
        doorRect = NSMakeRect(NSMidX(rect) - size / 2, NSMaxY(rect) - size, size, size);
    } else if (dir == DSADirectionSouth) {
        doorRect = NSMakeRect(NSMidX(rect) - size / 2, NSMinY(rect), size, size);
    } else if (dir == DSADirectionWest) {
        doorRect = NSMakeRect(NSMinX(rect), NSMidY(rect) - size / 2, size, size);
    } else if (dir == DSADirectionEast) {
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

    CGFloat tileSize = TILE_SIZE;
    NSInteger rows = self.mapArray.count;

    for (NSInteger y = 0; y < rows; y++) {
        NSArray *row = self.mapArray[y];
        NSLog(@"DSALocalMapView updateToolTips y %@", [NSNumber numberWithInteger: y]);
        for (NSInteger x = 0; x < row.count; x++) {
            NSLog(@"DSALocalMapView updateToolTips x %@", [NSNumber numberWithInteger: x]);
            DSALocalMapTile *tile = row[x];
            NSString *tooltip = [self tooltipForTile:tile];
            if (tooltip) {
                // Y-Koordinaten beachten, da y = 0 oben ist!
                NSRect tileRect = NSMakeRect(x * tileSize, (rows - 1 - y) * tileSize, tileSize, tileSize);
                [self addToolTipRect:tileRect owner:tooltip userData:NULL];
            }
        }
    }
}

- (NSString *)tooltipForTile:(DSALocalMapTile *)tile {
    NSString *type = tile.type;
    if ([type isEqualToString:@"Krämer"]) {
        NSString *npc = [(DSALocalMapTileBuildingShop*)tile npc] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"Krämer: %@", npc];
    }
    if ([type isEqualToString:@"Waffenhändler"]) {
        NSString *npc = [(DSALocalMapTileBuildingShop*)tile npc] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"Waffenhändler: %@", npc];
    }    
    if ([type isEqualToString:@"Haus"]) {
        NSString *npc = [(DSALocalMapTileBuildingHealer*)tile npc] ?: nil;
        return npc ? [NSString stringWithFormat:@"Haus: %@", npc] : nil;
    }    
    if ([type isEqualToString:@"Herberge"]) {
        NSString *name = [(DSALocalMapTileBuildingInn*)tile name] ?: @"(unbenannt)";
        return [NSString stringWithFormat:@"Herberge: %@", name];
    }
    if ([type isEqualToString:@"Taverne"]) {
        NSString *name = [(DSALocalMapTileBuildingInn*)tile name] ?: @"(unbenannt)";
        return [NSString stringWithFormat:@"Taverne: %@", name];
    }
    if ([type isEqualToString:@"Heiler"]) {
        NSString *npc = [(DSALocalMapTileBuildingHealer*)tile npc] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"Heiler: %@", npc];
    }
    if ([type isEqualToString:@"Schmied"]) {
        NSString *npc = [(DSALocalMapTileBuildingSmith*)tile npc] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"Schmied: %@", npc];
    }
    if ([type isEqualToString:@"Tempel"]) {
        NSString *god = [(DSALocalMapTileBuildingTemple*)tile god] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"%@ Tempel", god];
    }                
    if ([type isEqualToString:@"Wegweiser"]) {
        NSArray *destinations = [(DSALocalMapTileRoute*)tile destinations];
        if (destinations.count > 0) {
            return [NSString stringWithFormat:@"Wegweiser nach: %@", [destinations componentsJoinedByString:@", "]];
        }
    }
    if ([type isEqualToString:@"Hafen"]) {
        NSArray *destinations = [(DSALocalMapTileRoute*)tile destinations];
        if (destinations.count > 0) {
            return [NSString stringWithFormat:@"Hafen nach: %@", [destinations componentsJoinedByString:@", "]];
        }
    }    
    return nil;
}
@end
// End of DSALocalMapView

@implementation DSALocalMapViewAdventure

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [[self window] makeFirstResponder:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect]; // ruft drawRect aus DSALocalMapView auf

    if (!self.groupPosition) return;

    DSAMapCoordinate *coord = self.groupPosition.mapCoordinate;
    NSInteger x = coord.x;
    NSInteger y = coord.y;

    CGFloat tileSize = TILE_SIZE;
    NSInteger tilesY = self.mapArray.count;

    NSRect markerRect = NSMakeRect(x * tileSize + tileSize / 4.0,
                                   (tilesY - 1 - y) * tileSize + tileSize / 4.0,
                                   tileSize / 2.0,
                                   tileSize / 2.0);

    [[NSColor systemRedColor] set];
    NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:markerRect];
    [circle fill];

    // Richtungspfeil
    NSPoint center = NSMakePoint(NSMidX(markerRect), NSMidY(markerRect));
    CGFloat arrowLength = tileSize / 2.0;
    NSPoint tip = center;

    switch (self.groupHeading) {
        case DSADirectionNorth:     tip.y += arrowLength; break;
        case DSADirectionSouth:     tip.y -= arrowLength; break;
        case DSADirectionEast:      tip.x += arrowLength; break;
        case DSADirectionWest:      tip.x -= arrowLength; break;
        case DSADirectionNortheast: tip.x += arrowLength * 0.7; tip.y += arrowLength * 0.7; break;
        case DSADirectionSoutheast: tip.x += arrowLength * 0.7; tip.y -= arrowLength * 0.7; break;
        case DSADirectionSouthwest: tip.x -= arrowLength * 0.7; tip.y -= arrowLength * 0.7; break;
        case DSADirectionNorthwest: tip.x -= arrowLength * 0.7; tip.y += arrowLength * 0.7; break;
        default: break;
    }

    [[NSColor blackColor] setStroke];
    NSBezierPath *arrow = [NSBezierPath bezierPath];
    [arrow moveToPoint:center];
    [arrow lineToPoint:tip];
    [arrow setLineWidth:2.0];
    [arrow stroke];
}

- (void)setGroupPosition:(DSAPosition *)position heading:(DSADirection)heading {
    NSLog(@"DSALocalMapViewAdventure setGroupPosition called!");
    self.groupPosition = position;
    self.groupHeading = heading;
    [self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)event {
    NSString *chars = [event charactersIgnoringModifiers];
    if (chars.length == 0) return;

    unichar keyChar = [chars characterAtIndex:0];

    DSADirection direction = DSADirectionInvalid;
    switch (keyChar) {
        case NSUpArrowFunctionKey:    direction = DSADirectionNorth; break;
        case NSDownArrowFunctionKey:  direction = DSADirectionSouth; break;
        case NSLeftArrowFunctionKey:  direction = DSADirectionWest;  break;
        case NSRightArrowFunctionKey: direction = DSADirectionEast;  break;
    }

    if (direction != DSADirectionInvalid) {
        [self moveGroupInDirection:direction];
    } else {
        [super keyDown:event];
    }
}

- (void)moveGroupInDirection:(DSADirection)direction {
    DSAPosition *current = self.adventure.activeGroup.position;
    DSAPosition *newPosition = [current positionByMovingInDirection:direction steps:1];

    // Get current and target tiles
    DSALocalMapTile *fromTile = [self tileAtPosition:current];
    DSALocalMapTile *toTile = [self tileAtPosition:newPosition];

    // Check if destination is walkable
    if (!toTile.walkable) {
        NSBeep();
        return;
    }

    // EXITING a building?
    if ([fromTile isKindOfClass:[DSALocalMapTileBuilding class]]) {
        DSALocalMapTileBuilding *buildingTile = (DSALocalMapTileBuilding *)fromTile;
        if (direction != buildingTile.door) {
            NSLog(@"Cannot exit building facing %@ by moving %@",
                  DSADirectionToString(buildingTile.door),
                  DSADirectionToString(direction));
            NSBeep();
            return;
        }
    }

    // ENTERING a building?
    if ([toTile isKindOfClass:[DSALocalMapTileBuilding class]]) {
        DSALocalMapTileBuilding *buildingTile = (DSALocalMapTileBuilding *)toTile;
        DSADirection requiredApproach = [self oppositeDirection:buildingTile.door];
        if (direction != requiredApproach) {
            NSLog(@"Cannot enter building with door %@ by moving %@ (required: %@)",
                  DSADirectionToString(buildingTile.door),
                  DSADirectionToString(direction),
                  DSADirectionToString(requiredApproach));
            NSBeep();
            return;
        }
    }

    // Move group
    self.adventure.activeGroup.position = newPosition;
    [self setGroupPosition:newPosition];
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureLocationUpdated" object:self];
}

- (DSALocalMapTile *)tileAtPosition:(DSAPosition *)position {
    DSALocations *locations = [DSALocations sharedInstance];
    DSALocalMapLevel *level = [locations getLocalLocationMapWithName:position.localLocationName
                                                             ofLevel:position.mapCoordinate.level];
    return [level tileAtCoordinate:position.mapCoordinate];
}

- (DSADirection)oppositeDirection:(DSADirection)direction {
    switch (direction) {
        case DSADirectionNorth: return DSADirectionSouth;
        case DSADirectionSouth: return DSADirectionNorth;
        case DSADirectionEast:  return DSADirectionWest;
        case DSADirectionWest:  return DSADirectionEast;
        case DSADirectionNortheast: return DSADirectionSouthwest;
        case DSADirectionSoutheast: return DSADirectionNorthwest;
        case DSADirectionSouthwest: return DSADirectionNortheast;
        case DSADirectionNorthwest: return DSADirectionSoutheast;
        default: return DSADirectionInvalid;
    }
}

@end
