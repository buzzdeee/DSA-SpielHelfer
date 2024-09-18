/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 23:01:49 +0200 by sebastia

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

#import <objc/runtime.h>
#import "DSASpell.h"

@implementation DSASpell

- (instancetype)initWithLevel: (NSNumber *) level
{
  self = [super init];
  if (self)
    {
      _level = level;
    }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _level = [coder decodeObjectForKey:@"level"];
        _origin = [coder decodeObjectForKey:@"origin"];
        _name = [coder decodeObjectForKey:@"name"];
        _longName = [coder decodeObjectForKey:@"longName"];
        _category = [coder decodeObjectForKey:@"category"];
        _technique = [coder decodeObjectForKey:@"technique"];
        _test = [coder decodeObjectForKey:@"test"];
        _spellDuration = [coder decodeObjectForKey:@"spellDuration"];
        _spellingDuration = [coder decodeObjectForKey:@"spellingDuration"];
        _spellRange = [coder decodeObjectForKey:@"spellRange"];        
        _cost = [coder decodeObjectForKey:@"cost"];
        _isHealSpell = [coder decodeObjectForKey:@"isHealSpell"];
        _isDamageSpell = [coder decodeObjectForKey:@"isDamageSpell"];
        _isAffectingCreatures = [coder decodeObjectForKey:@"isAffectingCreatures"];
        _isAffectingObjects = [coder decodeObjectForKey:@"isAffectingObjects"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.level forKey:@"level"];
  [coder encodeObject:self.origin forKey:@"origin"];
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.longName forKey:@"longName"];
  [coder encodeObject:self.category forKey:@"category"];
  [coder encodeObject:self.technique forKey:@"technique"];
  [coder encodeObject:self.test forKey:@"test"];
  [coder encodeObject:self.spellDuration forKey:@"spellDuration"];
  [coder encodeObject:self.spellingDuration forKey:@"spellingDuration"];
  [coder encodeObject:self.spellRange forKey:@"spellRange"];
  [coder encodeObject:self.cost forKey:@"cost"];
  [coder encodeObject:self.isHealSpell forKey:@"isHealSpell"];
  [coder encodeObject:self.isDamageSpell forKey:@"isDamageSpell"];
  [coder encodeObject:self.isAffectingCreatures forKey:@"isAffectingCreatures"];
  [coder encodeObject:self.isAffectingObjects forKey:@"isAffectingObjects"];   
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

@end
