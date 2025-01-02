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

#ifndef _DSAADVENTURE_H_
#define _DSAADVENTURE_H_

#import <Foundation/Foundation.h>
#import "DSACharacter.h"
#import "DSAAventurianCalendar.h"

@interface DSAAdventure : NSObject

@property (nonatomic, strong) NSMutableArray<DSACharacter *> *partyMembers; // Party of characters
@property (nonatomic, strong) NSMutableArray<DSACharacter *> *partyNPCs; // NPC party members
@property (nonatomic, strong) DSAAventurianCalendar *gameTime; // In-game time

- (void)addCharacterToParty:(DSACharacter *)character;
- (void)removeCharacterFromParty:(DSACharacter *)character;
- (void)addNPCToParty:(DSACharacter *)character;
- (void)removeNPCFromParty:(DSACharacter *)character;

@end
#endif // _DSAADVENTURE_H_

