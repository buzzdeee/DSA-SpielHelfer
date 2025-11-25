/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-27 20:53:36 +0200 by sebastia

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

#import "DSAAdventureGroup.h"
#import "DSALocation.h"
#import "DSAWeather.h"
#import "DSACharacter.h"
#import "DSAWallet.h"
#import "DSAInventoryManager.h"
#import "Utils.h"
#import "DSAGod.h"
#import "DSAAdventure.h"
#import "DSAMapCoordinate.h"
#import "DSAEvent.h"
#import "DSALocations.h"
#import "DSAAdventureClock.h"

@implementation DSAAdventureGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _partyMembers = [NSMutableArray array];
        _npcMembers = [NSMutableArray array];
        _position = nil;
        _weather = nil;
    }
    return self;
}

- (instancetype)initWithPartyMembers:(NSArray<NSUUID *> *)members
                            position:(DSAPosition *)position
                             weather:(DSAWeather *)weather {
    self = [super init];
    if (self) {
        _partyMembers = [members mutableCopy];
        _position = position;
        _weather = weather;
    }
    return self;
}

- (NSInteger) membersCount
{
  return [self.allMembers count];
}

- (NSArray<NSUUID *> *) allMembers
{
  NSArray<NSUUID *> *allMembers = [self.partyMembers arrayByAddingObjectsFromArray:self.npcMembers];
  return allMembers;
}

- (NSArray<DSACharacter *> *) partyCharacters
{
    NSMutableArray<DSACharacter *> *characters = [NSMutableArray array];

    for (NSUUID *modelID in [self partyMembers]) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        [characters addObject: character];
    }
    return characters;
}

- (NSArray<DSACharacter *> *) npcCharacters
{
    NSMutableArray<DSACharacter *> *characters = [NSMutableArray array];

    for (NSUUID *modelID in [self npcMembers]) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        [characters addObject: character];
    }
    return characters;
}

- (NSArray<DSACharacter *> *) allCharacters
{
    NSMutableArray<DSACharacter *> *characters = [NSMutableArray array];

    for (NSUUID *modelID in [self allMembers]) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        [characters addObject: character];
    }
    return characters;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.partyMembers forKey:@"partyMembers"];
    [coder encodeObject:self.npcMembers forKey:@"npcMembers"];
    [coder encodeObject:self.nightGuards forKey:@"nightGuards"];
    [coder encodeObject:self.lastHunter forKey:@"lastHunter"];
    [coder encodeObject:self.lastHerbsCollector forKey:@"lastHerbsCollector"];    
    [coder encodeObject:self.position forKey:@"position"];
    [coder encodeObject:self.weather forKey:@"weather"];

}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _partyMembers = [coder decodeObjectForKey:@"partyMembers"];
        _npcMembers = [coder decodeObjectForKey:@"npcMembers"];
        _nightGuards = [coder decodeObjectForKey:@"nightGuards"];
        _lastHunter = [coder decodeObjectForKey:@"lastHunter"];
        _lastHerbsCollector = [coder decodeObjectForKey:@"lastHerbsCollector"];
        _position = [coder decodeObjectForKey:@"position"];
        _weather = [coder decodeObjectForKey:@"weather"];
    }
    return self;
}

- (float) totalWealthOfGroup
{
    float total = 0.0;

    for (DSACharacter *character in [self allCharacters]) {
        total += [character.wallet total];
    }

    return total;
}

// evenly pay in a shop or wherever else have to pay
- (void)subtractSilber:(float)silber
{
    if (silber <= 0.0) return;

    // 1. Collect all group members (party + npc) with wallets
    NSArray<DSACharacter *> *members = [self allCharacters];

    NSUInteger remainingCount = members.count;
    if (remainingCount == 0) return;

    float remainingAmount = silber;
    NSMutableSet<DSACharacter *> *completed = [NSMutableSet set];

    while (remainingAmount > 0.0 && remainingCount > 0) {
        float share = remainingAmount / remainingCount;

        BOOL anyonePaid = NO;

        for (DSACharacter *character in members) {
            if ([completed containsObject:character]) continue;

            float available = [character.wallet total];

            if (available >= share) {
                [character.wallet subtractSilber:share];
                remainingAmount -= share;
                anyonePaid = YES;
            } else {
                [character.wallet subtractSilber:available];
                remainingAmount -= available;
                [completed addObject:character];
                remainingCount--;
                anyonePaid = YES;
            }

            if (remainingAmount <= 0.01) break; // avoid float precision leftovers
        }

        if (!anyonePaid) break; // no one can pay anything more
    }
}

