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
#import "Utils.h"
#import "DSAOtherTalent.h"
#import "DSAPositiveTrait.h"
#import "DSATalentResult.h"


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
        NSLog(@"DSACharacter: allocating DSAAventurianDate in init");
        _birthday = [[DSAAventurianDate alloc] init];
        _talents = [[NSMutableDictionary alloc] init];
        _spells = [[NSMutableDictionary alloc] init];
        _specials = [[NSMutableDictionary alloc] init];
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

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSACharacter *copy = [[[self class] allocWithZone:zone] init];

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


// Since we use NSKeyedArchiver, and we use secure coding
// we have to support it with the following three methods
// BUT: GNUstep doesn't support the SecureCoding protocol yet :(
+ (BOOL)supportsSecureCoding
{
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
/*  // Get the image's representations (NSImage can have multiple representations)
  NSImageRep *imageRep = [[self.portrait representations] objectAtIndex:0];    
  // Check if the representation is a bitmap image rep and convert it to PNG data
  if ([imageRep isKindOfClass:[NSBitmapImageRep class]])
    {
      NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)imageRep;        
      // Get PNG representation of the image
      NSData *pngData = [bitmapRep representationUsingType:NSPNGFileType properties:@{}];        
      // Encode the PNG data with a key
      [coder encodeObject:pngData forKey:@"portraitData"];
    } */
  [coder encodeObject:self.portraitName forKey:@"portraitName"];  
  [coder encodeObject:self.modelID forKey:@"modelID"];  
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.title forKey:@"title"];
  [coder encodeObject:self.archetype forKey:@"archetype"];
  [coder encodeInteger:self.level forKey:@"level"];
  [coder encodeInteger:self.lifePoints forKey:@"lifePoints"];
  [coder encodeInteger:self.astralEnergy forKey:@"astralEnergy"];
  [coder encodeInteger:self.karmaPoints forKey:@"karmaPoints"];
  [coder encodeInteger:self.currentLifePoints forKey:@"currentLifePoints"];
  [coder encodeInteger:self.currentAstralEnergy forKey:@"currentAstralEnergy"];
  [coder encodeInteger:self.currentKarmaPoints forKey:@"currentKarmaPoints"];
  [coder encodeBool:self.isMagic forKey:@"isMagic"];
  [coder encodeBool:self.isMagicalDabbler forKey:@"isMagicalDabbler"]; 
  [coder encodeBool:self.isBlessedOne forKey:@"isBlessedOne"];    
  [coder encodeInteger:self.mrBonus forKey:@"mrBonus"];
  [coder encodeInteger:self.adventurePoints forKey:@"adventurePoints"];
  [coder encodeObject:self.origin forKey:@"origin"];
  [coder encodeObject:self.mageAcademy forKey:@"mageAcademy"];
  [coder encodeObject:self.element forKey:@"element"];
  [coder encodeObject:self.sex forKey:@"sex"];
  [coder encodeObject:self.hairColor forKey:@"hairColor"];
  [coder encodeObject:self.eyeColor forKey:@"eyeColor"];
  [coder encodeObject:@(self.height) forKey:@"height"];
  [coder encodeObject:@(self.weight) forKey:@"weight"];
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
  [coder encodeObject:self.currentPositiveTraits forKey:@"currentPositiveTraits"];
  [coder encodeObject:self.currentNegativeTraits forKey:@"currentNegativeTraits"];  
  [coder encodeObject:self.inventory forKey:@"inventory"];
  [coder encodeObject:self.bodyParts forKey:@"bodyParts"];
  [coder encodeObject:self.talents forKey:@"talents"];
  [coder encodeObject:self.spells forKey:@"spells"];
  [coder encodeObject:self.specials forKey:@"specials"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
/*      // Decode the PNG data
      NSData *imageData = [coder decodeObjectForKey:@"portraitData"]; 
      // Convert the PNG data back to an NSImage
      if (imageData)
        {
          self.portrait = [[NSImage alloc] initWithData:imageData];
        }     */
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
      self.portraitName = [coder decodeObjectForKey:@"portraitName"];
      self.name = [coder decodeObjectForKey:@"name"];
      self.title = [coder decodeObjectForKey:@"title"];
      self.archetype = [coder decodeObjectForKey:@"archetype"];
      self.level = [coder decodeIntegerForKey:@"level"];
      self.lifePoints = [coder decodeIntegerForKey:@"lifePoints"];
      self.astralEnergy = [coder decodeIntegerForKey:@"astralEnergy"];
      self.karmaPoints = [coder decodeIntegerForKey:@"karmaPoints"];
      self.currentLifePoints = [coder decodeIntegerForKey:@"currentLifePoints"];
      self.currentAstralEnergy = [coder decodeIntegerForKey:@"currentAstralEnergy"];
      self.currentKarmaPoints = [coder decodeIntegerForKey:@"currentKarmaPoints"];   
      self.mrBonus = [coder decodeIntegerForKey:@"mrBonus"];         
      self.isMagic = [coder decodeBoolForKey:@"isMagic"];
      self.isMagicalDabbler = [coder decodeBoolForKey:@"isMagicalDabbler"];      
      self.isBlessedOne = [coder decodeBoolForKey:@"isBlessedOne"];      
      self.adventurePoints = [coder decodeIntegerForKey:@"adventurePoints"];
      self.origin = [coder decodeObjectForKey:@"origin"];
      self.mageAcademy = [coder decodeObjectForKey:@"mageAcademy"];
      self.element = [coder decodeObjectForKey:@"element"];
      self.sex = [coder decodeObjectForKey:@"sex"];
      self.hairColor = [coder decodeObjectForKey:@"hairColor"];
      self.eyeColor = [coder decodeObjectForKey:@"eyeColor"];
      self.height = [[coder decodeObjectForKey:@"height"] floatValue];
      self.weight = [[coder decodeObjectForKey:@"weight"] floatValue];
      self.birthday = [coder decodeObjectForKey:@"birthday"];
      self.god = [coder decodeObjectForKey:@"god"];
      self.stars = [coder decodeObjectForKey:@"stars"];
      self.religion = [coder decodeObjectForKey:@"religion"];      
      self.socialStatus = [coder decodeObjectForKey:@"socialStatus"];
      self.parents = [coder decodeObjectForKey:@"parents"];
      self.siblings = [coder decodeObjectForKey:@"siblings"];
      self.birthPlace = [coder decodeObjectForKey:@"birthPlace"];
      self.birthEvent = [coder decodeObjectForKey:@"birthEvent"];
      self.legitimation = [coder decodeObjectForKey:@"legitimation"];
      self.childhoodEvents = [coder decodeObjectForKey:@"childhoodEvents"];
      self.youthEvents = [coder decodeObjectForKey:@"youthEvents"];
      self.money = [coder decodeObjectForKey:@"money"];
      self.positiveTraits = [coder decodeObjectForKey:@"positiveTraits"];
      self.negativeTraits = [coder decodeObjectForKey:@"negativeTraits"];
      self.currentPositiveTraits = [coder decodeObjectForKey:@"currentPositiveTraits"];
      self.currentNegativeTraits = [coder decodeObjectForKey:@"currentNegativeTraits"];      
      self.inventory = [coder decodeObjectForKey:@"inventory"];
      self.bodyParts = [coder decodeObjectForKey:@"bodyParts"];
      self.talents = [coder decodeObjectForKey:@"talents"];
      self.spells = [coder decodeObjectForKey:@"spells"];
      self.specials = [coder decodeObjectForKey:@"specials"];                 
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

// Calculate load of carried items
- (float)load {
    float totalWeight = 0.0;
    NSMutableSet<DSAObject *> *countedItems = [NSMutableSet set]; // For multi-slot items
    
    // Add weight from the general inventory
    totalWeight += [self weightOfInventory:self.inventory countedItems:countedItems];
    
    // Add weight from each body part inventory
    for (NSString *inventoryName in self.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [self.bodyParts valueForKey:inventoryName];
        totalWeight += [self weightOfInventory:inventory countedItems:countedItems];
    }
    
    return totalWeight;
}

- (float)weightOfInventory:(DSAInventory *)inventory countedItems:(NSMutableSet<DSAObject *> *)countedItems {
    float totalWeight = 0.0;
//    NSLog(@"weightOfInventory before for loop: %@", inventory);
    for (DSASlot *slot in inventory.slots) {
        DSAObject *item = slot.object;
//        NSLog(@"weightOfInventory %@", item.name);
        if (!item) continue; // Skip empty slots
        
        if ([countedItems containsObject:item]) {
            continue; // Skip already-counted multi-slot items
        }
        
        // Add the item's weight, considering quantity
        if ([item isKindOfClass:[DSAObjectContainer class]]) {
            // For containers, include the weight of the container and its contents
            DSAObjectContainer *container = (DSAObjectContainer *)item;
//            NSLog(@"found a container: %@", container);
            totalWeight += (item.weight + [self weightOfContainer:container countedItems:countedItems]);
        } else {
            // Add the item's weight, multiplied by quantity for single-slot items
            totalWeight += item.weight * slot.quantity;
        }
        
        // If this is a multi-slot item, mark it as counted
        if (item.occupiedBodySlots.count > 0) {
            [countedItems addObject:item];
        }
    }
    
    return totalWeight;
}

- (float)weightOfContainer:(DSAObjectContainer *)container countedItems:(NSMutableSet<DSAObject *> *)countedItems {
    float totalWeight = 0.0;
//    NSLog(@"weightOfContainer %@ before for loop", container);

    // If the container has no slots, its weight is just the container itself
    if ([container.slots count] == 0) {
//        NSLog(@"weightOfContainer returning totalWeight: %f", totalWeight);
        return totalWeight;
    }

    // Iterate over the slots in the container
    for (DSASlot *slot in container.slots) { // Assuming `slots` is an array of `DSASlot`
        DSAObject *containedItem = slot.object; // Get the actual object in the slot
        if (!containedItem) {
            continue; // Skip empty slots
        }

//        NSLog(@"weightOfContainer inspecting item: %@", containedItem.name);

        if ([countedItems containsObject:containedItem]) {
            continue; // Skip already-counted items to avoid infinite recursion or double-counting
        }

        if ([containedItem isKindOfClass:[DSAObjectContainer class]]) {
            // Recursively calculate weight for nested containers
            DSAObjectContainer *nestedContainer = (DSAObjectContainer *)containedItem;
            totalWeight += (containedItem.weight + [self weightOfContainer:nestedContainer countedItems:countedItems]);
        } else {
            totalWeight += containedItem.weight;
        }

        // Mark the item as counted if it's a multi-slot item
        if (containedItem.occupiedBodySlots.count > 0) {
            [countedItems addObject:containedItem];
        }
    }

//    NSLog(@"weightOfContainer returning totalWeight: %f", totalWeight);
    return totalWeight;
}

- (float)encumbrance {
    float totalEncumbrance = 0.0;
    NSMutableSet<DSAObject *> *countedItems = [NSMutableSet set];

    // Iterate over body parts inventories
    for (NSString *propertyName in self.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [self.bodyParts valueForKey:propertyName];

        // Iterate through all slots in the body part inventory
        for (DSASlot *slot in inventory.slots) {
            DSAObject *item = slot.object;

            // Skip empty slots
            if (!item) {
                continue;
            }

            // Skip already-counted multi-slot items
            if ([countedItems containsObject:item]) {
                continue;
            }

            // Add the penalty value to the total if it exists
            if (item.penalty > 0) {
                totalEncumbrance += item.penalty;
            }

            // Mark multi-slot items as counted
            if (item.occupiedBodySlots.count > 0) {
                [countedItems addObject:item];
            }
        }
    }

    return totalEncumbrance;
}

- (float)armor {
    float totalArmor = 0.0;
    NSMutableSet<DSAObject *> *countedItems = [NSMutableSet set];

    // Iterate over body parts inventories
    for (NSString *propertyName in self.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [self.bodyParts valueForKey:propertyName];

        // Iterate through all slots in the body part inventory
        for (DSASlot *slot in inventory.slots) {
            DSAObject *item = slot.object;

            // Skip empty slots
            if (!item) {
                continue;
            }

            // Skip already-counted multi-slot items
            if ([countedItems containsObject:item]) {
                continue;
            }

            // Add the penalty value to the total if it exists
            if (item.protection > 0) {
                totalArmor += item.protection;
            }

            // Mark multi-slot items as counted
            if (item.occupiedBodySlots.count > 0) {
                [countedItems addObject:item];
            }
        }
    }
    return roundf(totalArmor);
}

- (NSImage *)portrait {
    // Dynamically load the portrait from the app bundle
    if (self.portraitName) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:self.portraitName ofType:nil];
        if (imagePath) {
            return [[NSImage alloc] initWithContentsOfFile:imagePath];
        }
    }
    return nil; // Return nil if the portraitName or imagePath is invalid
}

