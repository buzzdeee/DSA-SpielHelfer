/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-07 21:57:19 +0100 by sebastia

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

#import "DSACharacterHeroHumanSharisad.h"
#import "DSASpell.h"
#import "DSASpellResult.h"
#import "Utils.h"

@implementation DSACharacterHeroHumanSharisad

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 30;
      self.astralEnergy = 15;
      self.currentLifePoints = 30;
      self.currentAstralEnergy = 15;   
      // not setting: maxLevelUpSpellsTries, as it's dependent on origin
      self.isMagic = YES;
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [Utils rollDice: @"1W6"];
 
  if (self.astralEnergy + result > 30) // AstralEnergy can't go above 30
    {
      NSInteger diff = 30 - self.astralEnergy;
      self.lifePoints = self.lifePoints + diff;
      self.tempDeltaLpAe = result - diff;
      // we have to ask the user how to distribute these
      [resultDict setObject: @(self.tempDeltaLpAe) forKey: @"deltaLpAe"];  
      [resultDict setObject: @(diff) forKey: @"deltaLifePoints"];
    }
  else
    {
       self.tempDeltaLpAe = result;  
      // we have to ask the user how to distribute these
      [resultDict setObject: @(result) forKey: @"deltaLpAe"];         
    }

  return resultDict;
}

// basic leveling up of a spell is handled within the spell
- (BOOL) levelUpSpell: (DSASpell *)spell
{
  BOOL result = NO;
  DSASpell *targetSpell = nil;
  DSASpell *tmpSpell = nil;

  targetSpell = spell;
  tmpSpell = [self.levelUpSpells objectForKey: spell.name];

  if (tmpSpell.maxUpPerLevel == 0)
    {
      NSLog(@"DSACharacterHeroSharisad: levelUpSpell: maxUpPerLevel was 0, I should not have been called in the first place, not doing anything!!!");
      return NO;
    }    
       
  self.maxLevelUpSpellsTriesTmp -= 1;
  result = [targetSpell levelUp];
  if (result)
    {
      tmpSpell.maxUpPerLevel -= 1;
      tmpSpell.maxTriesPerLevelUp = tmpSpell.maxUpPerLevel * 3;
      tmpSpell.level = targetSpell.level;
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

- (BOOL) canLevelUpSpell: (DSASpell *)spell
{
  if (spell.level == 18)
    {
      // we're already at the general maximum
      return NO;
    }
  if ([[self.levelUpSpells objectForKey: [spell name]] maxUpPerLevel] <= 0)
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
