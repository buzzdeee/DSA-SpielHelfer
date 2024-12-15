/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-09 02:03:56 +0200 by sebastia

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

#import "Utils.h"
#import "DSASlot.h"

@implementation Utils

static Utils *sharedInstance = nil;
static NSMutableDictionary *objectsDict;

+ (instancetype)sharedInstance
{
  @synchronized(self)
    {
      if (sharedInstance == nil)
        {
          sharedInstance = [[self alloc] init];
            // Perform additional setup if needed
          NSError *e = nil;
          NSString *filePath;
          filePath = [[NSBundle mainBundle] pathForResource:@"Ausruestung" ofType:@"json"];
          objectsDict = [NSJSONSerialization 
          JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
               options: NSJSONReadingMutableContainers
                 error: &e];
          if (e)
            {
               NSLog(@"Error loading JSON: %@", e.localizedDescription);
            }
          else
            {
              [Utils enrichEquipmentData: objectsDict withParentKeys:@[]];
            }                            
            
        }
    }
  return sharedInstance;
}

- (instancetype)init
{
  self = [super init];
  if (self)
    {
   
    }
  return self;
}

+ (NSDictionary *) getDSAObjectsDict
{
  //NSLog(@"Utils: getDSAObjectsDict %@", objectsDict);
  return objectsDict;
}

