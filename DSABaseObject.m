/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-09-07 20:55:11 +0200 by sebastia

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

#import "DSABaseObject.h"

@implementation DSABaseObject

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

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
    //NSLog(@"DSABaseObject copyWithZone called!");
    // Neues Objekt vom selben Typ erzeugen
    DSABaseObject *copy = [[[self class] allocWithZone:zone] init];

    Class currentClass = [self class];
    while (currentClass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithUTF8String:propertyName];

            const char *attributes = property_getAttributes(property);
            NSString *attributesString = [NSString stringWithUTF8String:attributes];
            if ([attributesString containsString:@",R"]) {
                // readonly -> wird übersprungen
                continue;
            }

            id value = [self valueForKey:key];
            if (!value) continue;

            // --- NSArray ---
            if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                for (id item in (NSArray *)value) {
                    if ([item conformsToProtocol:@protocol(NSCopying)]) {
                        [copiedArray addObject:[item copyWithZone:zone]];
                    } else {
                        [copiedArray addObject:item];
                    }
                }
                [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
            }
            // --- NSDictionary ---
            else if ([value isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *copiedDict = [[NSMutableDictionary alloc] initWithCapacity:[(NSDictionary *)value count]];
                for (id dictKey in (NSDictionary *)value) {
                    id item = value[dictKey];
                    if ([item conformsToProtocol:@protocol(NSCopying)]) {
                        copiedDict[dictKey] = [item copyWithZone:zone];
                    } else {
                        copiedDict[dictKey] = item;
                    }
                }
                [copy setValue:[NSDictionary dictionaryWithDictionary:copiedDict] forKey:key];
            }
            // --- NSSet ---
            else if ([value isKindOfClass:[NSSet class]]) {
                NSMutableSet *copiedSet = [[NSMutableSet alloc] initWithCapacity:[(NSSet *)value count]];
                for (id item in (NSSet *)value) {
                    if ([item conformsToProtocol:@protocol(NSCopying)]) {
                        [copiedSet addObject:[item copyWithZone:zone]];
                    } else {
                        [copiedSet addObject:item];
                    }
                }
                [copy setValue:[NSSet setWithSet:copiedSet] forKey:key];
            }
            // --- alle anderen Objekte, die NSCopying unterstützen ---
            else if ([value conformsToProtocol:@protocol(NSCopying)]) {
                [copy setValue:[value copyWithZone:zone] forKey:key];
            }
            // --- Fallback: shallow copy ---
            else {
                [copy setValue:value forKey:key];
            }
        }

        free(properties);
        currentClass = [currentClass superclass];
    }

    return copy;
}

@end