- (BOOL) canUseItem: (DSAObject *) item
{
  return YES;
}

- (BOOL) canCastSpell
{
  NSLog(@"DSACharacter canCastSpell called, TO BE ENHANCED!!!");
  if (self.spells || self.specials)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (BOOL) canUseTalent
{
  NSLog(@"DSACharacter canUseTalent called, TO BE ENHANCED!!!");
  return YES;
}

- (BOOL) canRegenerate
{
  NSLog(@"DSACharacter canRegenerate called, TO BE ENHANCED!!!");
  if (self.currentAstralEnergy < self.astralEnergy || 
      self.currentLifePoints < self.lifePoints)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (DSATalentResult *) useTalent: (NSString *) talentName withPenalty: (NSInteger) penalty
{
  NSLog(@"DSACharacter useTalent called");
  DSATalentResult *talentResult = [[DSATalentResult alloc] init];
  for (DSAOtherTalent *talent in [self.talents allValues])
    {
      if ([talent.name isEqualToString: talentName])
        {
          NSInteger level = talent.level - penalty;
          NSInteger initialLevel = level;
          NSMutableArray *resultsArr = [[NSMutableArray alloc] init];
          NSInteger oneCounter = 0;
          NSInteger twentyCounter = 0;
          BOOL earlyFailure = NO;
          NSInteger counter = 0;
          for (NSString *trait in talent.test)
            {
              NSInteger traitLevel = [[self.positiveTraits objectForKey: trait] level];
              NSInteger result = [Utils rollDice: @"1W20"];
              [resultsArr addObject: @{ @"trait": trait, @"result": @(result) }];
              
              if (result == 1)
                {
                  oneCounter += 1;
                }
              else if (result == 20)
                {
                  twentyCounter += 1;
                }
              if (initialLevel >= 0)
                {
                  NSLog(@"%@ initial Level > 0 current Level: %ld", trait, (signed long) level);
                  if (result <= traitLevel)  // potential failure, but we may have enough talent
                    {
                      NSLog(@"result was <= traitLevel");

                    }
                  else
                    {
                      NSLog(@"result was > traitLevel");
                      level = level - (result - traitLevel);
                      if (level < 0)
                        {
                          earlyFailure = YES;
                        }                      
                    }
                }
              else  // initialLevel < 0
                {
                  NSLog(@"%@ initial Level < 0 current Level: %ld", trait, (signed long) level);
                  if (result <= traitLevel)
                    {
                      NSLog(@"result was <= traitLevel");
                      level = level + (traitLevel - result);
                      if (level < 0 && counter == 2)
                        {
                          NSLog(@"setting early failure becaue counter == 2");
                          earlyFailure = YES;
                        }
                    }
                  else
                    {
                      NSLog(@"result was > traitLevel");
                      earlyFailure = YES;
                    }
                }
              counter += 1;
          
            }
          if (oneCounter >= 2)
            {
              if (oneCounter == 2)
                {
                   talentResult.result = DSATalentResultAutoSuccess;
                   talentResult.remainingTalentPoints = level;
                }
              else
                {
                   talentResult.result = DSATalentResultEpicSuccess;
                   talentResult.remainingTalentPoints = level;
                }
            }
          else if (twentyCounter >= 2)
            {
              if (twentyCounter == 2)
                {
                   talentResult.result = DSATalentResultAutoFailure;
                   talentResult.remainingTalentPoints = level;
                }
              else
                {
                   talentResult.result = DSATalentResultEpicFailure;
                   talentResult.remainingTalentPoints = level;
                }              
            }
          else
            {
              if (earlyFailure == YES)
                {
                   talentResult.result = DSATalentResultFailure;
                   talentResult.remainingTalentPoints = level;                                    
                }
              else
                {
                   talentResult.result = DSATalentResultSuccess;
                   talentResult.remainingTalentPoints = level;                
                }
            }
          talentResult.diceResults = resultsArr;
        }
    }
  
  return talentResult;
}
@end
