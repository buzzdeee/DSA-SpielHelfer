/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-11 21:43:36 +0100 by sebastia

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

#ifndef _DSAINVENTORYMANAGER_H_
#define _DSAINVENTORYMANAGER_H_

#import <Foundation/Foundation.h>
#import "DSACharacter.h"
#import "DSASlot.h"
#import "DSAObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface DSAInventoryManager : NSObject

+ (instancetype)sharedManager;

/// returns the item stored in a given inventory/slot
- (DSAObject *)findItemInModel: (DSACharacter *) model
           inventoryIdentifier: (NSString *) inventoryIdentifier
                     slotIndex: (NSInteger) slotIndex;

/// searches and finds an item by its name in all inventories of a given model           
- (DSAObject *) findItemWithName: (NSString *) name 
                         inModel: (DSACharacter *) model;                     
                     
/// replaces a new instantiated item in an inventory of a character
/// @param oldItem the item to be replaced
/// @param inModel the character that's intended to be in possession of oldItem
/// @param newItem the item that's going to replace the oldItem, if newItem is nil, 
/// the oldItem will be replaced with void, i.e. it gets deleted

- (BOOL) replaceItem: (DSAObject *) oldItem
             inModel: (DSACharacter *) model
            withItem: (nullable DSAObject *) newItem;                     
                     
/// Transfers an item between two slots in the same or different inventories.
/// @param sourceSlotIndex The source slot index.
/// @param inInventory the source inventory identifier.
/// @param sourceModel The source character model.
/// @param targetSlotIndex The target slot index.
/// @param targetModel The target character model.
/// @param inventoryIdentifier the target inventory identifier.
/// @return YES if the transfer is successful, NO otherwise.
- (BOOL)transferItemFromSlot:(NSInteger)sourceSlotIndex
                 inInventory:(NSString *)sourceInventory
                     inModel:(DSACharacter *)sourceModel
                      toSlot:(NSInteger)targetSlotIndex
                     inModel:(DSACharacter *)targetModel
         inventoryIdentifier:(NSString *)targetInventoryIdentifier;

              
- (BOOL)transferMultiSlotItem:(DSAObject *)item
                    fromModel:(DSACharacter *)sourceModel
                      toModel:(DSACharacter *)targetModel
                  toSlotIndex:(NSInteger)targetSlotIndex
    sourceInventoryIdentifier:(NSString *)sourceInventoryIdentifier
              sourceSlotIndex:(NSInteger)sourceSlotIndex
    targetInventoryIdentifier:(NSString *)targetInventoryIdentifier;              
                             
- (BOOL)cleanUpSourceSlotsForItem:(DSAObject *)item
                          inModel:(DSACharacter *)sourceModel
        sourceInventoryIdentifier:(NSString *)sourceInventoryIdentifier
                sourceSlotIndex:(NSInteger)sourceSlotIndex;
                   
- (DSASlot *)findOccupiedBodySlotOfType:(DSASlotType)slotType inModel:(DSACharacter *)model;
- (DSASlot *)findFreeBodySlotOfType:(NSInteger)slotType inModel:(DSACharacter *)model;
- (BOOL)areBodySlotsAvailableForItem:(DSAObject *)item inModel:(DSACharacter *)model;
- (BOOL)isItem:(DSAObject *)item compatibleWithSlot:(DSASlot *)slot forModel:(DSACharacter *)model;
- (BOOL)isItem:(DSAObject *)item compatibleWithSlot:(DSASlot *)slot;         
         
@end

NS_ASSUME_NONNULL_END

#endif // _DSAINVENTORYMANAGER_H_

