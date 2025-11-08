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
#import "DSAAdventureClock.h"
#import "DSAEvent.h"

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
    if ([type isEqualToString:@"Fähre"]) return [NSColor redColor];       
    if ([type isEqualToString:@"Haus"]) return [NSColor brownColor];
    if ([type isEqualToString:@"Krämer"]) return [NSColor lightGrayColor];
    if ([type isEqualToString:@"Waffenhändler"]) return [NSColor lightGrayColor];
    if ([type isEqualToString:@"Kräuterhändler"]) return [NSColor lightGrayColor];    
    if ([type isEqualToString:@"Heiler"]) return [NSColor purpleColor];
    if ([type isEqualToString:@"Schmied"]) return [NSColor colorWithCalibratedRed:0.0
                                                                            green:0.39
                                                                             blue:0.0
                                                                            alpha:1.0];
    if ([type isEqualToString:@"Tempel"]) return [NSColor magentaColor];    
    if ([type isEqualToString: DSALocalMapTileBuildingInnTypeTaverne]) return [NSColor orangeColor];
    if ([type isEqualToString: DSALocalMapTileBuildingInnTypeHerberge]) return [NSColor cyanColor];
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
    if ([type isEqualToString:@"Kräuterhändler"]) {
        NSString *npc = [(DSALocalMapTileBuildingShop*)tile npc] ?: @"(unbekannt)";
        return [NSString stringWithFormat:@"Kräuterhändler: %@", npc];
    }      
    if ([type isEqualToString:@"Haus"]) {
        NSString *npc = [(DSALocalMapTileBuildingHealer*)tile npc] ?: nil;
        return npc ? [NSString stringWithFormat:@"Haus: %@", npc] : nil;
    }    
    if ([type isEqualToString: DSALocalMapTileBuildingInnTypeHerberge]) {
        NSString *name = [(DSALocalMapTileBuildingInn*)tile name] ?: @"(unbenannt)";
        return [NSString stringWithFormat:@"Herberge: %@", name];
    }
    if ([type isEqualToString: DSALocalMapTileBuildingInnTypeTaverne]) {
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
    if ([type isEqualToString:@"Fähre"]) {
        NSArray *destinations = [(DSALocalMapTileRoute*)tile destinations];
        if (destinations.count > 0) {
            return [NSString stringWithFormat:@"Fähre nach: %@", [destinations componentsJoinedByString:@", "]];
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
    
    if (self.window) {
        // View added to a window — add observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLocationUpdate:)
                                                     name:@"DSAAdventureLocationUpdated"
                                                   object:nil];
    } else {
        // View removed from window — remove observer
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"DSAAdventureLocationUpdated"
                                                      object:nil];
    }    
    
    [[self window] makeFirstResponder:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Erst die Standardkarte zeichnen (inkl. aller Tiles)
    [super drawRect:dirtyRect];

    NSInteger tileSize = TILE_SIZE;
    NSInteger tilesY = self.mapArray.count;
    NSInteger tilesX = (tilesY > 0) ? [self.mapArray[0] count] : 0;

    NSString *locationName = self.adventure.activeGroup.position.localLocationName;
    NSInteger level = self.adventure.activeGroup.position.mapCoordinate.level;
    NSMutableSet *discovered = self.adventure.discoveredCoordinates[locationName];

    for (NSInteger y = 0; y < tilesY; y++) {
        //NSArray *row = self.mapArray[y];
        for (NSInteger x = 0; x < tilesX; x++) {
            DSAMapCoordinate *coord = [[DSAMapCoordinate alloc] initWithX:x y:y level:level];
            if (![discovered containsObject:coord]) {
                // Nicht entdeckt → Schwarz übermalen
                NSRect tileRect = NSMakeRect(x * tileSize,
                                             (tilesY - 1 - y) * tileSize,
                                             tileSize, tileSize);
                [[NSColor blackColor] setFill];
                NSRectFillUsingOperation(tileRect, NSCompositeSourceOver);
            }
        }
    }

    // Andere Gruppen auf gleicher Karte → Roter Punkt
    for (DSAAdventureGroup *group in self.adventure.groups) {
        if (group == self.adventure.activeGroup) continue;

        DSAPosition *pos = group.position;
        if (![pos.localLocationName isEqualToString:locationName]) continue;
        if (pos.mapCoordinate.level != level) continue;

        NSInteger x = pos.mapCoordinate.x;
        NSInteger y = pos.mapCoordinate.y;
        NSPoint center = NSMakePoint(x * tileSize + tileSize / 2.0,
                                     (tilesY - 1 - y) * tileSize + tileSize / 2.0);
        CGFloat radius = tileSize * 0.2;

        NSRect circleRect = NSMakeRect(center.x - radius, center.y - radius,
                                       radius * 2, radius * 2);

        [[NSColor systemRedColor] setFill];
        [[NSBezierPath bezierPathWithOvalInRect:circleRect] fill];
    }    
    
    // Danach Marker und Pfeil wie gewohnt (optional):
    [self drawGroupMarker];
}

- (void)drawGroupMarker {
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
}

- (void)discoverVisibleTilesAroundPosition:(DSAPosition *)position {
    DSAAdventure *adventure = self.adventure;
    if (!adventure) return;

    DSAMapCoordinate *center = position.mapCoordinate;
    NSString *mapName = position.localLocationName;

    for (NSInteger dx = -1; dx <= 1; dx++) {
        for (NSInteger dy = -1; dy <= 1; dy++) {
            DSAMapCoordinate *coord = [[DSAMapCoordinate alloc] initWithX:center.x + dx
                                                                          y:center.y + dy
                                                                      level:center.level];
            [adventure discoverCoordinate:coord forLocation:mapName];
        }
    }
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

- (void)moveGroupInDirection: (DSADirection) direction
{
  DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
  DSAAdventureGroup *activeGroup = adventure.activeGroup;
  [activeGroup moveGroupInDirection: direction];
}

- (void)handleLocationUpdate:(NSNotification *) notification
{
  // id sender = notification.object; // not used here...
  NSDictionary *userInfo = notification.userInfo;
  DSAAdventure *adventure = userInfo[@"adventure"];
  [self setGroupPosition: adventure.activeGroup.position];
  [self needsDisplay];
}

@end
