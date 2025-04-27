/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 00:00:58 +0200 by sebastia

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
#import "DSAObject.h"

#import "Utils.h"
#import "DSASlot.h"
#import "DSASpellMageRitual.h"



@implementation DSAObject

- (instancetype) initWithName: (NSString *) name forOwner: (NSUUID *) ownerUUID
{
  self = [super init];
  NSDictionary *objectInfo = [Utils getDSAObjectInfoByName: name];
  
  return [self initWithObjectInfo: objectInfo forOwner: ownerUUID];
  
}

- (instancetype) initWithObjectInfo: (NSDictionary *) objectInfo forOwner: (NSUUID *) ownerUUID
{
  self = [super init];
  
  NSString *name = [objectInfo objectForKey: @"Name"];
  NSMutableDictionary *appliedSpells = [NSMutableDictionary new];
  NSLog(@"DSAObject initWithObjectInfo Sprüche: %@", [objectInfo objectForKey: @"Sprüche"]);
  if ([objectInfo objectForKey: @"Sprüche"] && [[objectInfo objectForKey: @"Sprüche"] count] > 0)
    {
          for (NSString *spellName in [objectInfo objectForKey: @"Sprüche"])
            {
              NSString *spellType = [Utils findSpellOrRitualTypeWithName: spellName];
              NSDictionary *spruchDict = [[objectInfo objectForKey: @"Sprüche"] objectForKey: spellName];
              DSASpell *appliedSpell;
              if ([spellType isEqualToString: @"DSASpell"])
                {
                  NSMutableDictionary *spellDict = [[Utils getSpellWithName: spellName] mutableCopy];
                  for (NSString *key in [spruchDict allKeys])
                    {
                      [spellDict setObject: [spruchDict objectForKey: key] 
                                    forKey: key];
                    }
                  appliedSpell = [DSASpell spellWithName: spellName
                                               ofVariant: [spellDict objectForKey: @"Variante"]
                                       ofDurationVariant: [spellDict objectForKey: @"Dauer Variante"]
                                              ofCategory: [spellDict objectForKey: @"category"]
                                                 onLevel: 0
                                              withOrigin: nil
                                                withTest: nil
                                         withMaxDistance: [[spellDict objectForKey: @"Maximale Entfernung"] integerValue]
                                            withVariants: [spellDict objectForKey: @"Varianten"]
                                    withDurationVariants: [spellDict objectForKey: @"Dauer Varianten"]
                                  withMaxTriesPerLevelUp: 0
                                       withMaxUpPerLevel: 0
                                         withLevelUpCost: 0];
                  
                }
              else if ([spellType isEqualToString: @"DSASpellMageRitual"])
                {
                  NSMutableDictionary *ritualDict = [[Utils getMageRitualWithName: spellName] mutableCopy];
                  for (NSString *key in [spruchDict allKeys])
                    {
                      [ritualDict setObject: [spruchDict objectForKey: key]
                                     forKey: key];
                    }
                  appliedSpell = [DSASpellMageRitual ritualWithName: spellName
                                                          ofVariant: [ritualDict objectForKey: @"Variante"]
                                                  ofDurationVariant: [ritualDict objectForKey: @"Dauer Variante"]
                                                         ofCategory: [ritualDict objectForKey: @"category"]
                                                           withTest: [ritualDict objectForKey: @"Probe"]
                                                    withMaxDistance: [[ritualDict objectForKey: @"Maximale Entfernung"] integerValue]       
                                                       withVariants: [ritualDict objectForKey: @"Varianten"]
                                               withDurationVariants: [ritualDict objectForKey: @"Dauer Varianten"]
                                                        withPenalty: [[ritualDict objectForKey: @"Probenaufschlag"] integerValue]
                                                        withASPCost: [[ritualDict objectForKey: @"ASP Kosten"] integerValue]
                                               withPermanentASPCost: [[ritualDict objectForKey: @"davon permanente ASP Kosten"] integerValue]
                                                         withLPCost: [ritualDict objectForKey: @"LP Kosten"] ? [Utils rollDice: [ritualDict objectForKey: @"LP Kosten"]] : 0  // There's only one Mage ritual, that has LP cost specified as dice roll...
                                                withPermanentLPCost: [[ritualDict objectForKey: @"davon permanente LP Kosten"] integerValue]];
                }
              if (appliedSpell)    // effects are applied at the end of the method                                 
                {
                  // [appliedSpell variant = spruchDict.spellName; HAVE TO THINK MORE ABOUT IT XXXXX
                  [appliedSpells setObject: appliedSpell
                                    forKey: spellName];
                }
              NSLog(@"THE APPLIED SPELLS: %@", [appliedSpells allKeys]);
          }
    }
  NSLog(@"APPLIED SPELL: %@ to OBJECT: %@", [appliedSpells allKeys], name);
  // first ensure that we ownly set the owner on items that are definite personal items
  // other items may set ownerUUID in a second step  
  if (![[objectInfo objectForKey: @"persönliches Objekt"] isEqualTo: @YES])
    {
      ownerUUID = nil;
    }
  
  NSLog(@"THE OBJECT INFO: %@", objectInfo);
  if ([[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] && 
      ! [[objectInfo objectForKey: @"isDistantWeapon"] isEqualTo: @YES] && 
      ! [[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES] &&
      ! [[objectInfo objectForKey: @"isShield"] isEqualTo: @YES])
    {
      NSLog(@"a normal hand weapon");
      self = [[DSAObjectWeaponHandWeapon alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: arc4random_uniform([[objectInfo valueForKey: @"Icon"] count])]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                       withLength: [[objectInfo objectForKey: @"Länge"] floatValue]
                                    withHitPoints: [objectInfo objectForKey: @"Trefferpunkte"]  // Array of NSNumbers 
                                  withHitPointsKK: [[objectInfo objectForKey: @"TrefferpunkteKK"] integerValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]
                                  withAttackPower: [[objectInfo objectForKey: @"attackPower"] integerValue]
                                   withParryValue: [[objectInfo objectForKey: @"parryValue"] integerValue]
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                withAppliedSpells: appliedSpells
                                    withOwnerUUID: ownerUUID
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];      
    }
  else if (! [[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] && 
           [[objectInfo objectForKey: @"isDistantWeapon"] isEqualTo: @YES] && 
           ! [[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES] &&
           ! [[objectInfo objectForKey: @"isShield"] isEqualTo: @YES])
    {
      NSLog(@"a normal distant weapon");
      self = [[DSAObjectWeaponLongRange alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                  withMaxDistance: [[objectInfo objectForKey: @"Reichweite"] integerValue]
                              withDistancePenalty: [objectInfo objectForKey: @"TP Entfernung"]                                        
                           withHitPointsLongRange: [objectInfo objectForKey: @"Trefferpunkte Fernwaffe"]  // Array of NSNumbers
                                   withAmmunition: [objectInfo objectForKey: @"Munition"]
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                withAppliedSpells: appliedSpells
                                    withOwnerUUID: ownerUUID                               
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];      
    }
  else if ([[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] && 
           [[objectInfo objectForKey: @"isDistantWeapon"] isEqualTo: @YES] && 
           ! [[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES] &&
           ! [[objectInfo objectForKey: @"isShield"] isEqualTo: @YES])
    {
      NSLog(@"a hand weapon but also a distant weapon");
      self = [[DSAObjectWeaponHandAndLongRangeWeapon alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                       withLength: [[objectInfo objectForKey: @"Länge"] floatValue]
                                    withHitPoints: [objectInfo objectForKey: @"Trefferpunkte"]  // Array of NSNumbers 
                                  withHitPointsKK: [[objectInfo objectForKey: @"TrefferpunkteKK"] integerValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]
                                  withAttackPower: [[objectInfo objectForKey: @"attackPower"] integerValue]
                                   withParryValue: [[objectInfo objectForKey: @"parryValue"] integerValue]
                                  withMaxDistance: [[objectInfo objectForKey: @"Reichweite"] integerValue]
                              withDistancePenalty: [objectInfo objectForKey: @"TP Entfernung"]                                        
                           withHitPointsLongRange: [objectInfo objectForKey: @"Trefferpunkte Fernwaffe"]  // Array of NSNumbers                                   
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                withAppliedSpells: appliedSpells
                                    withOwnerUUID: ownerUUID                        
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];           
    }
  else if ([[objectInfo objectForKey: @"isShield"] isEqualTo: @YES] && 
           [[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] )
    {
      NSLog(@"a shield and a parry weapon");
      self = [[DSAObjectShieldAndParry alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                       withLength: [[objectInfo objectForKey: @"Länge"] floatValue]
                                      withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]
                            withShieldAttackPower: [[objectInfo objectForKey: @"shieldAttackPower"] integerValue]
                             withShieldParryValue: [[objectInfo objectForKey: @"shieldParryValue"] integerValue]
                                    withHitPoints: [objectInfo objectForKey: @"Trefferpunkte"]  // Array of NSNumbers 
                                  withHitPointsKK: [[objectInfo objectForKey: @"TrefferpunkteKK"] integerValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]
                                  withAttackPower: [[objectInfo objectForKey: @"attackPower"] integerValue]
                                   withParryValue: [[objectInfo objectForKey: @"parryValue"] integerValue]                                                        
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                withAppliedSpells: appliedSpells
                                    withOwnerUUID: ownerUUID                            
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];                
    }
  else if ([[objectInfo objectForKey: @"isShield"] isEqualTo: @YES] && 
           ! [[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] )
    {
      NSLog(@"a shield and a parry weapon");
      self = [[DSAObjectShield alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]                                        
                                      withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]
                            withShieldAttackPower: [[objectInfo objectForKey: @"shieldAttackPower"] integerValue]
                             withShieldParryValue: [[objectInfo objectForKey: @"shieldParryValue"] integerValue]
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                withAppliedSpells: appliedSpells
                                    withOwnerUUID: ownerUUID                          
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];                                                   
    }             
  else if ([[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES])
    {
    NSLog(@"HERE IN isArmor");
      self = [[DSAObjectArmor alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                   withProtection: [[objectInfo objectForKey: @"Rüstschutz"] floatValue]
                                      withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                withAppliedSpells: appliedSpells
                                    withOwnerUUID: ownerUUID                            
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];
    }
    
  else if ([[objectInfo objectForKey: @"isContainer"] isEqualTo: @YES])
    {
      self = [[DSAObjectContainer alloc] initWithName: name
                                             withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                           inCategory: [objectInfo objectForKey: @"category"]
                                        inSubCategory: [objectInfo objectForKey: @"category1"]
                                     inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                           withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                            withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                          withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]  
                                           ofSlotType: [objectInfo objectForKey: @"HatSlots" ] ? [Utils slotTypeFromString: [[objectInfo objectForKey: @"HatSlots" ] objectAtIndex: 0]] : DSASlotTypeGeneral
                                        withNrOfSlots: [objectInfo objectForKey: @"Slots" ] ? [[objectInfo objectForKey: @"Slots" ] integerValue] : 1
                                      maxItemsPerSlot: [objectInfo objectForKey: @"MaximumPerSlot" ] ? [[objectInfo objectForKey: @"MaximumPerSlot" ] integerValue] : 1
                              validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                    occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                    withAppliedSpells: appliedSpells
                                        withOwnerUUID: ownerUUID                               
                                          withRegions: [objectInfo objectForKey: @"Regionen"]];                                          
                                            
    }
  else if ([[objectInfo objectForKey: @"isFood"] isEqualTo: @YES])
    {
      self = [[DSAObjectFood alloc] initWithName: name
                                        withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                      inCategory: [objectInfo objectForKey: @"category"]
                                   inSubCategory: [objectInfo objectForKey: @"category1"]
                                inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                      withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                       withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                    isConsumable: [objectInfo objectForKey: @"direkt konsumierbar" ] ? YES : NO
                                 becomeWhenEmpty: [objectInfo objectForKey: @"Objekt wenn leer" ]
                                       isAlcohol: [objectInfo objectForKey: @"Wirkung" ] ? YES : NO
                                    alcoholLevel: [[objectInfo objectForKey: @"Wirkung"] integerValue]
                                  nutritionValue: [[objectInfo objectForKey: @"DurstodHungerlinderung"] floatValue]
                         validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                    canShareSlot: [[objectInfo objectForKey: @"canShareSlot"] boolValue]];
    }
  else if ([[objectInfo objectForKey: @"isCloth"] isEqualTo: @YES])
    {
       self = [[DSAObjectCloth alloc] initWithName: name
                                          withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                        inCategory: [objectInfo objectForKey: @"category"]
                                     inSubCategory: [objectInfo objectForKey: @"category1"]
                                  inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                        withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                         withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                       withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]
                                    withProtection: [[objectInfo objectForKey: @"Rüstschutz"] floatValue]    
                                        isTailored: [objectInfo objectForKey: @"ist maßgeschneidert" ] ? YES : NO
                           validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                 occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                 withAppliedSpells: appliedSpells
                                     withOwnerUUID: ownerUUID
                                       withRegions: [objectInfo objectForKey: @"Regionen"]];
    }
  else
    {
      NSLog(@"Unsure how to handle object creation for: %@, just going with DSAObject", name);
      self = [[DSAObject alloc] initWithName: name
                                    withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                  inCategory: [objectInfo objectForKey: @"category"]
                               inSubCategory: [objectInfo objectForKey: @"category1"]
                            inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                  withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                   withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                 withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]    
                     validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                           occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]                     
                                canShareSlot: [[objectInfo objectForKey: @"canShareSlot"] boolValue]
                                     useWith: [objectInfo objectForKey: @"benutzen mit"]
                                 useWithText: [objectInfo objectForKey: @"benutzen Text" ]
                           withAppliedSpells: appliedSpells
                               withOwnerUUID: ownerUUID                      
                                 withRegions: [objectInfo objectForKey: @"Regionen"]];     
    }
/* don't really need this, right?
  if ([appliedSpells count] > 0) // can only do this here at the end
    {
      for (DSASpell *appliedSpell in [appliedSpells allValues])
        {
          [appliedSpell applyEffectOnTarget: self];
        }
    }
*/   
  return self;
}

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                  withPenalty: (float) penalty
      validInventorySlotTypes: (NSArray *) validSlotTypes
            occupiedBodySlots: (NSArray *) occupiedBodySlots
                 canShareSlot: (BOOL) canShareSlot
                      useWith: (NSArray *) useWith
                  useWithText: (NSString *) useWithText
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.penalty = penalty;
      self.breakFactor = 0;
      self.canShareSlot = canShareSlot;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID;
      self.regions = regions;
      self.useWith = useWith;
      self.useWithText = useWithText;
      self.states = [[NSMutableSet alloc] init];
    }  
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.name = [coder decodeObjectForKey:@"name"];
      self.icon = [coder decodeObjectForKey:@"icon"];
      self.category = [coder decodeObjectForKey:@"category"];
      self.subCategory = [coder decodeObjectForKey:@"subCategory"];
      self.subSubCategory = [coder decodeObjectForKey:@"subSubCategory"];
      self.weight = [[coder decodeObjectForKey:@"weight"] floatValue];
      self.price = [[coder decodeObjectForKey:@"price"] floatValue];
      self.penalty = [[coder decodeObjectForKey:@"penalty"] floatValue];
      self.protection = [[coder decodeObjectForKey:@"protection"] floatValue];
      self.breakFactor = [coder decodeIntegerForKey:@"breakFactor"];
      self.appliedSpells = [coder decodeObjectForKey:@"appliedSpells"];
      self.ownerUUID = [coder decodeObjectForKey:@"ownerUUID"];  
      self.regions = [coder decodeObjectForKey:@"regions"];
      self.canShareSlot = [coder decodeBoolForKey:@"canShareSlot"];
      self.validSlotTypes = [coder decodeObjectForKey:@"validSlotTypes"];
      self.occupiedBodySlots = [coder decodeObjectForKey:@"occupiedBodySlots"];
      self.useWith = [coder decodeObjectForKey:@"useWith"];
      self.useWithText = [coder decodeObjectForKey:@"useWithText"];
      self.states = [coder decodeObjectForKey:@"states"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.icon forKey:@"icon"];
  [coder encodeObject:self.category forKey:@"category"];
  [coder encodeObject:self.subCategory forKey:@"subCategory"];
  [coder encodeObject:self.subSubCategory forKey:@"subSubCategory"];
  [coder encodeObject:@(self.weight) forKey:@"weight"];
  [coder encodeObject:@(self.price) forKey:@"price"];
  [coder encodeObject:@(self.penalty) forKey:@"penalty"];
  [coder encodeObject:@(self.protection) forKey:@"protection"];    // armor value
  [coder encodeInteger:self.breakFactor forKey:@"breakFactor"];
  [coder encodeObject:self.appliedSpells forKey:@"appliedSpells"];
  [coder encodeObject:self.ownerUUID forKey:@"ownerUUID"];
  [coder encodeObject:self.regions forKey:@"regions"];
  [coder encodeBool:self.canShareSlot forKey:@"canShareSlot"];
  [coder encodeObject:self.validSlotTypes forKey:@"validSlotTypes"];
  [coder encodeObject:self.occupiedBodySlots forKey:@"occupiedBodySlots"];
  [coder encodeObject:self.useWith forKey:@"useWith"];
  [coder encodeObject:self.useWithText forKey:@"useWithText"];
  [coder encodeObject:self.states forKey:@"states"];
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
  DSAObject *copy = [[[self class] allocWithZone:zone] init];

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


// used to determine, if the object can share an inventory slot
// or if we can carry the other object
- (BOOL)isCompatibleWithObject:(DSAObject *)otherObject
{
  // Check if we are a container, and may be able to carry the other Object
  if ([self isKindOfClass: [DSAObjectContainer class]])
    {
    
      DSAObjectContainer *container = (DSAObjectContainer *)self;
      BOOL foundSlot = NO;
      for (DSASlot *slot in container.slots)
        {
          if (slot.object == nil)
            {
              NSLog(@"DSAObject: %@ found empty slot", self.name);
              if ([otherObject.validSlotTypes containsObject: @(slot.slotType)])
                {
                  NSLog(@"DSAObject: %@ has slots of type: %@ other object %@ can be put into slot types: %@", self.name, @(slot.slotType),  otherObject.name, otherObject.validSlotTypes);
                  foundSlot = YES;
                  break;
                }
            }
          else if ([slot.object isCompatibleWithObject: otherObject])
            {
              foundSlot = YES;
              break;
            }
        }
      return foundSlot;
    }

    
  if (![self.name isEqualToString:otherObject.name])
    {
      return NO; // Different types of objects
    }
  if (!self.canShareSlot || !otherObject.canShareSlot)
    {
      NSLog(@"DSAObject %@ can't share slot with %@", self.name, otherObject);
      return NO; // Slot-sharing not allowed
    }
  // XXX TODO below tests may be bogus, and not sufficient
  if (self.appliedSpells != otherObject.appliedSpells || 
      ![self.ownerUUID isEqual: otherObject.ownerUUID] ||
      [self.states containsObject: @(DSAObjectStateIsPoisoned)] != [otherObject.states containsObject: @(DSAObjectStateIsPoisoned)])
    {
      return NO; // Mismatched properties
    }
  return YES;
}

@end

// Subclasses follow below
@implementation DSAObjectContainer
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                  withPenalty: (float) penalty  
                   ofSlotType: (NSInteger) slotType
                withNrOfSlots: (NSInteger) nrOfSlots
              maxItemsPerSlot: (NSInteger) maxItemsPerSlot
      validInventorySlotTypes: (NSArray *) validSlotTypes
            occupiedBodySlots: (NSArray *) occupiedBodySlots
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID            
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.penalty = penalty;
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID;
      self.regions = regions;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;
      self.slots = [NSMutableArray arrayWithCapacity:nrOfSlots];
      for (NSInteger i = 0; i < nrOfSlots; i++)
        {
          DSASlot *slot = [[DSASlot alloc] init];
          slot.slotType = slotType;  // Set the same slot type for all slots
          slot.maxItemsPerSlot = maxItemsPerSlot;
          [self.slots addObject:slot];
        }
    }  
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.slots = [coder decodeObjectForKey:@"slots"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.slots forKey:@"slots"];
}
@end
// end of DSAObjectContainer

@implementation DSAObjectWeapon
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.hitPoints = [coder decodeObjectForKey:@"hitPoints"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.hitPoints forKey:@"hitPoints"];
}
@end
// end of DSAObjectWeapon

@implementation DSAObjectWeaponHandWeapon
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                   withLength: (float) length
                withHitPoints: (NSArray *) hitPoints
              withHitPointsKK: (NSInteger) hitPointsKK
              withBreakFactor: (NSInteger) breakFactor              
              withAttackPower: (NSInteger) attackPower
               withParryValue: (NSInteger) parryValue
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots     
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID                       
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.length = length;
      self.hitPoints = hitPoints;
      self.hitPointsKK = hitPointsKK;
      self.breakFactor = breakFactor;
      self.attackPower = attackPower;
      self.parryValue = parryValue;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;     
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID; 
      self.regions = regions;
      self.states = [[NSMutableSet alloc] init];
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.length = [[coder decodeObjectForKey:@"length"] floatValue];
        self.hitPointsKK = [coder decodeIntegerForKey:@"hitPointsKK"];
        self.attackPower = [coder decodeIntegerForKey:@"attackPower"];
        self.parryValue = [coder decodeIntegerForKey:@"parryValue"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:@(self.length) forKey:@"length"];
  [coder encodeInteger:self.hitPointsKK forKey:@"hitPointsKK"];
  [coder encodeInteger:self.attackPower forKey:@"attackPower"];
  [coder encodeInteger:self.parryValue forKey:@"parryValue"];
}
@end
// End of DSAObjectWeaponHandWeapon

@implementation DSAObjectWeaponHandAndLongRangeWeapon
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                   withLength: (float) length
                withHitPoints: (NSArray *) hitPoints
              withHitPointsKK: (NSInteger) hitPointsKK
              withBreakFactor: (NSInteger) breakFactor              
              withAttackPower: (NSInteger) attackPower
               withParryValue: (NSInteger) parryValue
              withMaxDistance: (NSInteger) maxDistance
          withDistancePenalty: (NSDictionary *) distancePenalty
       withHitPointsLongRange: (NSArray *) hitPointsLongRange               
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots       
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID                     
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.length = length;
      self.hitPoints = hitPoints;
      self.hitPointsKK = hitPointsKK;
      self.breakFactor = breakFactor;
      self.attackPower = attackPower;
      self.parryValue = parryValue;
      self.maxDistance = maxDistance;
      self.distancePenalty = distancePenalty;      
      self.hitPointsLongRange = hitPointsLongRange;      
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;     
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID; 
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.maxDistance = [coder decodeIntegerForKey:@"maxDistance"];
        self.distancePenalty = [coder decodeObjectForKey:@"distancePenalty"];
        self.hitPointsLongRange = [coder decodeObjectForKey:@"hitPointsLongRange"];        
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeInteger:self.maxDistance forKey:@"maxDistance"];
  [coder encodeObject:self.distancePenalty forKey:@"distancePenalty"];
  [coder encodeObject:self.hitPointsLongRange forKey:@"hitPointsLongRange"];
}
@end
// End of DSAObjectWeaponHandAndLongRangeWeapon

