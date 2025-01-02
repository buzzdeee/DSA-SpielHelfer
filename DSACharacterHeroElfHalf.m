/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-28 23:33:19 +0200 by sebastia

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

#import "DSACharacterHeroElfHalf.h"

@implementation DSACharacterHeroElfHalf

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.lifePoints = 30;
      self.astralEnergy = 20;
      self.currentLifePoints = 30;
      self.currentAstralEnergy = 20;
      self.maxLevelUpTalentsTries = 30;        // most have this as their starting value
      self.maxLevelUpSpellsTries = 20; 
      self.mrBonus = 1;          
    }
  return self;
}

@end
