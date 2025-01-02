/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 20:41:26 +0200 by sebastia

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
#import "DSATalent.h"
#import "Utils.h"

@implementation DSATalent

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      self.isPersonalTalent = NO;
    }
  return self;
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

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self)
      {
        self.name = [coder decodeObjectForKey:@"name"];
        self.level = [coder decodeIntegerForKey:@"level"];
        self.maxTriesPerLevelUp = [coder decodeIntegerForKey:@"maxTriesPerLevelUp"];
        self.maxUpPerLevel = [coder decodeIntegerForKey:@"maxUpPerLevel"];
        self.levelUpCost = [coder decodeIntegerForKey:@"levelUpCost"];        
        self.talentDescription = [coder decodeObjectForKey:@"talentDescription"];
        self.category = [coder decodeObjectForKey:@"category"];
        self.isPersonalTalent = [coder decodeBoolForKey:@"isPersonalTalent"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeInteger:self.level forKey:@"level"];
  [coder encodeInteger:self.maxTriesPerLevelUp forKey:@"maxTriesPerLevelUp"];
  [coder encodeInteger:self.maxUpPerLevel forKey:@"maxUpPerLevel"];
  [coder encodeInteger:self.levelUpCost forKey:@"levelUpCost"];  
  [coder encodeObject:self.talentDescription forKey:@"talentDescription"];
  [coder encodeObject:self.category forKey:@"category"];
  [coder encodeBool:self.isPersonalTalent forKey:@"isPersonalTalent"];    
}

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSATalent *copy = [[[self class] allocWithZone:zone] init];

  Class currentClass = [self class];
  while (currentClass != [NSObject class])
    {  // Loop through class hierarchy
      // Get a list of all properties for this class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        
      // Iterate over each property
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          // Get the property name
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];

          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }
            
          // Get the value of the property for the current object
          id value = [self valueForKey:key];

          if (value)
            {
              // Handle arrays specifically
              if ([value isKindOfClass:[NSArray class]])
                {
                  // Create a mutable array to copy the elements
                  NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                  for (id item in (NSArray *)value)
                    {
                      if ([item conformsToProtocol:@protocol(NSCopying)])
                        {
                          [copiedArray addObject:[item copyWithZone:zone]];
                        } else {
                          [copiedArray addObject:item]; // Fallback to shallow copy
                        }
                    }
                  [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
                }
              // Check if the property conforms to NSCopying
              else if ([value conformsToProtocol:@protocol(NSCopying)])
                {
                  [copy setValue:[value copyWithZone:zone] forKey:key];
                }
              else
                {
                    // Just assign the reference (shallow copy)
                    [copy setValue:value forKey:key];
                }
            }
        }

      // Free the property list memory
      free(properties);
        
      // Move to superclass
      currentClass = [currentClass superclass];
    }    
  return copy;
}



- (BOOL) levelUp
{
  NSInteger result = 0;
  
  if (self.level < 10  && ! self.isPersonalTalent)
    {
      result = [Utils rollDice:@"2W6"];
    }
  else
    {
      result = [Utils rollDice:@"3W6"];
    }
  if (result > self.level)
    {
      self.level += 1;
      return YES;
    }
  else
    {
      return NO;
    }
}

@end
