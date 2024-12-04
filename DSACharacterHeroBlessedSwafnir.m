/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-17 12:12:14 +0100 by sebastia

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

#import "DSACharacterHeroBlessedSwafnir.h"
#import "Utils.h"

@implementation DSACharacterHeroBlessedSwafnir
- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.karmaPoints = @10;           // see "Die Götter des schwarzen Auges" S. 90
      self.currentKarmaPoints = @10;    
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
       
  // See: Kirchen, Kulte, Ordenskrieger Swafnir is different than other Blessed Ones
  result = [[Utils rollDice: @"1W6"] integerValue] - 1;
  tmp = [self.karmaPoints integerValue];
  self.karmaPoints = [NSNumber numberWithInteger: result + tmp];
  self.currentKarmaPoints = [NSNumber numberWithInteger: result + tmp];
    
  [resultDict setObject: [NSNumber numberWithInteger: result] forKey: @"deltaKarmaPoints"];

  return resultDict;
}


@end
