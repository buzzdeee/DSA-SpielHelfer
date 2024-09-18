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
    }
  return self;
}
@end
