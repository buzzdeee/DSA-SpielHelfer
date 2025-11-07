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

#import "DSAObject.h"

#import "Utils.h"
#import "DSASlot.h"
#import "DSASpellMageRitual.h"
#import "DSAConsumption.h"
#import "DSAPoison.h"
#import "DSAPlant.h"
#import "DSADefinitions.h"
#import "DSAInventoryManager.h"


@implementation DSAObjectEffect

#pragma mark - Initializer

- (instancetype)initWithEffectType:(DSAObjectEffectType)effectType {
    self = [super init];
    if (self) {
        _effectType = effectType;
        _uniqueKey = [[NSUUID UUID] UUIDString]; // automatischer eindeutiger Schlüssel
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _uniqueKey = [coder decodeObjectOfClass:[NSString class] forKey:@"uniqueKey"];
        _effectType = [coder decodeIntegerForKey:@"effectType"];
        _expirationDate = [coder decodeObjectOfClass:[DSAAventurianDate class] forKey:@"expirationDate"];
        _appliedSpell = [coder decodeObjectOfClass:[DSASpell class] forKey:@"appliedSpell"];
        _appliedPoison = [coder decodeObjectOfClass:[DSAPoison class] forKey:@"appliedPoison"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uniqueKey forKey:@"uniqueKey"];
    [coder encodeInteger:self.effectType forKey:@"effectType"];
    [coder encodeObject:self.expirationDate forKey:@"expirationDate"];
    [coder encodeObject:self.appliedSpell forKey:@"appliedSpell"];
    [coder encodeObject:self.appliedPoison forKey:@"appliedPoison"];
}

/// Falls du Secure Coding nutzen willst:
+ (BOOL)supportsSecureCoding {
    return YES;
}
@end

@implementation DSAObject

- (instancetype) initWithName: (NSString *) name forOwner: (NSUUID *) ownerUUID
{
  NSLog(@"DSAObject initWithName: before calling self = [super init] for name: %@", name);
  self = [super init];
  NSLog(@"DSAObject initWithName: before calling Utils getDSAObjectInfoByName: %@", name);
  NSDictionary *objectInfo = [[DSAObjectManager sharedManager] getDSAObjectInfoByName: name];
  NSLog(@"DSAObject initWithName: name: %@, objectInfo: %@", name, objectInfo);
  return [self initWithObjectInfo: objectInfo forOwner: ownerUUID];
  
}

- (instancetype) initWithObjectInfo: (NSDictionary *) objectInfo forOwner: (NSUUID *) ownerUUID
{
  self = [super init];
  
  NSString *name = [objectInfo objectForKey: @"Name"];
  NSMutableDictionary *appliedSpells = [NSMutableDictionary new];
  
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
                  [appliedSpells setObject: appliedSpell
                                    forKey: spellName];
                }
          }
    }
  //NSLog(@"DSAObject initWithObjectInfo: APPLIED SPELL: %@ to OBJECT: %@", [appliedSpells allKeys], name);
  // first ensure that we ownly set the owner on items that are definite personal items
  // other items may set ownerUUID in a second step  
  if (![[objectInfo objectForKey: @"persönliches Objekt"] isEqualTo: @YES])
    {
      ownerUUID = nil;
    }
  
  if ([[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] && 
      ! [[objectInfo objectForKey: @"isDistantWeapon"] isEqualTo: @YES] && 
      ! [[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES] &&
      ! [[objectInfo objectForKey: @"isShield"] isEqualTo: @YES])
    {
      NSLog(@"a normal hand weapon");
      self = [[DSAObjectWeaponHandWeapon alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: arc4random_uniform([[objectInfo valueForKey: @"Icon"] count])]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                 inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
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
                                    inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                 inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
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
                                    inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                 inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
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
                                    inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                 inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
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
      NSLog(@"a shield but not a parry weapon");
      self = [[DSAObjectShield alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                 inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
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
                                    inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                 inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
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
                                        inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                     inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
                                           withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                            withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                          withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]  
                                           ofSlotType: [objectInfo objectForKey: @"HatSlots" ] ? [[DSAObjectManager sharedManager] slotTypeFromString: [[objectInfo objectForKey: @"HatSlots" ] objectAtIndex: 0]] : DSASlotTypeGeneral
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
                                   inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
                                      withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                       withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                         validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                    canShareSlot: [[objectInfo objectForKey: @"canShareSlot"] boolValue]];
    }
  else if ([[objectInfo objectForKey: @"isCloth"] isEqualTo: @YES])
    {
       self = [[DSAObjectCloth alloc] initWithName: name
                                          withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                        inCategory: [objectInfo objectForKey: @"category"]
                                     inSubCategory: [objectInfo objectForKey: @"subCategory"]
                                  inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
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
  else if ([[objectInfo objectForKey: @"category"] isEqualTo: @"Gift"])
    {
      self = [[DSAPoisonRegistry sharedRegistry] poisonWithName: objectInfo[@"Name"]];
    }
  else if ([[objectInfo objectForKey: @"category"] isEqualTo: @"Pflanzen"])
    {
      self = [[DSAPlantRegistry sharedRegistry] plantWithName: objectInfo[@"Name"]];
    }    
  else
    {
      NSLog(@"Unsure how to handle object creation for: %@, just going with DSAObject, using objectInfo: %@", name, objectInfo);
      self = [[DSAObject alloc] initWithName: name
                                    withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                  inCategory: [objectInfo objectForKey: @"category"]
                               inSubCategory: [objectInfo objectForKey: @"subCategory"]
                            inSubSubCategory: [objectInfo objectForKey: @"subSubCategory"]
                                  withWeight: [[objectInfo objectForKey: @"Gewicht"] floatValue]
                                   withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                 withPenalty: [[objectInfo objectForKey: @"Behinderung"] floatValue]    
                     validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                           occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]                     
                                canShareSlot: [[objectInfo objectForKey: @"canShareSlot"] boolValue]
                           withAppliedSpells: appliedSpells
                               withOwnerUUID: ownerUUID                      
                                 withRegions: [objectInfo objectForKey: @"Regionen"]];
    }

    if (!self.states)
      {
        self.states = [NSMutableSet new];
      }
    NSDictionary *useWithInfo = objectInfo[@"useWith"];
    if (useWithInfo) {
        NSMutableDictionary *mapped = [NSMutableDictionary dictionary];

        [useWithInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (![key isKindOfClass:[NSString class]] || ![obj isKindOfClass:[NSDictionary class]]) {
                return;
            }
            NSString *useWithKey = (NSString *)key;
            NSDictionary *value = (NSDictionary *)obj;

            NSString *useWithText = value[@"useWithText"];
            NSString *actionString = value[@"action"];

            DSAUseObjectWithActionType actionType = DSAUseObjectWithActionTypeFromString(actionString);

            // Sicherstellen, dass ein gültiger Enum-Wert zurückkam
            if (actionType == -1) {
                 NSLog(@"DSAObject initWithObjectInfo Error: unknown action '%@' in JSON for useWith-Key '%@'", actionString, useWithKey);
                 abort(); // sofortiges Beenden
            }            
            
            mapped[useWithKey] = @{
                @"useWithText": useWithText ?: @"",
                @"action": @(actionType)
            };
        }];

        self.useWith = [mapped copy];
    }                                         
    
  //NSLog(@"DSAObject initWithObjectInfo before setting up self.consumptions ");      
  self.consumptions = [NSMutableDictionary dictionary];
  //NSLog(@"DSAObject initWithObjectInfo after setting up self.consumptions ");
  if ([objectInfo objectForKey: @"MaxUsageCount"] && [[objectInfo objectForKey: @"MaxUsageCount"] integerValue] > 0)
    {
      NSLog(@"DSAObject initWithObjectInfo in MaxUsageCount");
      NSInteger maxUsageCount = [[objectInfo objectForKey: @"MaxUsageCount"] integerValue];
      DSAConsumption *consumption;
      if (maxUsageCount == 1)
        {
          consumption = [[DSAConsumption alloc] initWithType:DSAConsumptionTypeUseOnce];
        }
      else if (maxUsageCount > 1)
        {
          consumption = [[DSAConsumption alloc] initWithType:DSAConsumptionTypeUseMany];
        }
      consumption.maxUses = maxUsageCount; 
      consumption.remainingUses = maxUsageCount;
      if ([objectInfo objectForKey: @"disappearWhenEmpty"] && [[objectInfo objectForKey: @"disappearWhenEmpty"] boolValue] == YES)
        {
          NSLog(@"DSAObject initWithObjectInfo in MaxUsageCount disappearWhenEmpty");
          consumption.disappearWhenEmpty = YES;
        }
      if ([objectInfo objectForKey: @"transitionWhenEmpty"])
        {
          NSLog(@"DSAObject initWithObjectInfo in MaxUsageCount transitionWhenEmpty");
          consumption.transitionWhenEmpty = [objectInfo objectForKey: @"transitionWhenEmpty"];
        }
      if ([objectInfo objectForKey: @"DurstodHungerlinderung"])
        {
          NSLog(@"DSAObject initWithObjectInfo in MaxUsageCount DurstodHungerlinderung");
          consumption.nutritionValue = [[objectInfo objectForKey: @"DurstodHungerlinderung"] floatValue];
        }
      if ([objectInfo objectForKey: @"AlkoholischeWirkung"])
        {
          NSLog(@"DSAObject initWithObjectInfo in MaxUsageCount AlkoholischeWirkung");
          consumption.alcoholLevel = [[objectInfo objectForKey: @"AlkoholischeWirkung"] integerValue];
          [self.states addObject: @(DSAObjectStateIsAlcoholic)];
        }        
      NSLog(@"DSAObject initWithObjectInfo: self.name: %@, self.category: %@, self.subCategory: %@, self.subSubCategory: %@", self.name, self.category, self.subCategory, self.subSubCategory);
      if ([self.subCategory isEqualToString: _(@"Getränke")])
        {
          NSLog(@"DSAObject initWithObjectInfo in MaxUsageCount Getränke objectInfo: %@", objectInfo);
          if ([objectInfo objectForKey: @"direkt konsumierbar"])
            {
              [self.states addObject: @(DSAObjectStateIsConsumable)];
              NSLog(@"DSAObject initWithObjectInfo DID ADD STATE: DSAObjectStateIsConsumable %@", self.states);
              consumption.isDrinkable = YES;
            }
        }
      else if ([self.subCategory isEqualToString: _(@"Essen")])
        {
          NSLog(@"DSAObject initWithObjectInfo in MaxUsageCount Essen");
          if ([objectInfo objectForKey: @"direkt konsumierbar"])
            {
              [self.states addObject: @(DSAObjectStateIsConsumable)];   
              NSLog(@"DSAObject initWithObjectInfo DID ADD STATE: DSAObjectStateIsConsumable: %@", self.states);         
              consumption.isEatable = YES;
            }
        }
      else
        {
           [self.states addObject: @(DSAObjectStateIsDepletable)];
        }  
      [self.consumptions setObject: consumption forKey: @"maxUsageCount"];
    }
  //NSLog(@"DSAObject initWithObjectInfo before consumptions shelfLifeDays");
  NSInteger shelfLifeInt = [self calculateShelfLifeDaysForObjectDict: objectInfo];
  if (shelfLifeInt > NSIntegerMin)
    {
      DSAConsumption *consumption = [[DSAConsumption alloc] initWithType:DSAConsumptionTypeExpiry];
      consumption.shelfLifeDays = shelfLifeInt;
      [self.states addObject: @(DSAObjectStateHasShelfLife)];
      [self.consumptions setObject: consumption forKey: @"shelfLifeDays"];
    }  
  //NSLog(@"DSAObject initWithObjectInfo after consumptions shelfLifeDays");           
  return self;
}


// returns NSIntegerMin in case of no shelfLifeDays
// returns NSIntegerMax in case of good forever
// returns NSInteger in days for how long it is good
- (NSInteger) calculateShelfLifeDaysForObjectDict: (NSDictionary *) dict
{
   NSInteger shelfLife = NSIntegerMin;
   if ([dict objectForKey: @"Haltbarkeit"])
     {
       NSDictionary *shelfLifeDict = [dict objectForKey: @"Haltbarkeit"];
       shelfLife = [[shelfLifeDict objectForKey: @"Tage"] integerValue];
       if (shelfLife == -1)
         {
           return NSIntegerMax;
         }
       NSInteger randomDays = 0;
       if ([shelfLifeDict objectForKey: @"Wuerfel"])
         {
           randomDays = [Utils rollDice: [shelfLifeDict objectForKey: @"Wuerfel"]];
         }
          
       shelfLife += randomDays;
     }
   return shelfLife;
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
      self.breakFactor = @{ @"initial": @(0), @"current": @(0)};
      self.canShareSlot = canShareSlot;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;
      self.appliedSpells = appliedSpells;
      self.ownerUUID = ownerUUID;
      self.regions = regions;
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
      self.breakFactor = [coder decodeObjectForKey:@"breakFactor"];
      self.appliedSpells = [coder decodeObjectForKey:@"appliedSpells"];
      self.ownerUUID = [coder decodeObjectForKey:@"ownerUUID"];  
      self.regions = [coder decodeObjectForKey:@"regions"];
      self.canShareSlot = [coder decodeBoolForKey:@"canShareSlot"];
      self.validSlotTypes = [coder decodeObjectForKey:@"validSlotTypes"];
      self.occupiedBodySlots = [coder decodeObjectForKey:@"occupiedBodySlots"];
      self.useWith = [coder decodeObjectForKey:@"useWith"];
      self.states = [coder decodeObjectForKey:@"states"];
      self.consumptions = [coder decodeObjectForKey:@"consumptions"];
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
  [coder encodeObject:self.breakFactor forKey:@"breakFactor"];
  [coder encodeObject:self.appliedSpells forKey:@"appliedSpells"];
  [coder encodeObject:self.ownerUUID forKey:@"ownerUUID"];
  [coder encodeObject:self.regions forKey:@"regions"];
  [coder encodeBool:self.canShareSlot forKey:@"canShareSlot"];
  [coder encodeObject:self.validSlotTypes forKey:@"validSlotTypes"];
  [coder encodeObject:self.occupiedBodySlots forKey:@"occupiedBodySlots"];
  [coder encodeObject:self.useWith forKey:@"useWith"];
  [coder encodeObject:self.states forKey:@"states"];
  [coder encodeObject:self.consumptions forKey:@"consumptions"];
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
      [self isPoisoned] != [otherObject isPoisoned])
    {
      return NO; // Mismatched properties
    }
  return YES;
}

- (DSAObjectState) isMagic
{
  if ([self.appliedSpells count] > 0)
    {
      if ([self.states containsObject: @(DSAObjectStateIsMagicUnknown)]) return DSAObjectStateIsMagicUnknown;
      if ([self.states containsObject: @(DSAObjectStateIsMagicKnown)]) return DSAObjectStateIsMagicKnown;      
      if ([self.states containsObject: @(DSAObjectStateIsMagicKnownDetails)]) return DSAObjectStateIsMagicKnownDetails;            

      NSLog(@"DSAObject %@ has applied spells, but found DSAObjectStateIsMagicIsNotMagic state set, changing to DSAObjectStateIsMagicUnknown", self.name);
      [self.states removeObject: @(DSAObjectStateIsNotMagic)];
      [self.states addObject: @(DSAObjectStateIsMagicUnknown)];
    }
  return DSAObjectStateIsNotMagic;
}

// Look at DSAObjectState for proper values
-(void)setIsMagic: (DSAObjectState) magicState  
{
  NSInteger spellCount = [self.appliedSpells count];
  if (magicState == DSAObjectStateIsMagicUnknown && spellCount > 0)
    {
      [self.states addObject: @(magicState)];
      [self.states removeObject: @(DSAObjectStateIsMagicKnown)];
      [self.states removeObject: @(DSAObjectStateIsMagicKnownDetails)];      
      [self.states removeObject: @(DSAObjectStateIsNotMagic)];            
    }
  else if (magicState == DSAObjectStateIsMagicKnown  && spellCount > 0)
    {
      [self.states removeObject: @(DSAObjectStateIsMagicUnknown)];
      [self.states addObject: @(magicState)];
      [self.states removeObject: @(DSAObjectStateIsMagicKnownDetails)];
      [self.states removeObject: @(DSAObjectStateIsNotMagic)];            
    }
  else if (magicState == DSAObjectStateIsMagicKnownDetails  && spellCount > 0)
    {
      [self.states removeObject: @(DSAObjectStateIsMagicUnknown)];
      [self.states removeObject: @(DSAObjectStateIsMagicKnown)];       
      [self.states addObject: @(magicState)];
      [self.states removeObject: @(DSAObjectStateIsNotMagic)];          
    }
  else if (magicState == DSAObjectStateIsNotMagic  && spellCount == 0)
    {
      [self.states removeObject: @(DSAObjectStateIsMagicUnknown)];
      [self.states removeObject: @(DSAObjectStateIsMagicKnown)];       
      [self.states removeObject: @(DSAObjectStateIsMagicKnownDetails)];                    
      [self.states addObject: @(magicState)];
      [self.states removeObject: @(DSAObjectStateIsNotMagic)];              
    }
  else
    {
      NSLog(@"DSAObject setIsMagic unhandled condition, trying to set isMagic before dealing with applied spells?");
      abort();
    }
}

- (BOOL) isConsumable
{
  if ([self.states containsObject: @(DSAObjectStateIsConsumable)])
    {
      return YES;
    }
  return NO;
}
- (BOOL) isAlcoholic
{
  if ([self.states containsObject: @(DSAObjectStateIsAlcoholic)])
    {
      return YES;
    }
  return NO;
}
- (BOOL) isDepletable
{
  if ([self.states containsObject: @(DSAObjectStateIsDepletable)])
    {
      return YES;
    }
  return NO;
}
- (BOOL) isPoisoned
{
  if ([self.states containsObject: @(DSAObjectStateIsPoisoned)])
    {
      return YES;
    }
  return NO;
}
- (BOOL) hasShelfLife
{
  if ([self.states containsObject: @(DSAObjectStateHasShelfLife)])
    {
      return YES;
    }
  return NO;
}

- (void)resetCurrentUsageToMax
{
  DSAConsumption *usageConsumption = [self usageConsumption];
  [usageConsumption resetCurrentUsageToMax];
}

- (BOOL) justDepleted
{
   DSAConsumption *usageConsumption = [self usageConsumption];
   //NSLog(@"DSAObject justDepleted: %@ based off of DSAConsumption: %@", @([usageConsumption justDepleted]), usageConsumption);
   return [usageConsumption justDepleted];

}

- (NSInteger) alcoholLevel
{
  if ([self isAlcoholic])
    {
      DSAConsumption *usageConsumption = [self usageConsumption];
      return usageConsumption.alcoholLevel;
    }
  return -20;  // definitely not alcoholic 
}

- (float) nutritionValue
{
  DSAConsumption *usageConsumption = [self usageConsumption];
  if (usageConsumption)
    {
      return usageConsumption.nutritionValue;
    }
  return 0.0;
}

- (BOOL) disappearWhenEmpty
{
  DSAConsumption *usageConsumption = [self usageConsumption];
  if (usageConsumption)
    {
      return [usageConsumption disappearWhenEmpty];
    }
  return YES;
}
- (NSString *) transitionWhenEmpty
{
  DSAConsumption *usageConsumption = [self usageConsumption];
  if (usageConsumption)
    {
      return [usageConsumption transitionWhenEmpty];
    }
  return nil;
}


// first check if we have an expiration consumption, and check if expired
// if not, or not expired, check maxUsageCount.
- (BOOL)useOnceWithDate:(DSAAventurianDate *)currentDate
                 reason:(DSAConsumptionFailReason *)reason
{
  if (reason) *reason = DSAConsumptionFailReasonNone;
  if ([self hasExpiryConsumption])
    {
      if ([[self expiryConsumption] isExpiredAtDate: currentDate])
        {
          if (reason) *reason = DSAConsumptionFailReasonExpired;
          return NO;
        }
    }
  DSAConsumption *maxUsageConsumption = [self.consumptions objectForKey: @"maxUsageCount"];
  if (maxUsageConsumption)
    {
      return [maxUsageConsumption useOnceWithDate: currentDate
                                           reason: reason];
    }
  return YES;
}

- (DSAConsumption *)expiryConsumption {
    for (DSAConsumption *consumption in self.consumptions.allValues) {
        if (consumption.type == DSAConsumptionTypeExpiry) {
            return consumption;
        }
    }
    return nil;
}

- (DSAConsumption *)usageConsumption {
    return [self.consumptions objectForKey: @"maxUsageCount"];
}

- (BOOL)hasExpiryConsumption {
    return ([self expiryConsumption] != nil);
}

- (BOOL)isExpiredAtDate:(DSAAventurianDate *)currentDate {
    DSAConsumption *expiry = [self expiryConsumption];
    if (!expiry) return NO;
    return [expiry isExpiredAtDate:currentDate];
}

- (void)activateExpiryIfNeededWithDate:(DSAAventurianDate *)date {
    DSAConsumption *expiry = [self expiryConsumption];
    if (expiry && !expiry.manufactureDate) {
        expiry.manufactureDate = [date copy];
    }
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

- (BOOL)isEmpty
{
    for (DSASlot *slot in self.slots) {
        if (slot.object != nil) {
            return NO;
        }
    }
    return YES;
}

- (NSInteger) countAllSlots
{
    return [self.slots count];
}

- (NSInteger) countEmptySlots
{
    NSInteger counter = 0;
    for (DSASlot *slot in self.slots) {
        if (slot.object == nil) {
            counter++;
        }
    }
    return counter;
}

- (DSASlotType) slotType
{
  return self.slots[0].slotType;
}

- (NSInteger) storeItem: (DSAObject *) item ofQuantity: (NSInteger) quantity
{
  NSInteger itemsToAdd = quantity;
  NSInteger itemsAdded = 0;
  DSAInventoryManager *inventoryManager = [DSAInventoryManager sharedManager];
  for (DSASlot *slot in self.slots)
    {
      if ([inventoryManager isItem: item compatibleWithSlot: slot])
        {
           itemsAdded += [slot addObject: [item copy] quantity: itemsToAdd];
           if (itemsAdded == quantity)
             {
               return quantity;
             }
           else
             {
               itemsToAdd = quantity - itemsAdded;
             }
        }
    }
  return itemsAdded;
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
      self.breakFactor = @{ @"initial": @(breakFactor), @"current": @(breakFactor)};
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
      self.breakFactor = @{ @"initial": @(breakFactor), @"current": @(breakFactor)};
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
      self.breakFactor = @{ @"initial": @(breakFactor), @"current": @(breakFactor)};
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
      self.breakFactor = @{ @"initial": @(breakFactor), @"current": @(breakFactor)};
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
      self.validSlotTypes = validSlotTypes;
      self.canShareSlot = canShareSlot;
    }  
  return self;
}

- (nullable DSADrunkenEffect *)generateDrunkenEffectForCharacter:(DSACharacter *)character
                                                          atDate: (DSAAventurianDate *) currentDate
{
   NSLog(@"DSAObjectFood generateDrunkenEffectForCharacter called");
   DSADrunkenEffect *activeDrunkenEffect = [character activeDrunkenEffect];
   DSADrunkenLevel stateLevel = DSADrunkenLevelNone;
   if (activeDrunkenEffect)
     {
       NSLog(@"DSAObjectFood generateDrunkenEffectForCharacter the character already has a drunken effect!");
       stateLevel = activeDrunkenEffect.drunkenLevel;
     }
   if (stateLevel == DSADrunkenLevelSevere)  // already severely drunken, can't get worse
     {
       NSLog(@"DSAObjectFood generateDrunkenEffectForCharacter the character already is severely drunken!");
       return nil;
     }
   else
     {
       NSLog(@"DSAObjectFood generateDrunkenEffectForCharacter the character is already drunken, but not yet severely, so bumping level!");
       stateLevel++;
     }
   
   DSADrunkenEffect *effect = [[DSADrunkenEffect alloc] init];
   effect.uniqueKey = @"Drunken";
   effect.effectType = DSACharacterEffectTypeDrunken;
   effect.expirationDate = [currentDate dateByAddingYears: 0
                                                     days: 0
                                                    hours: 6
                                                  minutes: 0];
   effect.drunkenLevel = stateLevel;
   
   return effect;
}                         
@end
// End of DSAObjectCloth

@implementation DSAObjectManager
static DSAObjectManager *sharedInstance = nil;
+ (instancetype)sharedManager {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

-(instancetype) init
{
  self = [super init];
  if (self)
    {
      _objectsByName = nil;
      
      NSError *e = nil;
      NSString *filePath;
      filePath = [[NSBundle mainBundle] pathForResource:@"Ausruestung" ofType:@"json"];
      _objectsByName = [NSJSONSerialization JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                                                       options: NSJSONReadingMutableContainers
                                                         error: &e];
      if (e)
        {
           NSLog(@"DSAObjectManager init: Error loading JSON: %@", e.localizedDescription);
        }
      else
        {
          [self enrichEquipmentData];
        }
      filePath = [[NSBundle mainBundle] pathForResource:@"Gifte" ofType:@"json"];
      NSMutableDictionary *poisonsDict = [NSJSONSerialization JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &e];
      if (e)
        {
           NSLog(@"DSAObjectManager init: Error loading JSON: %@", e.localizedDescription);
        }
      else
        {
          for (NSString *key in [poisonsDict allKeys])
            {
              NSMutableDictionary *poisonDict = [[NSMutableDictionary alloc] init];
              poisonDict = [poisonsDict[key] mutableCopy];
              poisonDict[@"Name"] = key;
              poisonDict[@"category"] = @"Gift";
              [_objectsByName setObject: poisonDict forKey: key];
            }
        } 
      filePath = [[NSBundle mainBundle] pathForResource:@"Pflanzen" ofType:@"json"];
      NSMutableDictionary *plantsDict = [NSJSONSerialization JSONObjectWithData: [NSData dataWithContentsOfFile: filePath]
                                                                        options: NSJSONReadingMutableContainers
                                                                          error: &e];
      if (e)
        {
           NSLog(@"DSAObjectManager init: Error loading JSON: %@", e.localizedDescription);
        }
      else
        {
          for (NSString *key in [plantsDict allKeys])
            {
              NSMutableDictionary *plantDict = [[NSMutableDictionary alloc] init];
              plantDict = [plantsDict[key] mutableCopy];
              plantDict[@"Name"] = key;
              [_objectsByName setObject: plantDict forKey: key];
            }
        }             
      
    }
  return self;
}

- (void)enrichEquipmentData {
    for (NSString *key in _objectsByName) {
        //NSLog(@"Utils.m enrichEquipmentData: CHECKING KEY: %@", key);
        NSMutableDictionary *entry = _objectsByName[key];

            if ([entry[@"Name"] isEqualToString: @"Bier"])
              {
                NSLog(@"DSAObject enrichEquipmentData BEGINNING entry: %@", entry);
              }
            if (entry[@"TrefferpunkteKK"] != nil) {
                entry[@"isHandWeapon"] = @YES;
            }
            if (entry[@"TP Entfernung"] != nil) {
                entry[@"isDistantWeapon"] = @YES;
            }
            if (entry[@"Rüstschutz"] != nil) {
                entry[@"isArmor"] = @YES;
            }
            if (entry[@"Waffenvergleichswert Schild"]) {
                entry[@"isShield"] = @YES;
                if (entry[@"Waffenvergleichswert"]) {
                  entry[@"isHandWeapon"] = @YES;
                }
            }
            
            if (entry[@"HatSlots"] != nil)
              {
                entry[@"isContainer"] = @YES;
              }
            
            // Optionally, compute and format additional fields here
            if (entry[@"Trefferpunkte"] != nil) {
                entry[@"TP"] = [entry[@"Trefferpunkte"] componentsJoinedByString:@", "];
            }
            if (entry[@"TP Entfernung"] != nil) {
                entry[@"TP Entfernung Formatted"] = [self formatTPEntfernung:entry[@"TP Entfernung"]];
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
                  NSLog(@"DSAObjectManager enrichEquipmentData: Invalid Waffenvergleichswert format: %@ ABORTING!", waffenvergleichswert);
                  abort();
                }
            }
            if (entry[@"Waffenvergleichswert Schild"] != nil) {
                NSString *waffenvergleichswertSchild = entry[@"Waffenvergleichswert Schild"];
                NSArray *values = [waffenvergleichswertSchild componentsSeparatedByString:@"/"];
    
                if (values.count == 2) {
                  // Parse the attackPower and parryValue as integers
                  NSInteger shieldAttackPower = [values[0] integerValue];
                  NSInteger shieldParryValue = [values[1] integerValue];
        
                  // Assign them back to the dictionary
                  entry[@"shieldAttackPower"] = @(shieldAttackPower);
                  entry[@"shieldParryValue"] = @(shieldParryValue);
                } else {
                  NSLog(@"DSAObjectManager enrichEquipmentData: Invalid Waffenvergleichswert Schild format: %@", waffenvergleichswertSchild);
                }
            }                 
            if (entry[@"Regionen"] != nil) {
                entry[@"Regionen Formatted"] = [entry[@"Regionen"] componentsJoinedByString:@", "];
                NSArray *regionen = [NSArray arrayWithArray: entry[@"Regionen"]];
                entry[@"Regionen"] = regionen;
            }

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
            if ([entry[@"category"] isEqualToString: @"Nahrungs- und Genußmittel"])
              {
                entry[@"isFood"] = @YES;
                if ([entry[@"subCategory"] isEqualToString: @"Getränke"])
                  {
                    entry[@"isDrink"] = @YES;
                    if ([entry[@"subSubCategory"] isEqualToString: @"Alkoholisch"])
                      {
                        entry[@"isAlcohol"] = @YES;
                      }
                    else
                      {
                        entry[@"isAlcohol"] = @NO;
                      }
                  }
                else
                  {
                    entry[@"isDrink"] = @NO;
                  }
              }

            if ([entry[@"MehrereProSlot"] isEqualTo: @YES])
              {
                entry[@"canShareSlot"] = @YES;
              }              
              
            // Add the slot types parsing logic here
            NSArray *validSlotTypes = entry[@"ErlaubtInSlots"];
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
            if ([entry[@"Name"] isEqualToString: @"Lulanie"])
              {
                NSLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX DSAObject enrichEquipmentData END entry: %@", entry);
              }            
    }
}

// helper method to enrich object data, DSASlot related info on DSAObjects
- (DSASlotType)slotTypeFromString:(NSString *)slotTypeString {
    NSDictionary<NSString *, NSNumber *> *slotTypeMapping = @{
        @"Allgemein" : @(DSASlotTypeGeneral),
        @"Unterwäsche" : @(DSASlotTypeUnderwear),
        @"Körperrüstung" : @(DSASlotTypeBodyArmor),
        @"Kopfbedeckung" : @(DSASlotTypeHeadgear),
        @"Schuh" : @(DSASlotTypeShoes),
        @"Halskette" : @(DSASlotTypeNecklace),
        @"Ohrring" : @(DSASlotTypeEarring),
        @"Nasenring" : @(DSASlotTypeNosering),
        @"Brille" : @(DSASlotTypeGlasses),
        @"Maske" : @(DSASlotTypeMask),
        @"Rucksack" : @(DSASlotTypeBackpack),
        @"Rückenköcher" : @(DSASlotTypeBackquiver),
        @"Schärpe" : @(DSASlotTypeSash),
        @"Armrüstung" : @(DSASlotTypeArmArmor),
        @"Armreif" : @(DSASlotTypeArmRing),
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
        @"Flüssigkeit" : @(DSASlotTypeLiquid),
        @"Schwert" : @(DSASlotTypeSword),
        @"Dolch" : @(DSASlotTypeDagger),
        @"Axt" : @(DSASlotTypeAxe),
        @"Geld" : @(DSASlotTypeMoney),
        @"Tabak" : @(DSASlotTypeTobacco),
        @"Wasser": @(DSASlotTypeWater),
    };

    // Look up the corresponding slot type
    NSNumber *slotTypeNumber = slotTypeMapping[slotTypeString];
    // NSLog(@"Utils: slotTypeFromString: for slot type: %@ returning: %@", slotTypeString, slotTypeNumber);
    return slotTypeNumber ? slotTypeNumber.unsignedIntegerValue : NSNotFound;
}


// methods to format various strings
- (NSString *)formatTPEntfernung:(NSDictionary *)tpEntfernung {
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
    return [NSString stringWithFormat: @"(%@)", [values componentsJoinedByString:@"/"]];
}
// end of methods to format various strings


- (NSDictionary *)getDSAObjectInfoByName:(NSString *)name
{
  return _objectsByName[name];
}

- (NSArray<DSAObject *> *)getAllDSAObjectsForShop:(NSString *)shopType
{
    NSMutableArray *objectsArr = [[NSMutableArray alloc] init];

    NSArray<NSString *> *relevantCategories = nil;

    NSLog(@"DSAObjectManager getAllDSAObjectsForShop: %@", shopType);
    
    if ([shopType isEqualToString:@"Krämer"]) {
        relevantCategories = DSAShopGeneralStoreCategories();
    } else if ([shopType isEqualToString:@"Waffenhändler"]) {
        relevantCategories = DSAShopWeaponStoreCategories();
    } else if ([shopType isEqualToString:@"Kräuterhändler"]) {
        relevantCategories = DSAShopHerbsStoreCategories();        
    } else {
        NSLog(@"DSAObjectManager getAllDSAObjectsForShop: unknown shop type: %@", shopType);
        abort();
        return @[];
    }
    //NSLog(@"DSAObject getAllDSAObjectsForShop got relevant categories: %@", relevantCategories);
    for (NSString *category in relevantCategories) {
        for (NSDictionary *objectDict in [_objectsByName allValues])
          {
            if ([[objectDict objectForKey: @"category"] isEqualToString: category])
              {
                DSAObject *object = [[DSAObject alloc] initWithObjectInfo: objectDict forOwner: nil];
                [objectsArr addObject: object];
              }
          }
      }

    return objectsArr;
}

@end