@implementation DSAObjectWeaponLongRange
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
              withMaxDistance: (NSInteger) maxDistance
          withDistancePenalty: (NSDictionary *) distancePenalty
       withHitPointsLongRange: (NSArray *) hitPointsLongRange
               withAmmunition: (NSArray *) ammunition
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots   
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID                         
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.maxDistance = maxDistance;
      self.distancePenalty = distancePenalty;      
      self.hitPointsLongRange = hitPointsLongRange;
      self.ammunition = ammunition;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;     
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID; 
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.maxDistance = [coder decodeIntegerForKey:@"maxDistance"];
        self.distancePenalty = [coder decodeObjectForKey:@"distancePenalty"];
        self.hitPointsLongRange = [coder decodeObjectForKey:@"hitPointsLongRange"];
        self.ammunition = [coder decodeObjectForKey:@"ammunition"];      
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeInteger:self.maxDistance forKey:@"maxDistance"];
  [coder encodeObject:self.distancePenalty forKey:@"distancePenalty"];
  [coder encodeObject:self.hitPointsLongRange forKey:@"hitPointsLongRange"];
  [coder encodeObject:self.ammunition forKey:@"ammunition"];
}
@end
// End of DSAObjectWeaponLongRange

@implementation DSAObjectShield
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
              withBreakFactor: (NSInteger) breakFactor
                  withPenalty: (float) penalty
        withShieldAttackPower: (NSInteger) shieldAttackPower
         withShieldParryValue: (NSInteger) shieldParryValue
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots            
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID                
                  withRegions: (NSArray *) regions;
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.breakFactor = breakFactor;
      self.penalty = penalty;
      self.shieldAttackPower = shieldAttackPower;
      self.shieldParryValue = shieldParryValue;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;   
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID;   
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.shieldAttackPower = [coder decodeIntegerForKey:@"shieldAttackPower"];
        self.shieldParryValue = [coder decodeIntegerForKey:@"shieldParryValue"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeInteger:self.shieldAttackPower forKey:@"shieldAttackPower"];
  [coder encodeInteger:self.shieldParryValue forKey:@"shieldParryValue"];
}
@end
// End of DSAObjectShield

