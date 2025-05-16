/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-16 21:48:28 +0200 by sebastia

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

#import "DSABattleWindowController.h"
#import "DSAAreaMap.h"
#import "DSABattleMapView.h"
#import "DSADocumentController.h"
#import "DSAAdventureDocument.h"
#import "DSAAdventure.h"

@implementation DSABattleWindowController

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSABattleMap"];
  if (self)
    {
      
    }
  return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    DSAAreaMap *areaMap = [self generateSampleAreaMap];
    //NSArray *players = @[[self createSamplePlayer]];
    //NSArray *enemies = @[[self createSampleEnemy]];
/*    DSADocumentController *controller = (DSADocumentController *)[NSDocumentController sharedDocumentController];
    DSAAdventureDocument *activeAdventure = (DSAAdventureDocument *)[controller currentDocument];
    DSAAdventure *adventureModel = activeAdventure.model;
    NSArray<NSUUID *> *partyIDs = adventureModel.partyMembers;
    NSMutableArray<DSACharacter *> *characters = [NSMutableArray array];
    for (NSUUID *uuid in partyIDs) {
        DSACharacter *c = [DSACharacter characterWithModelID:uuid];
        if (c) [characters addObject:c];
    }
*/
    NSArray<DSACharacter *> *players = [self charactersFromAdventure];
    NSArray *enemies = @[];
    DSABattleMap *battleMap = [[DSABattleMap alloc] initWithAreaMap:areaMap
                                                  playerCharacters:players
                                                            enemies:enemies];
    
    self.battleMapView.battleMap = battleMap;
    [self.battleMapView setNeedsDisplay:YES]; // Zeichnen anstoßen
}

- (NSArray<DSACharacter *> *)charactersFromAdventure {
    NSMutableArray<DSACharacter *> *characters = [NSMutableArray array];
    DSAAdventureDocument *adventureDoc = [[[DSADocumentController sharedDocumentController] allAdventureDocuments] objectAtIndex: 0]; // There shouldn't be more than one open...
    NSLog(@"DSABattleWindowController charactersFromAdventure: adventureDoc: %@", adventureDoc);
    
    DSAAdventure *adventure = adventureDoc.model;
    NSLog(@"DSABattleWindowController charactersFromAdventure: adventure: %@", adventure);
    for (NSUUID *modelID in [adventure.subGroups objectAtIndex: 0]) {
        NSLog(@"DSABattleWindowController charactersFromAdventure: modelID %@", modelID);
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        if (character) {
            [characters addObject:character];
        } else {
            NSLog(@"[DSABattleWindowController] Character with model ID %@ not found in registry", modelID);
        }
    }

    return [characters copy];
}
/*
- (NSArray<DSAAdventureDocument *> *)allAdventureDocuments {
    return [[self documents] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDocument *doc, NSDictionary *bindings) {
        return [doc isKindOfClass:[DSAAdventureDocument class]];
    }]];
}
*/
- (DSAAreaMap *)generateSampleAreaMap {
    NSUInteger width = 40, height = 24;
    NSMutableArray *rows = [NSMutableArray array];

    for (NSUInteger y = 0; y < height; y++) {
        NSMutableArray *row = [NSMutableArray array];
        for (NSUInteger x = 0; x < width; x++) {
            DSAAreaMapTile *tile = [[DSAAreaMapTile alloc] init];
            tile.terrainType = (x + y) % 5 == 0 ? @"water" : @"grass";
            tile.isWalkable = ![tile.terrainType isEqualToString:@"water"];
            [row addObject:tile];
        }
        [rows addObject:row];
    }

    DSAAreaMap *map = [[DSAAreaMap alloc] init];
    map.width = width;
    map.height = height;
    map.tiles = rows;

    return map;
}

@end
