/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-28 22:33:51 +0200 by sebastia

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

#import "DSACharacterHeroElf.h"
#import "Utils.h"

@implementation DSACharacterHeroElf
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 25;
      self.astralEnergy = 25;
      self.currentLifePoints = 25;
      self.currentAstralEnergy = 25;
      self.maxLevelUpTalentsTries = 25;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 25;
      self.maxLevelUpTalentsTriesTmp = 0;
      self.maxLevelUpSpellsTriesTmp = 0;      
      self.maxLevelUpVariableTries = 0;
      self.isMagic = YES;         
    }
  return self;
}


- (NSDictionary *) levelUpBaseEnergies
{
  NSInteger result;
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  result = [Utils rollDice: @"1W6"] + 2;
 
  self.tempDeltaLpAe = result;
  // we have to ask the user how to distribute these
  [resultDict setObject: @(result) forKey: @"deltaLpAe"];

  return resultDict;
}

// @protocol DSACharacterMagic below
- (DSASpellResult *) castSpell: (DSASpell *) spell
{
  return [[DSASpellResult alloc] init];
}
- (DSASpellResult *) castSpell: (DSASpell *) spell on: (id) target
{
  return [[DSASpellResult alloc] init];
}

- (DSASpellResult *) castSpell: (DSASpell *) spell withSource: (id) source onTarget: (id) target
{
  return [[DSASpellResult alloc] init];
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  NSLog(@"DSACharacterHeroElf: the Spell: %@", spell);
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];
  NSLog(@"DSACharacterHeroElf: nr of spells in levelUpSpells: %@", self.levelUpSpells);
  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroElf: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
      result = YES;
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp -= 1;
      if ((tmpSpell.maxTriesPerLevelUp % 3) == 0)
        {
          tmpSpell.maxUpPerLevel -= 1;
        }
    }
  return result;
}

// Non-Elf spells can only be leveled up to 11
// See: "Dunkle Städte, Lichte Wälder", "Geheimnisse der Elfen", S. 68
- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (![@[ @"A", @"W", @"F" ] containsObject: spell.origin])
    {
      if (spell.level == 11 )
        {
          return NO;
        }
    }
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] == 0)
    {
      return NO;
    }
  else
    {
      return YES;
    }    
}

- (BOOL) levelUpSpecialsWithSpells
{
  return NO;
}

@end