// evenly distribute money (e.g. loot or reward)
- (void)addSilber:(float)silber
{
    if (silber <= 0.0) return;

    // 1. Collect all group members (party + npc)
    NSArray<DSACharacter *> *members = [self allCharacters];

    NSUInteger memberCount = members.count;
    if (memberCount == 0) return;

    // 2. Divide evenly
    float share = silber / memberCount;
    float distributed = 0.0;

    for (DSACharacter *character in members) {
        [character.wallet addSilber:share];
        distributed += share;
    }

    // 3. Handle rounding error by giving the remaining silver to the first character
    float roundingError = silber - distributed;
    if (fabs(roundingError) > 0.01 && members.count > 0) {
        DSACharacter *first = members[0];
        [first.wallet addSilber:roundingError];
    }
}

- (void)distributeItems:(DSAObject *)item count:(NSInteger)count
{
    //NSLog(@"DSAAdventureGroup distributeItems: item %@", item);
    if (!item || count <= 0) return;

    // 1. Gather group members with inventories
    NSMutableArray<DSACharacter *> *members = [NSMutableArray array];
    for (NSUUID *modelID in self.partyMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        if (character.inventory) [members addObject:character];
    }
    for (NSUUID *modelID in self.npcMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        if (character.inventory) [members addObject:character];
    }

    if (members.count == 0) return;

    NSInteger remaining = count;

    // 2. Try bulk add first
    for (DSACharacter *character in members) {
        NSInteger added = [character addObjectToInventory:item quantity:remaining];
        NSLog(@"DSAAdventureGroup distributeItems: bulk adding %@ to Character: %@", item.name, character.name);
        if (added == remaining)
          {
            [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: character targetModel: character];
            return; // Done
          }
        if (added > 0) {
            [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: character targetModel: character];
            remaining -= added;
        }
    }

    // 3. Fallback: one-by-one
    for (DSACharacter *character in members)
      {
        if (remaining <= 0) break;
        while (remaining > 0)
          {
            NSInteger added = [character addObjectToInventory:item quantity:1];
            NSLog(@"DSAAdventureGroup distributeItems: single adding %@ to Character: %@", item.name, character.name);
            if (added == 1)
              {
                remaining -= 1;
                if (remaining == 0)
                  {
                    break;  // nothing more to distribute
                  }
              }
            else  // character inventory is full
              {
                break;
              }
          }
        [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: character targetModel: character];
      }
    if (remaining > 0) {
        NSLog(@"DSAAdventureGroup distributeItems: Could not distribute %ld of item %@", (long)remaining, item.name);
    }
}

- (NSArray<DSASlot *> *)getAllDSASlotsForShop:(NSString *)shopType {
    NSMutableArray<DSASlot *> *result = [NSMutableArray array];
    
    NSArray<NSString *> *categories = nil;
    if ([shopType isEqualToString:@"Krämer"]) {
        categories = DSAShopGeneralStoreCategories();
    } else if ([shopType isEqualToString:@"Kräuterhändler"]) {
        categories = DSAShopHerbsStoreCategories();        
    } else if ([shopType isEqualToString:@"Waffenhändler"]) {
        categories = DSAShopWeaponStoreCategories();
    } else {
        return @[];
    }
    
    NSArray<NSUUID *> *allMembers = [[self partyMembers] arrayByAddingObjectsFromArray:[self npcMembers]];
    
    for (NSUUID *uuid in allMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:uuid];
        if (!character) continue;
        
        DSAInventory *inventory = character.inventory;
        if (!inventory) continue;
        
        for (DSASlot *slot in inventory.slots) {
            DSAObject *object = slot.object;
            if (!object) continue;
            
            // Kategorie-Prüfung
            if (![categories containsObject:object.category]) {
                continue;
            }
            
            // Container-Prüfung
            if ([object isKindOfClass:[DSAObjectContainer class]]) {
                DSAObjectContainer *container = (DSAObjectContainer *)object;
                if (![container isEmpty]) {
                    continue; // Container ist nicht leer
                }
            }
            
            [result addObject:slot];
        }
    }
    
    return result;
}

