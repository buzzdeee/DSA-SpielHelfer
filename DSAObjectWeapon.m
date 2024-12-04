/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-23 19:28:45 +0100 by sebastia

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

#import "DSAObjectWeapon.h"

@implementation DSAObjectWeapon
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.hitPoints = [coder decodeObjectForKey:@"hitPoints"];
        self.regions = [coder decodeObjectForKey:@"regions"];
        self.isPersonalWeapon = [coder decodeBoolForKey:@"isPersonalWeapon"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.hitPoints forKey:@"hitPoints"];
  [coder encodeObject:self.regions forKey:@"regions"];
  [coder encodeBool:self.isPersonalWeapon forKey:@"isPersonalWeapon"];    
}

@end
