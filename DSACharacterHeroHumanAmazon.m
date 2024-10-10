/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-10-04 16:50:10 +0200 by sebastia

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

#import "DSACharacterHeroHumanAmazon.h"

@implementation DSACharacterHeroHumanAmazon

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // see Mit Mantel, Schwert und Zauberstab S. 12
      self.lifePoints = [NSNumber numberWithInteger: 35];
      self.currentLifePoints = [NSNumber numberWithInteger: 35];  
    }
  return self;
}

@end
