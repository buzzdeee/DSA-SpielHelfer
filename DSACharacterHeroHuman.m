/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-17 19:55:26 +0200 by sebastia

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

#import "DSACharacterHeroHuman.h"
#import "Utils.h"
#import "DSACharacterMagic.h"

@implementation DSACharacterHeroHuman
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Most of the human have 30 lifePoints at the start
      // as seen in the character descriptions in "Mit Mantel Schwert und Zauberstab", 
      // and "Die Helden des Schwarzen Auges", Regelbuch II
      self.lifePoints = [NSNumber numberWithInteger: 30];
      self.astralEnergy = [NSNumber numberWithInteger: 0];
      self.karmaPoints = [NSNumber numberWithInteger: 0];
      self.currentLifePoints = [NSNumber numberWithInteger: 30];
      self.currentAstralEnergy = [NSNumber numberWithInteger: 0];
      self.currentKarmaPoints = [NSNumber numberWithInteger: 0];
      self.mrBonus = @0;
    }
  return self;
}

- (NSDictionary *) levelUpBaseEnergies
{
  NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
  NSInteger result = [[Utils rollDice: @"1W6"] integerValue];
  
  if ([self isMagicalDabbler])  // as explained in "Die Magie des schwarzen Auges" S. 37
    {
      if (result == 1) // 1 point always has to go to the lifePoints
        {
          NSNumber *tmp = self.lifePoints;
          self.lifePoints = [NSNumber numberWithInteger: result + [tmp integerValue]];
          self.currentLifePoints = [NSNumber numberWithInteger: result + [tmp integerValue]];
          [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaLifePoints"];
        }
      else
        {
          
          NSInteger remainder = result - 1;
          if ( remainder == 1 )
            {
              NSNumber *tmp = self.lifePoints;
              self.lifePoints = [NSNumber numberWithInteger: 1 + [tmp integerValue]];
              self.currentLifePoints = [NSNumber numberWithInteger: 1 + [tmp integerValue]];
              self.tempDeltaLpAe = @1;
              // we have to ask the user how to distribute the remaining point
              [resultDict setObject: @1 forKey: @"deltaLpAe"];
              [resultDict setObject: @1 forKey: @"deltaLifePoints"];
              self.tempDeltaLpAe = @1;
            }
          else if (remainder > 1)
            {
              NSNumber *tmp = self.lifePoints;
              self.lifePoints = [NSNumber numberWithInteger: result - 2 + [tmp integerValue]];
              self.currentLifePoints = [NSNumber numberWithInteger: result -2  + [tmp integerValue]];            

              // we have to ask the user how to distribute remaining points
              [resultDict setObject: @2 forKey: @"deltaLpAe"];        // a maximum of 2 can be assigned to AstralEnergy
              [resultDict setObject: [NSNumber numberWithInteger: result - 2] forKey: @"deltaLifePoints"];
              self.tempDeltaLpAe = @2;
            }          
        }
    }
  else
    {
      NSInteger tmp = [self.lifePoints integerValue];
      self.lifePoints = [NSNumber numberWithInteger: result + tmp];
      self.currentLifePoints = [NSNumber numberWithInteger: result + tmp];
  
      [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaLifePoints"];
      if ([self conformsToProtocol:@protocol(DSACharacterMagic)])
        {
          result = [[Utils rollDice: @"1W6"] integerValue];
          NSInteger tmp = [self.astralEnergy integerValue];
          self.astralEnergy = [NSNumber numberWithInteger: result + tmp];
          self.currentAstralEnergy = [NSNumber numberWithInteger: result + tmp];
          [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaAstralEnergy"];
        }

      if ([self isBlessedOne])
        {        
          NSLog(@"leveling up Karma not yet implemented!!!");
          [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaKarmaPoints"];
        }
    }
  return resultDict;
}



@end
