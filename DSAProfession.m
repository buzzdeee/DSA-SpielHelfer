/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-23 20:12:10 +0200 by sebastia

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

#import "DSAProfession.h"

@implementation DSAProfession

- (instancetype)initProfession: (NSString *) name
                    ofCategory: (NSString *) category
                       onLevel: (NSNumber *) level
                      withTest: (NSArray *) test
        withMaxTriesPerLevelUp: (NSNumber *) maxTriesPerLevelUp
             withMaxUpPerLevel: (NSNumber *) maxUpPerLevel
             influencesTalents: (NSMutableDictionary *)talents
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
      self.level = level;
      self.test = test;
      self.maxTriesPerLevelUp = maxTriesPerLevelUp;
      self.maxUpPerLevel = maxUpPerLevel;
      self.influencesTalents = talents;     
    }
  return self;
}                       

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.influencesTalents = [coder decodeObjectForKey:@"influencesTalents"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.influencesTalents forKey:@"influencesTalents"];  
}


@end