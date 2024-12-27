/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-26 12:09:29 +0100 by sebastia

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

#import "DSASpellMageRitual.h"

@implementation DSASpellMageRitual
- (instancetype)initSpell: (NSString *) name
               ofCategory: (NSString *) category
                 withTest: (NSArray *) test
              withASPCost: (NSInteger) aspCost
     withPermanentASPCost: (NSInteger) permanentASPCost
               withLPCost: (NSString *) lpCost
      withPermanentLPCost: (NSInteger) permanentLPCost
{
  self = [super initSpell: name
               ofCategory: category
                  onLevel: @0
               withOrigin: nil
                 withTest: test
   withMaxTriesPerLevelUp: @0
        withMaxUpPerLevel: @0
          withLevelUpCost: @0];
  if (self)
    {
      self.aspCost = aspCost;
      self.permanentASPCost = permanentASPCost;
      self.lpCost = lpCost;
      self.permanentLPCost = permanentLPCost;
      
    }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if (self)
    {
      self.aspCost = [coder decodeIntegerForKey:@"aspCost"];
      self.permanentASPCost = [coder decodeIntegerForKey:@"permanentASPCost"];
      self.lpCost = [coder decodeObjectForKey:@"lpCost"];
      self.permanentLPCost = [coder decodeIntegerForKey:@"permanentLPCost"];      
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{ 
  [super encodeWithCoder: coder];
  [coder encodeInteger:self.aspCost forKey:@"aspCost"];
  [coder encodeInteger:self.permanentASPCost forKey:@"permanentASPCost"];
  [coder encodeObject:self.lpCost forKey:@"lpCost"];
  [coder encodeInteger:self.permanentLPCost forKey:@"permanentLPCost"];  
}

- (BOOL) levelUp;  // nothing to level up here
{
  NSLog(@"DSASpellMageRitual levelUp NOT YET implemented");
  return YES;
}

- (BOOL) isActiveSpell
{
  return YES;
}
@end
