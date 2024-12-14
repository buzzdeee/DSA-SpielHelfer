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

#import <objc/runtime.h>
#import "DSACharacter.h"
#import "AppKit/AppKit.h"

#import "DSACharacterHeroHumanAmazon.h"
#import "DSACharacterHeroHumanJuggler.h"
#import "DSACharacterHeroHumanHuntsman.h"
#import "DSACharacterHeroHumanWarrior.h"
#import "DSACharacterHeroHumanPhysician.h"


@implementation DSACharacter

static NSDictionary<NSString *, Class> *typeToClassMap = nil;
static NSMutableDictionary<NSString *, DSACharacter *> *characterRegistry = nil;


+ (void)initialize {
    if (self == [DSACharacter class]) {
        @synchronized(self) {
            if (!characterRegistry) {
                characterRegistry = [NSMutableDictionary dictionary];
            }
            if (!typeToClassMap) {
                typeToClassMap = @{
                    _(@"Alchimist"): [DSACharacterHeroHumanAmazon class],
                    _(@"Amazone"): [DSACharacterHeroHumanAmazon class],
                    _(@"Gaukler"): [DSACharacterHeroHumanJuggler class],
                    _(@"Jäger"): [DSACharacterHeroHumanHuntsman class],
                    _(@"Krieger"): [DSACharacterHeroHumanWarrior class],
                    _(@"Medicus"): [DSACharacterHeroHumanPhysician class],
                };
            }
        }
    }
}

+ (instancetype)characterWithType:(NSString *)type {
    Class subclass = [typeToClassMap objectForKey:type];
    if (subclass) {
        return [[subclass alloc] init];
    }
    // Handle unknown type
    return nil;
}

+ (DSACharacter *)characterWithModelID:(NSString *)modelID {
    @synchronized(characterRegistry) {
    for (NSString *key in [characterRegistry allKeys]) {
        if ([key isEqualToString:modelID]) {
            NSLog(@"Found matching modelID: %@", key);
            return characterRegistry[modelID];
        }
    }    
        NSLog(@"searching character with model ID: %@ in all keys: %@", modelID, [characterRegistry allKeys]);
        return characterRegistry[modelID];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Generate a unique UUID for modelID
        @synchronized([DSACharacter class]) {
            if (!characterRegistry) {
                characterRegistry = [NSMutableDictionary dictionary];
            }

            _modelID = [[NSUUID UUID] UUIDString]; // Use NSUUID for a truly unique ID
            NSLog(@"Generated modelID: %@", _modelID);

            if (!characterRegistry[_modelID]) {
                characterRegistry[_modelID] = self; // Register the character
            } else {
                NSLog(@"Warning: modelID %@ already exists!", _modelID);
            }
        }

        // Initialize other properties
        _isMagic = NO;
        _isBlessedOne = NO;
        _isMagicalDabbler = NO;
        _element = nil;
        _religion = nil;
        _siblings = [[NSArray alloc] init];
        _childhoodEvents = [[NSArray alloc] init];
        _youthEvents = [[NSArray alloc] init];
        _inventory = [[DSAInventory alloc] init];
        _bodyParts = [[DSABodyParts alloc] init];
    }
    return self;
}

