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

#ifndef _DSAOBJECT_H_
#define _DSAOBJECT_H_

#import <Foundation/Foundation.h>
#import "DSASpell.h"

typedef NS_ENUM(NSUInteger, DSAObjectState)
{
  DSAObjectStateIsUnbreakable,                // object is not destroyable
  DSAObjectStateIsBroken,                     // object is broken
  DSAObjectStateIsPoisoned,                   // object is poisoned
  DSAObjectStateHasSpellActive,               // object has a magic spell activated
  DSAObjectStateHasUnknownMagic,              // object is magic, but it's unknown which spells/rituals are applied
  DSAObjectStateIsConsumable,                 // object can be consumed i.e. eaten or drunk
  DSAObjectStateStabzauberFackel,             // torch Stabzauber is active
  DSAObjectStateStabzauberSeil,               // rope Stabzauber is active
  DSAObjectStateNoMoreStabzauber,             // Stabzauber 5 failed, no more Stabzauber possible
  DSAObjectStateStabzauberTierverwandlung,    // Stabzauber 6 verwandlung in Chamäleon oder Speikobra
  DSAObjectStateKugelzauberBrennglas,         // Kugelzauber 2, Kugel ist zu einem Brennglas verwandelt
  DSAObjectStateKugelzauberSchutzfeld,        // Kugelzauber 3, Kugel erzeugt Schutzfeld gegen Untote etc.
  DSAObjectStateKugelzauberWarnung,           // Kugelzauber 4, Warnung vor Haß und Mordlust
};

@class DSASlot;

@interface DSAObject : NSObject <NSCoding, NSCopying>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *subCategory;
@property (nonatomic, strong) NSString *subSubCategory;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) float price;
@property (nonatomic, assign) float penalty;
@property (nonatomic, assign) float protection;
@property (nonatomic, assign) NSInteger breakFactor;
@property (nonatomic, strong) NSUUID *ownerUUID;
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, strong) NSArray *useWith;                       // object can be used with these other objects
@property (nonatomic, strong) NSString *useWithText;                  // text displayed when used

@property (nonatomic, strong) NSMutableSet<NSNumber *> *states;

@property (nonatomic) BOOL canShareSlot;
@property (nonatomic, strong) NSArray<NSNumber *> *occupiedBodySlots; // Body parts this item occupies
@property (nonatomic, strong) NSArray<NSNumber *> *validSlotTypes; // List of DSASlotTypes this object can be placed in
@property (nonatomic, strong) NSMutableDictionary<NSString*, DSASpell *> *appliedSpells;  // spells casted onto a character, and having effect on it


- (instancetype) initWithName: (NSString *) name forOwner: (NSUUID *)ownerUUID;

- (instancetype) initWithObjectInfo: (NSDictionary *) objectInfo forOwner: (NSUUID *) ownerUUID;

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
                  withRegions: (NSArray *) regions;
                  
- (BOOL)isCompatibleWithObject:(DSAObject *)otherObject;                    
                    

@end

// Subclasses come here
@interface DSAObjectContainer : DSAObject
@property (nonatomic, strong) NSMutableArray<DSASlot *> *slots;  // The slots the container holds
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
                  withRegions: (NSArray *) regions;

@end
// End of DSAObjectContainer

@interface DSAObjectWeapon : DSAObject
@property (nonatomic, strong) NSArray *hitPoints;
@end
// End of DSAObjectWeapon

@interface DSAObjectWeaponHandWeapon : DSAObjectWeapon
@property (nonatomic, assign) NSInteger hitPointsKK;
@property (nonatomic, assign) float length;
@property (nonatomic, assign) NSInteger attackPower;
@property (nonatomic, assign) NSInteger parryValue;

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
                  withRegions: (NSArray *) regions;
@end
// End of DSAObjectWeaponHandWeapon

@interface DSAObjectWeaponHandAndLongRangeWeapon : DSAObjectWeaponHandWeapon
@property (nonatomic, assign) NSInteger maxDistance;
@property (nonatomic, strong) NSDictionary *distancePenalty;
@property (nonatomic, strong) NSArray *hitPointsLongRange;

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
                  withRegions: (NSArray *) regions;


@end
// End of DSAObjectWeaponHandAndLongRangeWeapon

@interface DSAObjectWeaponLongRange : DSAObjectWeapon
@property (nonatomic, assign) NSInteger maxDistance;
@property (nonatomic, strong) NSDictionary *distancePenalty;
@property (nonatomic, strong) NSArray *hitPointsLongRange;
@property (nonatomic, strong) NSArray *ammunition;


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
                  withRegions: (NSArray *) regions;
@end
// End of DSAObjectWeaponLongRange

@interface DSAObjectShield : DSAObject
@property (nonatomic, assign) NSInteger shieldAttackPower;
@property (nonatomic, assign) NSInteger shieldParryValue;

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
@end
// End of DSAObjectShield

@interface DSAObjectShieldAndParry : DSAObjectShield
@property (nonatomic, assign) float length;
@property (nonatomic, strong) NSArray *hitPoints;
@property (nonatomic, assign) NSInteger hitPointsKK;
@property (nonatomic, assign) NSInteger attackPower;
@property (nonatomic, assign) NSInteger parryValue;

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
                  withRegions: (NSArray *) regions;
@end
// End of DSAObjectShieldAndParry

@interface DSAObjectArmor : DSAObject

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
                  withRegions: (NSArray *) regions;
@end
// End of DSAObjectArmor

@interface DSAObjectFood : DSAObject
@property (nonatomic) BOOL isConsumable;
@property (nonatomic) BOOL isAlcohol;
@property (nonatomic, assign) NSInteger alcoholLevel;
@property (nonatomic, assign) float nutritionValue;
@property (nonatomic, strong) NSString *becomeWhenEmpty;                    // Item name, when it becomes empty, i.e. a bottle...
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
                 canShareSlot: (BOOL) canShareSlot;
@end
// End of DSAObjectFood
                    
@interface DSAObjectCloth : DSAObject
@property (nonatomic) BOOL isTailored;                                 // ist Maßgeschneidert
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                  withPenalty: (float) penalty                        // Behinderung
               withProtection: (float) protection                     // armor
                   isTailored: (BOOL) isTailored
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots       
            withAppliedSpells: (NSMutableDictionary *) appliedSpells
                withOwnerUUID: (NSUUID *) ownerUUID                     
                  withRegions: (NSArray *) regions;
@end
// End of DSAObjectCloth

#endif // _DSAOBJECT_H_

