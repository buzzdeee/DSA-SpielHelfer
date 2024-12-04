/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-14 22:28:25 +0100 by sebastia

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

#import "DSACharacterHeroHumanShaman.h"
#import "Utils.h"
#import "DSASpell.h"
#import "DSASpellResult.h"

@implementation DSACharacterHeroHumanShaman

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.astralEnergy = @15;
      self.currentAstralEnergy = @15;
      self.maxLevelUpTalentsTries = @20;        // most have this as their starting value
      self.maxLevelUpSpellsTries = @10;
      self.maxLevelUpTalentsTriesTmp = @20;
      self.maxLevelUpSpellsTriesTmp = @10;      
      self.maxLevelUpVariableTries = @10;
      self.mrBonus = @3;                      // Die Magie des schwarzen Auges S. 40
    }
  return self;
}


- (NSDictionary *) levelUpBaseEnergies
{
  if (self.spells == nil || [self.spells count] == 0)  // standard shaman without druid spells
    {
      NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
      NSInteger result = [[Utils rollDice: @"1W6"] integerValue] + 1;

      // at least 1 point always has to go to the lifePoints AND astralEnergy
      NSNumber *tmp = self.lifePoints;
      self.lifePoints = [NSNumber numberWithInteger: 1 + [tmp integerValue]];
      self.currentLifePoints = [NSNumber numberWithInteger: 1 + [tmp integerValue]];
      [resultDict setObject: @1 forKey: @"deltaLifePoints"];
      tmp = self.astralEnergy;
      self.astralEnergy = [NSNumber numberWithInteger: 1 + [tmp integerValue]];
      self.currentAstralEnergy = [NSNumber numberWithInteger: 1 + [tmp integerValue]];
      [resultDict setObject: @1 forKey: @"deltaAstralEnergy"];  
    
      if (result > 2)
        {          
          // we have to ask the user how to distribute remaining points
          [resultDict setObject: [NSNumber numberWithInteger: result - 2 ] forKey: @"deltaLpAe"];
          self.tempDeltaLpAe = [NSNumber numberWithInteger: result - 2 ];
        }
      return resultDict;
    }
  else
    {
      NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
      NSNumber *result = [NSNumber numberWithInteger: [[Utils rollDice: @"1W6"] integerValue] + 2];
 
      self.tempDeltaLpAe = result;
      // we have to ask the user how to distribute these
      [resultDict setObject: result forKey: @"deltaLpAe"];

      return resultDict;    
    }
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
  NSLog(@"THE spell name: %@ TMP SPELL: %@ AND ALL THE TMP SPELLS %@", spell.name, tmpSpell, self.levelUpSpells);

  if ([tmpSpell.maxUpPerLevel integerValue] == 0)
    {
      NSLog(@"DSACharacterHeroHumanShaman: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
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

  NSLog(@"checking if we can level up spell: %@, %lu", spell.name, (unsigned long)[[[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] integerValue]);
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
  return YES;
}

@end
