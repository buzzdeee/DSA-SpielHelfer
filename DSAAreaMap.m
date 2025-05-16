/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-16 21:25:05 +0200 by sebastia

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

#import "DSAAreaMap.h"

@implementation DSAAreaMap
@end

@implementation DSABattleMap

- (instancetype)initWithAreaMap:(DSAAreaMap *)areaMap
              playerCharacters:(NSArray<DSACharacter *> *)players
                        enemies:(NSArray<DSACharacter *> *)enemies
{
    self = [super init];
    if (self) {
        _areaMap = areaMap;
        NSUInteger width = areaMap.width;
        NSUInteger height = areaMap.height;
        
        NSMutableArray *rows = [NSMutableArray arrayWithCapacity:height];
        
        for (NSUInteger y = 0; y < height; y++) {
            NSMutableArray *row = [NSMutableArray arrayWithCapacity:width];
            for (NSUInteger x = 0; x < width; x++) {
                DSABattleMapTile *battleTile = [[DSABattleMapTile alloc] init];
                battleTile.baseTile = areaMap.tiles[y][x];
                battleTile.isVisible = NO;
                battleTile.occupant = nil;
                [row addObject:battleTile];
            }
            [rows addObject:row];
        }
        _battleTiles = [rows copy];

        // Positioniere Spieler (linke Seite)
        [self placeCharacters:players fromX:0 toX:width / 3];

        // Positioniere Gegner (rechte Seite)
        [self placeCharacters:enemies fromX:2 * width / 3 toX:width];
    }
    return self;
}

- (void)placeCharacters:(NSArray<DSACharacter *> *)characters fromX:(NSUInteger)xMin toX:(NSUInteger)xMax {
    NSUInteger height = self.areaMap.height;
    NSUInteger placed = 0;
    
    for (NSUInteger y = 0; y < height && placed < characters.count; y++) {
        for (NSUInteger x = xMin; x < xMax && placed < characters.count; x++) {
            DSABattleMapTile *tile = self.battleTiles[y][x];
            if (tile.baseTile.isWalkable && tile.occupant == nil) {
                tile.occupant = characters[placed];
                placed++;
            }
        }
    }
}
@end

@implementation DSAAreaMapTile
@end

@implementation DSABattleMapTile
@end

