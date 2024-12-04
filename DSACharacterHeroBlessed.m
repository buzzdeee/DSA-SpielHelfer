/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-16 23:29:08 +0100 by sebastia

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

#import "DSACharacterHeroBlessed.h"
#import "Utils.h"

@implementation DSACharacterHeroBlessed
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Most of the human have 30 lifePoints at the start
      // as seen in the character descriptions in "Mit Mantel Schwert und Zauberstab", 
      // and "Die Helden des Schwarzen Auges", Regelbuch II
      self.lifePoints = @30;
      self.astralEnergy = @0;
      self.karmaPoints = @24;           // for Blessed ones of Gods, Halfgods only will have 12 Karma Points, See Kirchen, Kulte, Ordenskrieger S. 10
      self.currentLifePoints = @30;
      self.currentAstralEnergy = @0;
      self.currentKarmaPoints = @24;
      self.isBlessedOne = YES;
      self.mrBonus = @0;
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [[Utils rollDice: @"1W6"] integerValue];
  
  NSInteger tmp = [self.lifePoints integerValue];
  self.lifePoints = [NSNumber numberWithInteger: result + tmp];
  self.currentLifePoints = [NSNumber numberWithInteger: result + tmp];
 
  [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaLifePoints"];
       
  // See: Kirchen, Kulte, Ordenskrieger, S. 17 (Visionsqueste, 1x/Stufe), Blessed ones for half-gods, have different calculation
  result = [[Utils rollDice: @"1W3"] integerValue] + 4;
  tmp = [self.karmaPoints integerValue];
  self.karmaPoints = [NSNumber numberWithInteger: result + tmp];
  self.currentKarmaPoints = [NSNumber numberWithInteger: result + tmp];
    
  [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaKarmaPoints"];

  return resultDict;
}

@end