- (DSACharacter *)findOwnerOfInventorySlot:(DSASlot *)slot {
    if (!slot) return nil;

    NSArray<NSUUID *> *allMembers = [self.partyMembers arrayByAddingObjectsFromArray:self.npcMembers];
    
    for (NSUUID *uuid in allMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:uuid];
        if (!character || !character.inventory) continue;

        if ([character.inventory.slots containsObject:slot]) {
            return character; // Slot gefunden
        }
    }

    return nil; // Kein Besitzer gefunden
}

- (BOOL)hasCharacterWithoutUniqueMiracle:(NSString *)miracleKey {
    for (DSACharacter *character in [self allCharacters]) {
        if (![character.receivedUniqueMiracles containsObject:miracleKey]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray<DSACharacter *> *)charactersWithoutUniqueMiracle:(NSString *)miracleKey {
    NSMutableArray<DSACharacter *> *result = [NSMutableArray array];
    for (DSACharacter *character in [self allCharacters]) {
        if (![character.receivedUniqueMiracles containsObject:miracleKey]) {
            [result addObject:character];
        }
    }
    return [result copy];
}

- (BOOL)hasMageInGroup
{
    for (DSACharacter *character in [self allCharacters]) {
        if ([character isMemberOfClass: [DSACharacterHeroHumanMage class]])
          {
            return YES;
          }
    }
    return NO;
}

- (NSInteger) charactersWithBookedRoomOfKey: (NSString *) roomKey
{
  NSInteger count = 0;
  for (DSACharacter *character in self.allCharacters)
    {
      if ([character hasAppliedCharacterEffectWithKey: roomKey])
        {
          count++;
        }
    }
  return count;
}

- (NSArray<DSACharacter *> *)illCharactersIncludingNPCs:(BOOL)includeNPCs
{
    return [self charactersWithState:DSACharacterStateSick includeNPCs:includeNPCs];
}

- (NSArray<DSACharacter *> *)woundedCharactersIncludingNPCs: (BOOL) includeNPCs
{
  return [self charactersWithState:DSACharacterStateWounded includeNPCs:includeNPCs];
}
- (NSArray<DSACharacter *> *)poisonedCharactersIncludingNPCs: (BOOL) includeNPCs
{
  return [self charactersWithState:DSACharacterStatePoisoned includeNPCs:includeNPCs];
}
- (NSArray<DSACharacter *> *)charactersWithState:(DSACharacterState)state includeNPCs:(BOOL)includeNPCs
{
    NSArray<DSACharacter *> *characters = includeNPCs ? self.allCharacters : self.partyCharacters;
    NSMutableArray<DSACharacter *> *filtered = [NSMutableArray array];

    for (DSACharacter *character in characters) {
        NSNumber *level = character.statesDict[@(state)];
        if (level && level.unsignedIntegerValue > DSASeverityLevelNone) {
            [filtered addObject:character];
        }
    }

    return [filtered copy];
}

- (NSArray<DSACharacter *> *)charactersAbleToUseTalentsIncludingNPCs:(BOOL)includeNPCs
{
    return [self charactersWithNonEmptyDictionaryForKey:@"talents" includeNPCs:includeNPCs];
}

- (NSArray<DSACharacter *> *)charactersAbleToCastSpellsIncludingNPCs:(BOOL)includeNPCs
{
    return [self charactersWithNonEmptyDictionaryForKey:@"spells" includeNPCs:includeNPCs];
}

- (NSArray<DSACharacter *> *)charactersAbleToCastRitualsIncludingNPCs:(BOOL)includeNPCs
{
    return [self charactersWithNonEmptyDictionaryForKey:@"specials" includeNPCs:includeNPCs];
}
- (NSArray<DSACharacter *> *)charactersWithNonEmptyDictionaryForKey:(NSString *)key includeNPCs:(BOOL)includeNPCs
{
    NSArray<DSACharacter *> *characters = includeNPCs ? self.allCharacters : self.partyCharacters;
    NSMutableArray<DSACharacter *> *filtered = [NSMutableArray array];

    for (DSACharacter *character in characters) {
        if ([character isDeadOrUnconscious])
          {
            continue;
          }
        NSDictionary *dict = [character valueForKey:key];
        if ([dict isKindOfClass:[NSDictionary class]] && dict.count > 0) {
            [filtered addObject:character];
        }
    }

    return [filtered copy];
}

- (DSACharacter *)characterWithBestTalentWithName:(NSString *)talentName
                                           negate:(BOOL)negate
{
    DSACharacter *bestCharacter = nil;
    NSInteger bestValue = negate ? NSIntegerMax : NSIntegerMin;

    for (DSACharacter *character in self.allCharacters) {
        // Holt das Talent aus dem Dictionary
        DSATalent *talent = character.currentTalents[talentName];
        if (!talent) {
            NSLog(@"DSAAdventureGroup characterWithBestTalentWithName: Talent: %@ not found at character: %@, aborting", talentName, character.name);
            abort();  // may support optional talents in the future, i.e. professions, or special talents?
            continue; // Character hat das Talent nicht
        }

        NSInteger level = talent.level;

        if (negate) {
            // Bei negate == YES suchen wir den SCHLECHTESTEN
            if (level < bestValue) {
                bestValue = level;
                bestCharacter = character;
            }
        } else {
            // Normal: besten Wert finden
            if (level > bestValue) {
                bestValue = level;
                bestCharacter = character;
            }
        }
    }

    return bestCharacter;
}


- (void)applyMiracle:(DSAMiracleResult *)miracleResult {
    if ([miracleResult.target isEqualToString:@"group"]) {
        for (DSACharacter *character in self.allCharacters) {
            [character applyMiracleEffect:miracleResult];
        }
    } else if ([miracleResult.target isEqualToString:@"individual"]) {
        for (DSACharacter *character in self.allCharacters) {
            if ([character applyMiracleEffect:miracleResult]) {
                break;
            }
        }
    }
}

// THIS DESCRIPTION is special here, skipping over read-only properties
// DUE TO allCharacters property, this: [DSACharacter characterWithModelID:modelID]
// is not working when loading saved games from file...

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }          
          
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}
@end // DSAAdventureGroup

