/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 22:51:35 +0200 by sebastia

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

#import "DSANegativeTrait.h"
#import "Utils.h"

@implementation DSANegativeTrait

- (instancetype)initTrait: (NSString *) name
                   onLevel: (NSNumber *)level
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.level = level;
      self.category = _(@"Negative Eigenschaft");
    }
  return self;
}                   

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self)
    {
      self.category = [coder decodeObjectForKey:@"category"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.category forKey:@"category"];
}

- (BOOL) levelDown
{
  NSNumber *result;
  for (int i=0; i<3;i++)
    {
      result = [Utils rollDice: @"1W20"];
      if ([result integerValue] <= [self.level integerValue])
        {
          NSInteger oldLevel = [self.level integerValue];
          self.level = [NSNumber numberWithInteger: oldLevel - 1];
          return YES;
        }
    }
  return NO;
}

@end