- (void)dealloc
{
    @synchronized([DSACharacter class]) {
        [characterRegistry removeObjectForKey:_modelID];
        NSLog(@"Character with modelID %@ removed from registry.", _modelID);
    }
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

// Since we use NSKeyedArchiver, and we use secure coding
// we have to support it with the following three methods
// BUT: GNUstep doesn't support the SecureCoding protocol yet :(
+ (BOOL)supportsSecureCoding
{
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  // Get the image's representations (NSImage can have multiple representations)
  NSImageRep *imageRep = [[self.portrait representations] objectAtIndex:0];    
  // Check if the representation is a bitmap image rep and convert it to PNG data
  if ([imageRep isKindOfClass:[NSBitmapImageRep class]])
    {
      NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)imageRep;        
      // Get PNG representation of the image
      NSData *pngData = [bitmapRep representationUsingType:NSPNGFileType properties:@{}];        
      // Encode the PNG data with a key
      [coder encodeObject:pngData forKey:@"portraitData"];
    }
  [coder encodeObject:self.modelID forKey:@"modelID"];  
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.title forKey:@"title"];
  [coder encodeObject:self.archetype forKey:@"archetype"];
  [coder encodeObject:self.level forKey:@"level"];
  [coder encodeObject:self.lifePoints forKey:@"lifePoints"];
  [coder encodeObject:self.astralEnergy forKey:@"astralEnergy"];
  [coder encodeObject:self.karmaPoints forKey:@"karmaPoints"];
  [coder encodeObject:self.currentLifePoints forKey:@"currentLifePoints"];
  [coder encodeObject:self.currentAstralEnergy forKey:@"currentAstralEnergy"];
  [coder encodeObject:self.currentKarmaPoints forKey:@"currentKarmaPoints"];
  [coder encodeBool:self.isMagic forKey:@"isMagic"];
  [coder encodeBool:self.isMagicalDabbler forKey:@"isMagicalDabbler"]; 
  [coder encodeBool:self.isBlessedOne forKey:@"isBlessedOne"];    
  [coder encodeObject:self.mrBonus forKey:@"mrBonus"];
  [coder encodeObject:self.adventurePoints forKey:@"adventurePoints"];
  [coder encodeObject:self.origin forKey:@"origin"];
  [coder encodeObject:self.mageAcademy forKey:@"mageAcademy"];
  [coder encodeObject:self.element forKey:@"element"];
  [coder encodeObject:self.sex forKey:@"sex"];
  [coder encodeObject:self.hairColor forKey:@"hairColor"];
  [coder encodeObject:self.eyeColor forKey:@"eyeColor"];
  [coder encodeObject:self.height forKey:@"height"];
  [coder encodeObject:self.weight forKey:@"weight"];
  [coder encodeObject:self.birthday forKey:@"birthday"];
  [coder encodeObject:self.god forKey:@"god"];
  [coder encodeObject:self.stars forKey:@"stars"];
  [coder encodeObject:self.religion forKey:@"religion"];  
  [coder encodeObject:self.socialStatus forKey:@"socialStatus"];
  [coder encodeObject:self.parents forKey:@"parents"];
  [coder encodeObject:self.siblings forKey:@"siblings"];
  [coder encodeObject:self.birthPlace forKey:@"birthPlace"];    
  [coder encodeObject:self.birthEvent forKey:@"birthEvent"];
  [coder encodeObject:self.legitimation forKey:@"legitimation"];
  [coder encodeObject:self.childhoodEvents forKey:@"childhoodEvents"];
  [coder encodeObject:self.youthEvents forKey:@"youthEvents"];
  [coder encodeObject:self.money forKey:@"money"];
  [coder encodeObject:self.positiveTraits forKey:@"positiveTraits"];
  [coder encodeObject:self.negativeTraits forKey:@"negativeTraits"];
  [coder encodeObject:self.inventory forKey:@"inventory"];
  [coder encodeObject:self.bodyParts forKey:@"bodyParts"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      // Decode the PNG data
      NSData *imageData = [coder decodeObjectForKey:@"portraitData"]; 
      // Convert the PNG data back to an NSImage
      if (imageData)
        {
          self.portrait = [[NSImage alloc] initWithData:imageData];
        }    
      _modelID = [coder decodeObjectOfClass:[NSString class] forKey:@"modelID"];
      if (!self.modelID)
        {
          _modelID = [[NSUUID UUID] UUIDString];  //backward compat
        }
      if (!characterRegistry[_modelID]) {
          characterRegistry[_modelID] = self; // Register the character
      } else {
          NSLog(@"Warning: modelID %@ already exists!", _modelID);
      }      
      
      self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
      self.title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
      self.archetype = [coder decodeObjectOfClass:[NSString class] forKey:@"archetype"];
      self.level = [coder decodeObjectOfClass:[NSString class] forKey:@"level"];
      self.lifePoints = [coder decodeObjectOfClass:[NSString class] forKey:@"lifePoints"];
      self.astralEnergy = [coder decodeObjectOfClass:[NSString class] forKey:@"astralEnergy"];
      self.karmaPoints = [coder decodeObjectOfClass:[NSString class] forKey:@"karmaPoints"];
      self.currentLifePoints = [coder decodeObjectOfClass:[NSString class] forKey:@"currentLifePoints"];
      self.currentAstralEnergy = [coder decodeObjectOfClass:[NSString class] forKey:@"currentAstralEnergy"];
      self.currentKarmaPoints = [coder decodeObjectOfClass:[NSString class] forKey:@"currentKarmaPoints"];   
      self.mrBonus = [coder decodeObjectOfClass:[NSString class] forKey:@"mrBonus"];         
      self.isMagic = [coder decodeBoolForKey:@"isMagic"];
      self.isMagicalDabbler = [coder decodeBoolForKey:@"isMagicalDabbler"];      
      self.isBlessedOne = [coder decodeBoolForKey:@"isBlessedOne"];      
      self.adventurePoints = [coder decodeObjectOfClass:[NSString class] forKey:@"adventurePoints"];
      self.origin = [coder decodeObjectOfClass:[NSString class] forKey:@"origin"];
      self.mageAcademy = [coder decodeObjectOfClass:[NSString class] forKey:@"mageAcademy"];
      self.element = [coder decodeObjectOfClass:[NSString class] forKey:@"element"];
      self.sex = [coder decodeObjectOfClass:[NSString class] forKey:@"sex"];
      self.hairColor = [coder decodeObjectOfClass:[NSString class] forKey:@"hairColor"];
      self.eyeColor = [coder decodeObjectOfClass:[NSString class] forKey:@"eyeColor"];
      self.height = [coder decodeObjectOfClass:[NSString class] forKey:@"height"];
      self.weight = [coder decodeObjectOfClass:[NSString class] forKey:@"weight"];
      self.birthday = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"birthday"];
      self.god = [coder decodeObjectOfClass:[NSString class] forKey:@"god"];
      self.stars = [coder decodeObjectOfClass:[NSString class] forKey:@"stars"];
      self.religion = [coder decodeObjectOfClass:[NSString class] forKey:@"religion"];      
      self.socialStatus = [coder decodeObjectOfClass:[NSString class] forKey:@"socialStatus"];
      self.parents = [coder decodeObjectOfClass:[NSString class] forKey:@"parents"];
      self.siblings = [coder decodeObjectOfClass:[NSString class] forKey:@"siblings"];
      self.birthPlace = [coder decodeObjectOfClass:[NSString class] forKey:@"birthPlace"];
      self.birthEvent = [coder decodeObjectOfClass:[NSString class] forKey:@"birthEvent"];
      self.legitimation = [coder decodeObjectOfClass:[NSString class] forKey:@"legitimation"];
      self.childhoodEvents = [coder decodeObjectOfClass:[NSString class] forKey:@"childhoodEvents"];
      self.youthEvents = [coder decodeObjectOfClass:[NSString class] forKey:@"youthEvents"];
      self.money = [coder decodeObjectOfClass:[NSString class] forKey:@"money"];
      self.positiveTraits = [coder decodeObjectOfClass:[NSString class] forKey:@"positiveTraits"];
      self.negativeTraits = [coder decodeObjectOfClass:[NSString class] forKey:@"negativeTraits"];
      self.inventory = [coder decodeObjectOfClass:[NSString class] forKey:@"inventory"];
      self.bodyParts = [coder decodeObjectOfClass:[NSString class] forKey:@"bodyParts"];
    }
  return self;
}


