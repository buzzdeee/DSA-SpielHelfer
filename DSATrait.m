/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 22:37:59 +0200 by sebastia

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

#import "DSATrait.h"
#import "Utils.h"

@implementation DSATrait
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self)
      {
        self.level = [coder decodeIntegerForKey:@"level"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.category = [coder decodeObjectForKey:@"category"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeInteger:self.level forKey:@"level"];
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.category forKey:@"category"];
}                 


@end
// End of DSATrait

@implementation DSAPositiveTrait
- (instancetype)initTrait: (NSString *) name
                   onLevel: (NSInteger)level
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.level = level;
      self.category = _(@"Positive Eigenschaft");
    }
  return self;
}                   


- (BOOL) levelUp
{
  NSInteger result;
  NSLog(@"DSAPositiveTrait levelUp %@", self);
  for (int i=0; i<3;i++)
    {
      NSLog(@"DSAPositiveTrait levelUp try: %ld",(signed long) i);
      result = [Utils rollDice: @"1W20"];
      if (result >= self.level)
        {
          self.level += 1;
          NSLog(@"DSAPositiveTrait now: %ld", (signed long) self.level);
          return YES;
        }
    }
  return NO;
}
@end
// End of DSAPositiveTrait

@implementation DSANegativeTrait
- (instancetype)initTrait: (NSString *) name
                   onLevel: (NSInteger)level
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

- (BOOL) levelDown
{
  NSInteger result;
  for (int i=0; i<3;i++)
    {
      result = [Utils rollDice: @"1W20"];
      if (result <= self.level)
        {
          self.level -= 1;
          return YES;
        }
    }
  return NO;
}
@end
// End of DSANegativeTrait