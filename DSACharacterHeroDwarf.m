/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-10-03 20:51:04 +0200 by sebastia

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

#import "DSACharacterHeroDwarf.h"

@implementation DSACharacterHeroDwarf

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 40;
      self.astralEnergy = 0;
      self.currentLifePoints = 40;
      self.currentAstralEnergy = 0;
      self.maxLevelUpTalentsTries = 25;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 0;
      self.maxLevelUpTalentsTriesTmp = 0;
      self.maxLevelUpSpellsTriesTmp = 0;      
      self.maxLevelUpVariableTries = 0;
      self.mrBonus = 2;                       // Die Helden des Schwarzen Auges, Regelbuch II S. 40           
    }
  return self;
}

@end
