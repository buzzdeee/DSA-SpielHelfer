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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.partyMembers forKey:@"partyMembers"];
    [coder encodeObject:self.npcMembers forKey:@"npcMembers"];
    [coder encodeObject:self.position forKey:@"position"];
    [coder encodeObject:self.weather forKey:@"weather"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _partyMembers = [coder decodeObjectForKey:@"partyMembers"];
        _npcMembers = [coder decodeObjectForKey:@"npcMembers"];
        _position = [coder decodeObjectForKey:@"position"];
        _weather = [coder decodeObjectForKey:@"weather"];
    }
    return self;
}


- (float)totalWealthOfGroup
{
    float total = 0.0;

    for (NSUUID *modelID in self.partyMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        if (character.wallet) {
            total += [character.wallet total];
        }
    }
    for (NSUUID *modelID in self.npcMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        if (character.wallet) {
            total += [character.wallet total];
        }
    }    

    return total;
}

// evenly pay in a shop or wherever else have to pay
- (void)subtractSilber:(float)silber
{
    if (silber <= 0.0) return;

    // 1. Collect all group members (party + npc) with wallets
    NSMutableArray<DSACharacter *> *members = [NSMutableArray array];

    for (NSUUID *modelID in self.partyMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        if (character.wallet) [members addObject:character];
    }
    for (NSUUID *modelID in self.npcMembers) {
        DSACharacter *character = [DSACharacter characterWithModelID:modelID];
        if (character.wallet) [members addObject:character];
    }

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

- (void)distributeItems:(DSAObject *)item count:(NSInteger)count
{
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
        NSInteger added = [character.inventory addObject:item quantity:remaining];
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
            NSInteger added = [character.inventory addObject:item quantity:1];
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
        NSLog(@"⚠️ Could not distribute %ld of item %@", (long)remaining, item.name);
    }
}


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

@end
