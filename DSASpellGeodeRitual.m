/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-09 23:05:56 +0100 by sebastia

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

#import "DSASpellGeodeRitual.h"

@implementation DSASpellGeodeRitual
- (instancetype)initSpell: (NSString *) name
               ofCategory: (NSString *) category
                 withTest: (NSArray *) test
                isLearned: (BOOL) learned
{
  self = [super initSpell: name
               ofCategory: category
                  onLevel: 0
               withOrigin: nil
                 withTest: test
   withMaxTriesPerLevelUp: 0
        withMaxUpPerLevel: 0
          withLevelUpCost: 0];
  if (self)
    {
      self.isLearned = learned;
    }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.isLearned = [coder decodeBoolForKey:@"isLearned"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{ 
  [super encodeWithCoder: coder];
  [coder encodeBool:self.isLearned forKey:@"isLearned"];
}

- (BOOL) levelUp;  // in this case means learn the spell (:
{
  NSLog(@"DSASpellGeodeRitual levelUp NOT YET implemented");
  return YES;
}

- (BOOL) isActiveSpell
{
  return self.isLearned;
}
@end