@implementation DSAObjectShieldAndParry
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                   withLength: (float) length
                  withPenalty: (float) penalty
        withShieldAttackPower: (NSInteger) shieldAttackPower
         withShieldParryValue: (NSInteger) shieldParryValue
                withHitPoints: (NSArray *) hitPoints
              withHitPointsKK: (NSInteger) hitPointsKK
              withBreakFactor: (NSInteger) breakFactor              
              withAttackPower: (NSInteger) attackPower
               withParryValue: (NSInteger) parryValue
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots       
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID                     
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.length = length;
      self.breakFactor = breakFactor;
      self.penalty = penalty;
      self.hitPoints = hitPoints;
      self.hitPointsKK = hitPointsKK;
      self.attackPower = attackPower;
      self.parryValue = parryValue;    
      self.shieldAttackPower = shieldAttackPower;
      self.shieldParryValue = shieldParryValue;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;     
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID; 
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.length = [[coder decodeObjectForKey:@"length"] floatValue];
        self.hitPoints = [coder decodeObjectForKey:@"hitPoints"];
        self.hitPointsKK = [coder decodeIntegerForKey:@"hitPointsKK"];
        self.attackPower = [coder decodeIntegerForKey:@"attackPower"];
        self.parryValue = [coder decodeIntegerForKey:@"parryValue"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:@(self.length) forKey:@"length"];
  [coder encodeObject:self.hitPoints forKey:@"hitPoints"];
  [coder encodeInteger:self.hitPointsKK forKey:@"hitPointsKK"];  
  [coder encodeInteger:self.attackPower forKey:@"attackPower"];
  [coder encodeInteger:self.parryValue forKey:@"parryValue"];
}                  
@end
// End of DSAObjectShieldAndParry

