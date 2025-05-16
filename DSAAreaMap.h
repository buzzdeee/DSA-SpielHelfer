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

#ifndef _DSAAREAMAP_H_
#define _DSAAREAMAP_H_

#import <Foundation/Foundation.h>

@class DSAAreaMapTile;
@interface DSAAreaMap : NSObject
@property NSUInteger width, height;
@property NSArray<NSArray<DSAAreaMapTile *> *> *tiles;
@end

@class DSACharacter;
@class DSABattleMapTile;
@interface DSABattleMap : NSObject
@property DSAAreaMap *areaMap;
@property NSArray<NSArray<DSABattleMapTile *> *> *battleTiles;
- (instancetype)initWithAreaMap:(DSAAreaMap *)areaMap
              playerCharacters:(NSArray<DSACharacter *> *)players
                        enemies:(NSArray<DSACharacter *> *)enemies;
@end

@interface DSAAreaMapTile : NSObject
@property NSString *terrainType;    // z. B. @"grass", @"stone", @"water"
@property BOOL isWalkable;
@end


@interface DSABattleMapTile : NSObject
@property DSAAreaMapTile *baseTile;
@property DSACharacter *occupant;
@property BOOL isVisible;
@end



#endif // _DSAAREAMAP_H_

