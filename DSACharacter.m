/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-08 00:03:31 +0200 by sebastia

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

#import "DSACharacter.h"

@implementation DSACharacter

@synthesize name = _name;
@synthesize age = _age;

// Since we use NSKeyedArchiver, and we use secure coding
// we have to support it with the following three methods
// BUT: GNUstep doesn't support the SecureCoding protocol yet :(
+ (BOOL)supportsSecureCoding
{
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.age forKey:@"age"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
      self.age = [coder decodeObjectOfClass:[NSString class] forKey:@"age"];
    }
  return self;
}

@end
