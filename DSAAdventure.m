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

@implementation DSAAdventure

- (instancetype)init {
    if (self = [super init]) {
        _partyMembers = [NSMutableArray array];
        _partyNPCs = [NSMutableArray array];
        _gameTime = [[DSAAventurianCalendar alloc] init];
    }
    return self;
}

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

@end