+ (void)enrichEquipmentData:(NSMutableDictionary *)data withParentKeys:(NSArray<NSString *> *)parentKeys {
    for (NSString *key in data) {
        id value = data[key];
        if ([value isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *entry = (NSMutableDictionary *)value;

            // Add category flags based on the presence of specific keys
            entry[@"Name"] = [key copy];
            
            if (entry[@"TrefferpunkteKK"] != nil) {
                entry[@"isHandWeapon"] = @YES;
            }
            if (entry[@"TP Entfernung"] != nil) {
                entry[@"isDistantWeapon"] = @YES;
            }
            if (entry[@"Rüstschutz"] != nil) {
                entry[@"isArmor"] = @YES;
            }
            if (entry[@"Slottypen"] != nil)
              {
                entry[@"isContainer"] = @YES;
              }
            
            // Optionally, compute and format additional fields here
            if (entry[@"Trefferpunkte"] != nil) {
                entry[@"TP"] = [entry[@"Trefferpunkte"] componentsJoinedByString:@", "];
            }
            if (entry[@"TP Entfernung"] != nil) {
                entry[@"TP Entfernung Formatted"] = [Utils formatTPEntfernung:entry[@"TP Entfernung"]];
            }
            if (entry[@"Waffenvergleichswert"] != nil) {
                NSString *waffenvergleichswert = entry[@"Waffenvergleichswert"];
                NSArray *values = [waffenvergleichswert componentsSeparatedByString:@"/"];
    
                if (values.count == 2) {
                  // Parse the attackPower and parryValue as integers
                  NSInteger attackPower = [values[0] integerValue];
                  NSInteger parryValue = [values[1] integerValue];
        
                  // Assign them back to the dictionary
                  entry[@"attackPower"] = @(attackPower);
                  entry[@"parryValue"] = @(parryValue);
                } else {
                  NSLog(@"Invalid Waffenvergleichswert format: %@", waffenvergleichswert);
                }
            }          
            if (entry[@"Regionen"] != nil) {
                entry[@"Regionen Formatted"] = [entry[@"Regionen"] componentsJoinedByString:@", "];
                NSArray *regionen = [NSArray arrayWithArray: entry[@"Regionen"]];
                entry[@"Regionen"] = regionen;
            }
            
            // Add hierarchical information
            entry[@"category"] = parentKeys.count > 0 ? parentKeys[0] : @"";
            entry[@"subCategory"] = parentKeys.count > 1 ? parentKeys[1] : @"";
            entry[@"subSubCategory"] = parentKeys.count > 2 ? parentKeys[2] : @"";

            if ([entry[@"category"] isEqualToString: @"Behälter"])
              {
                entry[@"isContainer"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Werkzeug"])
              {
                entry[@"isTool"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Kleidung und Schuhwerk"])
              {
                entry[@"isCloth"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Musikinstrumente"])
              {
                entry[@"isInstrument"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Musikinstrumente"])
              {
                entry[@"isInstrument"] = @YES;
              }
            if ([entry[@"category"] isEqualToString: @"Nahrungs- und Genußmittel"])
              {
                entry[@"isConsumable"] = @YES;
              }

            if ([entry[@"MehrereProSlot"] isEqualTo: @YES])
              {
                entry[@"canShareSlot"] = @YES;
              }              
              
            // Add the slot types parsing logic here
            NSArray *validSlotTypes = entry[@"ErlaubteInventorySlots"];
            NSMutableArray<NSNumber *> *validSlotTypesEnum = [NSMutableArray array];

            // If validSlotTypes is missing or empty, default to DSASlotTypeGeneral
            if (validSlotTypes == nil || validSlotTypes.count == 0) {
                [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
            } else {
                // Convert slot types in JSON to DSASlotType enums
                for (NSString *slotTypeString in validSlotTypes) {
                    DSASlotType slotType = [self slotTypeFromString:slotTypeString];
                    if (slotType != NSNotFound) {
                        [validSlotTypesEnum addObject:@(slotType)];
                    }
                }
                // Always add DSASlotTypeGeneral to the list of valid slot types
                [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
            }

            // Store the parsed validSlotTypes as enum values
            entry[@"validSlotTypes"] = validSlotTypesEnum;              
            
            NSArray *occupiedBodySlots = entry[@"belegteKörperSlots"];
            NSMutableArray<NSNumber *> * occupiedBodySlotsEnum = [NSMutableArray array];
            // If occupiedBodySlots is missing or empty, we're fine with it, the item only occpuies a single named slot
            if (occupiedBodySlots == nil || occupiedBodySlots.count == 0) {
                occupiedBodySlots = nil;
            } else {
                // Convert slot types in JSON to DSASlotType enums
                for (NSString *slotTypeString in occupiedBodySlots) {
                    DSASlotType slotType = [self slotTypeFromString:slotTypeString];
                    if (slotType != NSNotFound) {
                        [occupiedBodySlotsEnum addObject:@(slotType)];
                    }
                }
            }
            entry[@"occupiedBodySlots"] = occupiedBodySlotsEnum;
                        
            // Recurse into deeper dictionaries with updated hierarchy
            [Utils enrichEquipmentData:entry withParentKeys:[parentKeys arrayByAddingObject:key]];
        } else if ([value isKindOfClass:[NSMutableArray class]]) {
            // Handle arrays of dictionaries (if applicable)
            for (id subValue in (NSMutableArray *)value) {
                if ([subValue isKindOfClass:[NSMutableDictionary class]]) {
                    [Utils enrichEquipmentData:(NSMutableDictionary *)subValue withParentKeys:parentKeys];
                }
            }
        }
    }
}

// helper method to enrich object data
+ (DSASlotType)slotTypeFromString:(NSString *)slotTypeString {
    NSDictionary<NSString *, NSNumber *> *slotTypeMapping = @{
        @"Allgemein" : @(DSASlotTypeGeneral),
        @"Unterwäsche" : @(DSASlotTypeUnderwear),
        @"Körperrüstung" : @(DSASlotTypeBodyArmor),
        @"Kopfbedeckung" : @(DSASlotTypeHeadgear),
        @"Schuh" : @(DSASlotTypeShoes),
        @"Halskette" : @(DSASlotTypeNecklace),
        @"Ohrring" : @(DSASlotTypeEarring),
        @"Brille" : @(DSASlotTypeGlasses),
        @"Maske" : @(DSASlotTypeMask),
        @"Rucksack" : @(DSASlotTypeBackpack),
        @"Rückenköcher" : @(DSASlotTypeBackquiver),
        @"Schärpe" : @(DSASlotTypeSash),
        @"Armrüstung" : @(DSASlotTypeArmArmor),
        @"Handschuhe" : @(DSASlotTypeGloves),
        @"Hüfte" : @(DSASlotTypeHip),
        @"Ring" : @(DSASlotTypeRing),
        @"Weste" : @(DSASlotTypeVest),
        @"Shirt" : @(DSASlotTypeShirt),
        @"Jacke" : @(DSASlotTypeJacket),
        @"Beingurt" : @(DSASlotTypeLegbelt),
        @"Beinrüstung" : @(DSASlotTypeLegArmor),
        @"Beinkleidung" : @(DSASlotTypeTrousers),
        @"Socke" : @(DSASlotTypeSocks),
        @"Schuhaccesoir" : @(DSASlotTypeShoeaccessories),
        @"Sack" : @(DSASlotTypeBag),
        @"Korb" : @(DSASlotTypeBasket),
        @"Köcher" : @(DSASlotTypeQuiver),
        @"Bolzentasche" : @(DSASlotTypeBoltbag),
        @"Flasche" : @(DSASlotTypeBottle),
        @"Schwert" : @(DSASlotTypeSword),
        @"Dolch" : @(DSASlotTypeDagger),
        @"Axt" : @(DSASlotTypeAxe)
    };

    // Look up the corresponding slot type
    NSNumber *slotTypeNumber = slotTypeMapping[slotTypeString];
    return slotTypeNumber ? slotTypeNumber.unsignedIntegerValue : NSNotFound;
}

// another helper method
+ (NSMutableArray<NSNumber *> *)parseValidSlotTypesForItem:(NSDictionary *)itemData {
    NSArray<NSString *> *validSlotTypes = itemData[@"validSlotTypes"];
    NSMutableArray<NSNumber *> *validSlotTypesEnum = [NSMutableArray array];

    // If validSlotTypes is empty or nil, default to "General"
    if (validSlotTypes == nil || validSlotTypes.count == 0) {
        [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
    } else {
        // Convert slot types in JSON to DSASlotType enums
        for (NSString *slotTypeString in validSlotTypes) {
            DSASlotType slotType = [self slotTypeFromString:slotTypeString];
            if (slotType != NSNotFound) {
                [validSlotTypesEnum addObject:@(slotType)];
            }
        }
        // Always add "General" slot type to the list
        [validSlotTypesEnum addObject:@(DSASlotTypeGeneral)];
    }

    return validSlotTypesEnum;
}

+ (NSString *)formatTPEntfernung:(NSDictionary *)tpEntfernung {
    if (![tpEntfernung isKindOfClass:[NSDictionary class]]) {
        return @"";
    }    
    // Extract the values in order of the keys
    NSArray<NSString *> *orderedKeys = @[@"extrem nah", @"sehr nah", @"nah", @"mittel", @"weit", @"sehr weit", @"extrem weit"];
    NSMutableArray<NSString *> *values = [NSMutableArray array];
    
    for (NSString *key in orderedKeys) {
        NSNumber *value = tpEntfernung[key];
        if (value) {
            [values addObject:value.stringValue];
        } else {
            [values addObject:@"-"]; // Default for missing values
        }
    }
    
    // Join the values with "/"
    return [values componentsJoinedByString:@"/"];
}

+ (NSDictionary *)getDSAObjectInfoByName:(NSString *)name
{
  NSMutableArray *categories = [NSMutableArray array]; // To track category path
  NSDictionary *result = [self searchForDSAObjectWithName: name
                                             inDictionary: objectsDict
                                            categoryStack: categories];

  if (result && categories.count > 0)
    {
       NSMutableDictionary *resultWithCategories = [result mutableCopy];
       for (NSInteger i = 0; i < categories.count; i++)
         {
           NSString *key = [NSString stringWithFormat:@"category%@", (i == 0 ? @"" : [NSString stringWithFormat:@"%ld", (long)i])];
           resultWithCategories[key] = categories[i];
         }
       resultWithCategories[@"name"] = name;
       return [resultWithCategories copy];
    }
  return result;
}

+ (NSDictionary *)searchForDSAObjectWithName:(NSString *)name
                                inDictionary:(NSDictionary *)dictionary
                               categoryStack:(NSMutableArray *)categoryStack
{
  // Iterate through the dictionary
  for (NSString *key in dictionary)
    {
      id value = dictionary[key];

      if ([key isEqualToString:name] && [value isKindOfClass:[NSDictionary class]])
        {
          // Found the key matching the name, and its value is a dictionary
          return value;
        }
      else if ([value isKindOfClass:[NSDictionary class]])
        {
          // Add the current key to the category stack
          [categoryStack addObject:key];

          // Recursively search within the nested dictionary
          NSDictionary *result = [self searchForDSAObjectWithName:name inDictionary:value categoryStack:categoryStack];
          if (result)
            {
              return result; // Found in nested dictionary
            }

          // Remove the current key from the stack if not found in this branch
          [categoryStack removeLastObject];
        }
    }

  // Return nil if not found
  return nil;
}

+ (NSDictionary *) parseDice: (NSString *) diceDefinition
{
  int count, points;
  NSMutableDictionary *dice = [[NSMutableDictionary alloc] init];
  NSScanner *scanner = [NSScanner scannerWithString: diceDefinition];
  [scanner scanInt: &count];
  [scanner scanCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"W"] intoString: NULL];
  [scanner scanInt: &points];
  
  [dice setValue: [NSNumber numberWithInt: count] forKey: @"count"];
  [dice setValue: [NSNumber numberWithInt: points] forKey: @"points"];

//  NSLog(@"Utils : parseDice returning dice: %@", dice);  
  return dice;
}

+ (NSDictionary *) parseConstraint: (NSString *) constraintDefinition
{
  int value;
  NSString *cvalue;
  NSMutableDictionary *constraint = [[NSMutableDictionary alloc] init];
  NSScanner *scanner = [NSScanner scannerWithString: constraintDefinition];
  [scanner scanInt: &value];
  [scanner scanCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"+-"] intoString: &cvalue];
  
  [constraint setValue: [NSNumber numberWithInt: value] forKey: @"value"];
  if ([cvalue isEqualToString: @"+"])
    {
      [constraint setValue: @"MAX" forKey: @"constraint"];
    }
  else
    {
      [constraint setValue: @"MIN" forKey: @"constraint"];
    }
    
  return constraint;
}

+ (NSNumber *) rollDice: (NSString *) diceDefinition
{
  NSDictionary *dice = [NSDictionary dictionaryWithDictionary: [Utils parseDice: diceDefinition]];
  int result = 0;
  for (int i=0; i<[[dice objectForKey: @"count"] intValue];i++)
    {
      result += arc4random_uniform([[dice objectForKey: @"points"] intValue]) + 1;
    }
  return [NSNumber numberWithInt: result];
}

@end
