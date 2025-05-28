/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-01 23:26:05 +0100 by sebastia

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

#import "DSAAdventure.h"
#import "DSAAdventureClock.h"
#import "DSAAdventureGroup.h"

@implementation DSAAdventure

- (instancetype)init {
    if (self = [super init]) {
        _groups = [NSMutableArray array];
        NSLog(@"DSAAdventure init before _gameClock");
        _gameClock = [[DSAAdventureClock alloc] init];
        NSLog(@"DSAAdventure init after _gameClock: %@", _gameClock.currentDate);        
        _gameWeather = [[DSAWeather alloc] init];
        NSLog(@"DSAAdventure init after _gameWeather: %@", _gameWeather);
        _characterFilePaths = [[NSMutableArray alloc] init];
        NSLog(@"DSAAdventure init after _characterFilePaths");
        [_gameClock startClock];
        NSLog(@"DSAAdventure init after starting clock");
    }
    NSLog(@"DSAAdventure init: returning self: %@", self);
    return self;
}

- (void)dealloc
{
  NSLog(@"DSAAdventure is being deallocated.");
  
  NSLog(@"DSAAdventure finished dealloc.");  
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  NSLog(@"DSAAdventure encodeWithCoder called!");
  [coder encodeObject:self.groups forKey:@"groups"];
  [coder encodeObject:self.gameClock forKey:@"gameClock"];
  [coder encodeObject:self.gameWeather forKey:@"gameWeather"];
  
  [coder encodeObject:self.characterFilePaths forKey:@"characterFilePaths"];
 }

- (instancetype) initWithCoder:(NSCoder *)coder
{
  NSLog(@"DSAAdventure initWithCoder called!");
  self = [super init];
  if (self)
    {
      _groups = [coder decodeObjectForKey:@"groups"];
      _gameClock = [coder decodeObjectForKey:@"gameClock"];
      _gameWeather = [coder decodeObjectForKey:@"gameWeather"];
      
      _characterFilePaths = [coder decodeObjectForKey:@"characterFilePaths"] ?: [NSMutableArray array];
      NSLog(@"DSAAdventure initWithCoder, going to start gameClock");
      [self.gameClock startClock];
    }
  return self;
}

- (DSAAdventureGroup *)activeGroup {
    return self.groups.firstObject;
}

- (void)switchToGroupAtIndex:(NSUInteger)index {
    if (index < self.groups.count && index != 0) {
        [self.groups exchangeObjectAtIndex:0 withObjectAtIndex:index];
    }
}

- (void)addCharacterToActiveGroup:(NSUUID *)characterUUID {
    if (characterUUID && ![self.activeGroup.partyMembers containsObject:characterUUID]) {
        [self.activeGroup.partyMembers addObject:characterUUID];
    }
}

- (void)removeCharacterFromActiveGroup:(NSUUID *)characterUUID {
    [self.activeGroup.partyMembers removeObject:characterUUID];
    
    // Optional: leere Gruppen löschen?
    if (self.activeGroup.partyMembers.count == 0) {
        [self.groups removeObjectAtIndex:0];
    }
}

/*
- (void)addCharacterToParty:(DSACharacter *)character {
    if ([self.partyMembers count] < 6) {
      if (![self.partyMembers containsObject:character]) {
          [self.partyMembers addObject:character];
      }
    }
}

- (void)removeCharacterFromParty:(DSACharacter *)character {
    [self.partyMembers removeObject:character];
}

- (void)addNPCToParty:(DSACharacter *)character {
    if ([self.partyNPCs count] < 3) {
      if (![self.partyNPCs containsObject:character]) {
          [self.partyNPCs addObject:character];
      }
    }
}

- (void)removeNPCFromParty:(DSACharacter *)character {
    [self.partyNPCs removeObject:character];
}
*/
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
