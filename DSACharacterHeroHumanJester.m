/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-10-04 16:51:56 +0200 by sebastia

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

#import "DSACharacterHeroHumanJester.h"
#import "Utils.h"
#import "DSASpell.h"
#import "DSASpellResult.h"

@implementation DSACharacterHeroHumanJester

- (instancetype)init
{
  self = [super init];
  // see "Die Magie des Schwarzen Auges" S. 47
  if (self)
    {
      self.astralEnergy = @25;
      self.currentAstralEnergy = @25;
      self.maxLevelUpTalentsTries = @30;        
      self.maxLevelUpSpellsTries = @20;
      self.maxLevelUpTalentsTriesTmp = @30;
      self.maxLevelUpSpellsTriesTmp = @20;      
      self.maxLevelUpVariableTries = @0;
      self.mrBonus = @3;                               
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  // see "Die Magie des Schwarzen Auges" S. 47
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSNumber *result = [NSNumber numberWithInteger: [[Utils rollDice: @"1W6"] integerValue] + 2];
 
  self.tempDeltaLpAe = result;
  // we have to ask the user how to distribute these
  [resultDict setObject: result forKey: @"deltaLpAe"];

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
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if ([tmpSpell.maxUpPerLevel integerValue] == 0)
    {
      NSLog(@"DSACharacterHeroJester: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp = [NSNumber numberWithInteger: [self.maxLevelUpSpellsTriesTmp integerValue] - 1];
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel = [NSNumber numberWithInteger: [tmpSpell.maxUpPerLevel integerValue] - 1];
      tmpSpell.maxTriesPerLevelUp = [NSNumber numberWithInteger: [tmpSpell.maxUpPerLevel integerValue] * 3];
      tmpSpell.level = targetSpell.level;
    }
  else
    {
      tmpSpell.maxTriesPerLevelUp = [NSNumber numberWithInteger: [tmpSpell.maxTriesPerLevelUp integerValue] - 1];
      if ([tmpSpell.maxTriesPerLevelUp integerValue] % 3 == 0)
        {
          tmpSpell.maxUpPerLevel = [NSNumber numberWithInteger: [tmpSpell.maxUpPerLevel integerValue] - 1];
        }
    }
  return result;
}

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if ([spell.level integerValue] == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] integerValue] <= 0)
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