// helper function to produce a string based on siblings.
- (NSString *)siblingsString
{
    NSString *pronoun = [self.sex isEqualToString:_(@"männlich")] ? @"Er" : @"Sie";
    NSString *genderWord = [self.sex isEqualToString:_(@"männlich")] ? @"der" : @"die";
    
    // If no siblings, return a simple message
    if ([self.siblings count] == 0) {
        return [NSString stringWithFormat:@"%@ hat keine Geschwister.", self.name];
    }
    
    // Initialize counters for siblings
    NSInteger olderBrothers = 0;
    NSInteger youngerBrothers = 0;
    NSInteger olderSisters = 0;
    NSInteger youngerSisters = 0;
    
    // Count the number of older/younger brothers and sisters
    for (NSDictionary *sibling in self.siblings) {
        NSString *age = sibling[@"age"];
        NSString *sex = sibling[@"sex"];
        
        if ([age isEqualToString:_(@"älter")]) {
            if ([sex isEqualToString:_(@"männlich")]) {
                olderBrothers++;
            } else {
                olderSisters++;
            }
        } else {  // "jünger"
            if ([sex isEqualToString:_(@"männlich")]) {
                youngerBrothers++;
            } else {
                youngerSisters++;
            }
        }
    }
    
    // Total number of children in the family
    NSInteger totalChildren = [self.siblings count] + 1;  // +1 to include the character
    NSInteger numberOfOlderSiblings = olderBrothers + olderSisters;
    NSInteger characterPosition = totalChildren - numberOfOlderSiblings;  // Position of the character among the siblings
    // Generate a detailed sibling description
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"%@ ist %@ %ldte von %ld Kindern. ", self.name, genderWord, (long)characterPosition, (long)totalChildren];
    
    NSMutableArray *siblingDescriptions = [NSMutableArray array];
    
    // Build the description based on the sibling counts
    if (olderBrothers > 0) {
        NSString *olderBrothersString = [NSString stringWithFormat:@"%ld ältere%@ Br%@der", (long)olderBrothers, olderBrothers > 1 ? @"" : @"n", olderBrothers > 1 ? @"ü" : @"u"];
        [siblingDescriptions addObject:olderBrothersString];
    }
    
    if (olderSisters > 0) {
        NSString *olderSistersString = [NSString stringWithFormat:@"%ld ältere Schwester%@", (long)olderSisters, olderSisters > 1 ? @"n" : @""];
        [siblingDescriptions addObject:olderSistersString];
    }
    
    if (youngerBrothers > 0) {
        NSString *youngerBrothersString = [NSString stringWithFormat:@"%ld jüngere%@ Br%@der", (long)youngerBrothers, youngerBrothers > 1 ? @"" : @"n", youngerBrothers > 1 ? @"ü" : @"u"];
        [siblingDescriptions addObject:youngerBrothersString];
    }
    
    if (youngerSisters > 0) {
        NSString *youngerSistersString = [NSString stringWithFormat:@"%ld jüngere Schwester%@", (long)youngerSisters, youngerSisters > 1 ? @"n" : @""];
        [siblingDescriptions addObject:youngerSistersString];
    }
    
    // Append the sibling description
    if ([siblingDescriptions count] > 0) {
        [resultString appendFormat:@"%@ hat %@.", pronoun, [siblingDescriptions componentsJoinedByString:@", "]];
    }    
    return resultString;
}

@end