@implementation DSAAdventureGroup (moveGroup)
- (void)discoverVisibleTilesAroundPosition:(DSAPosition *)position {
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
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

- (DSAPosition *)moveGroupInDirection:(DSADirection)direction {
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    DSAPosition *current = self.position;
    DSAPosition *newPosition = [current positionByMovingInDirection:direction steps:1];
    NSLog(@"DSAAdventureGroup moveGroupInDirection: newPosition: %@", newPosition);

    [self discoverVisibleTilesAroundPosition:newPosition];

    DSALocation *localMapLocation = [[DSALocations sharedInstance] locationWithName: current.localLocationName ofType: @"local"];
    
    DSALocalMapTile *fromTile = [localMapLocation tileAtPosition:current];
    DSALocalMapTile *toTile = [localMapLocation tileAtPosition:newPosition];

    if ([toTile isMemberOfClass:[DSALocalMapTileBuildingInn class]])
      {
        NSString *inType = [toTile type];
        if ([inType isEqualToString: DSALocalMapTileBuildingInnTypeHerberge] || 
            [inType isEqualToString: DSALocalMapTileBuildingInnTypeHerbergeMitTaverne])
          {
             newPosition.context = DSAActionContextReception;
          }
        else if ([inType isEqualToString: DSALocalMapTileBuildingInnTypeTaverne])
          {
            newPosition.context = DSAActionContextTavern;
          }
        else
          {
            NSLog(@"DSAAdventureGroup moveGroupInDirection: unknown inType: %@, aborting!", inType);
            abort();
          }
      }
    else
      {
        newPosition.context = nil;
      }    
    
    // Check if destination is walkable
    if (!toTile.walkable) {
        NSBeep();
        return nil;
    }

    
    NSArray<DSAEvent *> *activeEvents = [adventure activeEventsAtPosition:newPosition 
                                                                  forDate:adventure.gameClock.currentDate];

    NSLog(@"DSAAdventureGroup moveGroupInDirection: activeEvents: %@", activeEvents);                                                                  
    for (DSAEvent *event in activeEvents)
      {
        if (event.eventType == DSAEventTypeLocationBan)
          {
            NSLog(@"DSALocalMapView moveGroupInDirection: we're not allowed to get in: Hausverbot!");
            NSDictionary *userInfo = @{ @"severity": @(LogSeverityInfo),
                                         @"message": @"Wir haben hier leider Hausverbot!"
                                      };
            [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                                object: nil
                                                              userInfo: userInfo];
            NSBeep();
            return nil;
          }
      }                                                          
    // EXITING a building?
    if ([fromTile isKindOfClass:[DSALocalMapTileBuilding class]]) {
        DSALocalMapTileBuilding *buildingTile = (DSALocalMapTileBuilding *)fromTile;
        if (direction != buildingTile.door) {
            NSLog(@"DSAAdventureGroup moveGroupInDirection: Cannot exit building facing %@ by moving %@",
                  DSADirectionToString(buildingTile.door),
                  DSADirectionToString(direction));
            NSBeep();
            return nil;
        }
    }

    // ENTERING a building?
    if ([toTile isKindOfClass:[DSALocalMapTileBuilding class]]) {
        DSALocalMapTileBuilding *buildingTile = (DSALocalMapTileBuilding *)toTile;
        DSADirection requiredApproach = [self oppositeDirection:buildingTile.door];
        if (direction != requiredApproach) {
            NSLog(@"DSAAdventureGroup moveGroupInDirection: Cannot enter building with door %@ by moving %@ (required: %@)",
                  DSADirectionToString(buildingTile.door),
                  DSADirectionToString(direction),
                  DSADirectionToString(requiredApproach));
            NSBeep();
            return nil;
        }
    }

    // Move group
    self.position = newPosition;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"DSAAdventureLocationUpdated" 
                                                        object: self
                                                      userInfo: nil];
    return newPosition;
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

-(void) leaveLocation
{
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: self.position.localLocationName ofType: @"local"];
    DSALocalMapTile *currentTile = [currentLocation tileAtPosition: self.position];
    
    
    NSLog(@"DSAAdventureGroup leaveLocation called");
    if ([currentTile isKindOfClass:[DSALocalMapTileBuildingInn class]])
      {
        NSLog(@"DSAAdventureGroup leaveLocation called we're in an Inn");
        DSALocalMapTileBuildingInn *innTile = (DSALocalMapTileBuildingInn*) currentTile;
        if ([@[DSALocalMapTileBuildingInnTypeHerberge, DSALocalMapTileBuildingInnTypeHerbergeMitTaverne] containsObject:innTile.type] && 
            [@[DSAActionContextPrivateRoom, DSAActionContextTavern] containsObject: self.position.context])
          {
            NSLog(@"DSAAdventureGroup leaveLocation called we're in an Inn, switching to the reception");
            self.position.context = DSAActionContextReception;
            NSDictionary *userInfo = @{ @"position" : self.position };
            [[NSNotificationCenter defaultCenter] postNotificationName: @"DSAAdventureLocationUpdated" 
                                                                object: self
                                                              userInfo: userInfo];
            return;
          }
      }
    
    NSLog(@"DSAAdventureGroup leaveLocation currentTile: %@", currentTile);
    if ([currentTile isKindOfClass: [DSALocalMapTileBuilding class]])
      {
        NSLog(@"DSAAdventureGroup leaveLocation called we're in some building which is not an Inn");
        DSALocalMapTileBuilding *buildingTile = (DSALocalMapTileBuilding*)currentTile;
        DSADirection direction = buildingTile.door;
        DSAPosition *currentPosition = self.position;
        self.position = nil;
        self.position = [currentPosition positionByMovingInDirection: direction steps: 1];
        NSDictionary *userInfo = @{ @"position" : self.position };
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DSAAdventureLocationUpdated" 
                                                            object: self
                                                          userInfo: userInfo];        
      }
    NSLog(@"DSAAdventureGroup leaveLocation currentPosition after leaving: %@", self.position);
}
@end // DSAAdventureGroup (moveGroup)
