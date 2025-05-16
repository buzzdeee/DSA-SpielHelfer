/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-16 21:33:14 +0200 by sebastia

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

#import "DSABattleMapView.h"
#import "DSAAreaMap.h"
#import "DSACharacter.h"

@implementation DSABattleMapView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (!self.battleMap) return;
    
    CGFloat tileSize = 32.0;
    NSUInteger rows = self.battleMap.areaMap.height;
    NSUInteger cols = self.battleMap.areaMap.width;
    
    for (NSUInteger y = 0; y < rows; y++) {
        for (NSUInteger x = 0; x < cols; x++) {
            NSRect tileRect = NSMakeRect(x * tileSize, y * tileSize, tileSize, tileSize);
            DSABattleMapTile *tile = self.battleMap.battleTiles[y][x];
            
            NSColor *fillColor = [self colorForTerrain:tile.baseTile.terrainType];
            [fillColor setFill];
            NSBezierPath *path = [NSBezierPath bezierPathWithRect:tileRect];
            [path fill];

            if (tile.occupant) {
                if (tile.occupant.isNPC) {
                    [[NSColor redColor] set];
                } else {
                    [[NSColor blackColor] set];
                }
                NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(tileRect, 4, 4)];
                [circle fill];
            }
        }
    }
}

- (NSColor *)colorForTerrain:(NSString *)terrainType {
    if ([terrainType isEqualToString:@"grass"]) return [NSColor greenColor];
    if ([terrainType isEqualToString:@"stone"]) return [NSColor grayColor];
    if ([terrainType isEqualToString:@"water"]) return [NSColor blueColor];
    if ([terrainType isEqualToString:@"bush"]) return [NSColor darkGrayColor];
    return [NSColor whiteColor];
}

@end