@implementation DSAObjectArmor
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
               withProtection: (float) protection  // armor
                  withPenalty: (float) penalty
      validInventorySlotTypes: (NSArray *) validSlotTypes
            occupiedBodySlots: (NSArray *) occupiedBodySlots
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID            
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.protection = protection;  // armor
      self.penalty = penalty;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID;   
      self.regions = regions;
    }  
  return self;
}                  
@end
// End of DSAObjectArmor

@implementation DSAObjectCloth
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                  withPenalty: (float) penalty
               withProtection: (float) protection  // armor  
                   isTailored: (BOOL) isTailored
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots       
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID                     
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.penalty = penalty;
      self.isTailored = isTailored;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;     
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID; 
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.isTailored = [coder decodeBoolForKey:@"isTailored"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeBool:self.isTailored forKey:@"isTailored"];
}

- (float) penalty
{
  if (self.isTailored)
    {
      return [super penalty] * 0.75;
    }
  else
    {
      return [super penalty];
    }
}
                
@end

@implementation DSAObjectFood
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                 isConsumable: (BOOL) isConsumable
              becomeWhenEmpty: (NSString *) newItemName
                    isAlcohol: (BOOL) isAlcohol
                 alcoholLevel: (NSInteger) alcoholLevel
               nutritionValue: (float) nutritionValue
      validInventorySlotTypes: (NSArray *) validSlotTypes
                 canShareSlot: (BOOL) canShareSlot
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.isConsumable = isConsumable;
      self.becomeWhenEmpty = (NSString *) newItemName;
      self.isAlcohol = isAlcohol;
      self.alcoholLevel = alcoholLevel;
      self.nutritionValue = nutritionValue;
      self.validSlotTypes = validSlotTypes;
      self.canShareSlot = canShareSlot;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.isConsumable = [coder decodeBoolForKey:@"isConsumable"];
        self.isAlcohol = [coder decodeBoolForKey:@"isAlcohol"];
        self.becomeWhenEmpty = [coder decodeObjectForKey:@"becomeWhenEmpty"];
        self.alcoholLevel = [coder decodeIntegerForKey:@"alcoholLevel"];
        self.nutritionValue = [[coder decodeObjectForKey:@"nutritionValue"] floatValue];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeBool:self.isConsumable forKey:@"isConsumable"];
  [coder encodeBool:self.isAlcohol forKey:@"isAlcohol"];
  [coder encodeObject:self.becomeWhenEmpty forKey:@"becomeWhenEmpty"];
  [coder encodeInteger:self.alcoholLevel forKey:@"alcoholLevel"];
  [coder encodeObject:@(self.nutritionValue) forKey:@"nutritionValue"];
}             
@end
// End of DSAObjectCloth
