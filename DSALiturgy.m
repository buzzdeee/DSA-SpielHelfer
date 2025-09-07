/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-17 21:20:40 +0100 by sebastia

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

#import "DSALiturgy.h"

@implementation DSALiturgy
- (instancetype)initLiturgy: (NSString *) name
                 ofCategory: (NSString *) category 
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.category = category;
    }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.name = [coder decodeObjectForKey:@"name"];
      self.category = [coder decodeObjectForKey:@"category"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.category forKey:@"category"];
}
@end
