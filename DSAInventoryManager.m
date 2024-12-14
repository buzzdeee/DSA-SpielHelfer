/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-11 21:41:50 +0100 by sebastia

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

#import "DSAInventoryManager.h"

@implementation DSAInventoryManager

+ (instancetype)sharedManager {
    static DSAInventoryManager *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (BOOL)transferItemFromSlot:(NSInteger)sourceSlotIndex
                  inInventory:(NSString *)sourceInventory // New parameter for source inventory
                     inModel:(DSACharacter *)sourceModel
                     toSlot:(NSInteger)targetSlotIndex
                    inModel:(DSACharacter *)targetModel
           inventoryIdentifier:(NSString *)targetInventoryIdentifier // New parameter for target inventory
{
    // Get the source and target slots directly from the parameters
    DSASlot *sourceSlot = [self findSlotInModel:sourceModel
                             withInventoryIdentifier:sourceInventory // Pass source inventory
                                          atIndex:sourceSlotIndex];
    DSASlot *targetSlot = [self findSlotInModel:targetModel
                             withInventoryIdentifier:targetInventoryIdentifier // Pass target inventory
                                          atIndex:targetSlotIndex];
    NSLog(@"TRANSFERRING SINGLE SLOT ITEM");
    // Validate the source and target slots
    if (!sourceSlot || !targetSlot) {
        NSLog(@"Invalid slot indices or model references. source slot: %@ targetSlot %@", sourceSlot, targetSlot);
        return NO;
    }

    // Ensure that source slot has an item
    if (!sourceSlot.object) {
        NSLog(@"Source slot is empty.");
        return NO;
    }
    
    // Check for the valid slot type (e.g., item can only go into compatible slots)
    if (![self isItem:sourceSlot.object compatibleWithSlot:targetSlot]) {
        NSLog(@"Incompatible item for target slot.");
        return NO;
    }

    // Check if we can transfer the item (check max item count, etc.)
    NSInteger remainingCapacity = targetSlot.maxItemsPerSlot - targetSlot.quantity;
    
    if (sourceSlot.object.canShareSlot && remainingCapacity > 0) {
        // Handle shared slot logic
        NSInteger transferCount = MIN(remainingCapacity, sourceSlot.quantity);

        // Update the target slot
        targetSlot.quantity += transferCount;
        targetSlot.object = sourceSlot.object;

        // Update the source slot
        sourceSlot.quantity -= transferCount;
        if (sourceSlot.quantity == 0) {
            sourceSlot.object = nil; // Clear source slot if empty
        }
        [self postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];
        return YES;
    } else if (!sourceSlot.object.canShareSlot && targetSlot.object == nil) {
        NSLog(@"Before updating slots: Source Slot: %@, Quantity: %ld", sourceSlot.object, sourceSlot.quantity);
        NSLog(@"Before updating slots: Target Slot: %@, Quantity: %ld", targetSlot.object, targetSlot.quantity);    
        // If item can't share slot, just move it over if target is empty
        targetSlot.object = sourceSlot.object;
        targetSlot.quantity = sourceSlot.quantity;

        // Clear source slot
        sourceSlot.object = nil;
        sourceSlot.quantity = 0;
        
        NSLog(@"After updating slots: Source Slot: %@, Quantity: %ld", sourceSlot.object, sourceSlot.quantity);
        NSLog(@"After updating slots: Target Slot: %@, Quantity: %ld", targetSlot.object, targetSlot.quantity);
        
        [self postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];
        return YES;
    }

    NSLog(@"Transfer failed: No space or incompatible item.");
    return NO;
}


- (void) postDSAInventoryChangedNotificationForSourceModel: (DSACharacter *) sourceModel targetModel: (DSACharacter *)targetModel
{
    if (sourceModel == targetModel) {
        NSLog(@"DSAInventoryManager postDSAInventoryChangedNotificationForSourceModel posting single notification");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAInventoryChangedNotification"
                                                            object:sourceModel
                                                          userInfo:@{@"sourceModel": sourceModel, @"targetModel": targetModel}];
        NSLog(@"DSAInventoryManager: Posting notification with sourceModel: %p, targetModel: %p", sourceModel, targetModel);                                                          
    } else {
        // If source and target models are different, send two notifications
        NSLog(@"DSAInventoryManager postDSAInventoryChangedNotificationForSourceModel posting two notifications");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAInventoryChangedNotification"
                                                            object:sourceModel
                                                          userInfo:@{@"sourceModel": sourceModel, @"targetModel": targetModel}];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAInventoryChangedNotification"
                                                            object:targetModel
                                                          userInfo:@{@"sourceModel": sourceModel, @"targetModel": targetModel}];
    }  
}

- (DSASlot *)findSlotInModel:(DSACharacter *)model 
      withInventoryIdentifier:(NSString *)inventoryIdentifier 
                      atIndex:(NSInteger)slotIndex {
    if ([inventoryIdentifier isEqualToString:@"inventory"]) {
        // Look in the general inventory
        if (slotIndex >= 0 && slotIndex < model.inventory.slots.count) {
            return model.inventory.slots[slotIndex];
        }
    } else if ([inventoryIdentifier isEqualToString:@"body"]) {
        // Look in the body part inventories
        NSInteger bodySlotCounter = 0; // Global body slot counter
        for (NSString *propertyName in model.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [model.bodyParts valueForKey:propertyName];
            if (slotIndex >= bodySlotCounter && slotIndex < bodySlotCounter + inventory.slots.count) {
                // Adjust slot index relative to this inventory
                NSInteger adjustedSlotIndex = slotIndex - bodySlotCounter;
                return inventory.slots[adjustedSlotIndex];
            }
            bodySlotCounter += inventory.slots.count; // Increment the counter
        }
    }

    // If no matching slot is found
    NSLog(@"DSAInventoryManager: Invalid slot index %ld for inventory %@", (long)slotIndex, inventoryIdentifier);
    return nil;
}

- (BOOL)isItem:(DSAObject *)item compatibleWithSlot:(DSASlot *)slot forModel:(DSACharacter *)model {
    // Multi-slot item logic
    if (item.occupiedBodySlots && item.occupiedBodySlots.count > 0) {
        NSLog(@"Checking compatibility for multi-slot item: %@ in slot type: %lu", item.name, (unsigned long)slot.slotType);

        // Allow dropping into DSASlotTypeGeneral (general inventory) only if it's empty
        if (slot.slotType == DSASlotTypeGeneral) {
            if (slot.object == nil) {
                NSLog(@"Multi-slot item can be dropped into empty general inventory slot.");
                return YES;
            } else {
                NSLog(@"Multi-slot item cannot be dropped into occupied general inventory slot.");
                return NO;
            }
        }

        // If the slot type is not in the item's occupiedBodySlots, it's incompatible
        if (![item.occupiedBodySlots containsObject:@(slot.slotType)]) {
            NSLog(@"Multi-slot item is incompatible with slot type %ld", (long)slot.slotType);
            return NO;
        }

        // Ensure all required slots are free
        for (NSNumber *requiredSlotType in item.occupiedBodySlots) {
            DSASlot *requiredSlot = [[DSAInventoryManager sharedManager] findFreeBodySlotOfType:requiredSlotType.integerValue inModel:model];
            if (!requiredSlot) {
                NSLog(@"Multi-slot item requires a free slot of type %ld, but none are available.", requiredSlotType.integerValue);
                return NO;
            }
        }

        // If all required slots are free, the item is compatible
        return YES;
    }

    // Single-slot item logic
    NSLog(@"Checking compatibility for single-slot item: %@", item.name);

    // Check if the slot's type is valid for the item
    if (![item.validSlotTypes containsObject:@(slot.slotType)]) {
        NSLog(@"isItem: compatibleWithSlot: forModel: Item type is incompatible with slot type.");
        return NO;
    }

    // If the slot is empty, it's compatible
    if (slot.object == nil) {
        return YES;
    }

    // If the item cannot share a slot and the slot is already occupied, it's incompatible
    if (!item.canShareSlot) {
        NSLog(@"Item cannot share slot and the slot is already occupied.");
        return NO;
    }

    // If the slot is occupied, ensure the items are of the same type
    if (![slot.object isCompatibleWithObject:item]) {
        NSLog(@"Shared slot is already occupied by a different or incompatible item.");
        return NO;
    }

    // If the item can share the slot, check for available capacity
    NSInteger remainingCapacity = slot.maxItemsPerSlot - slot.quantity;
    if (remainingCapacity <= 0) {
        NSLog(@"No space left in the target slot for shared items.");
        return NO;
    }

    // The item is compatible with the slot
    return YES;
}



- (BOOL)isItem:(DSAObject *)item compatibleWithSlot:(DSASlot *)slot {
    // Check if the slot's type is valid for the item
    if (![item.validSlotTypes containsObject:@(slot.slotType)]) {
        NSLog(@"isItem: compatibleWithSlot: Item type is incompatible with slot type.");
        return NO;
    }

    // If the slot is empty, it's compatible
    if (slot.object == nil) {
        return YES;
    }

    // If the item cannot share a slot and the slot is already occupied, it's incompatible
    if (!item.canShareSlot) {
        NSLog(@"Item cannot share slot and the slot is already occupied.");
        return NO;
    }

    // If the slot is occupied, ensure the items are of the same type
    if (![slot.object isCompatibleWithObject:item]) {
        NSLog(@"Shared slot is already occupied by a different or incompatible item.");
        return NO;
    }

    // If the item can share the slot, check for available capacity
    NSInteger remainingCapacity = slot.maxItemsPerSlot - slot.quantity;
    if (remainingCapacity <= 0) {
        NSLog(@"No space left in the target slot for shared items.");
        return NO;
    }

    // The item is compatible with the slot
    return YES;
}

- (DSASlot *)findOccupiedBodySlotOfType:(DSASlotType)slotType inModel:(DSACharacter *)model {
    for (NSString *propertyName in model.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [model.bodyParts valueForKey:propertyName];
        for (DSASlot *slot in inventory.slots) {
            if (slot.slotType == slotType && slot.object != nil) {
                return slot; // Found an occupied slot
            }
        }
    }
    return nil; // No occupied slot found
}

// Check if all required body slots are free
- (BOOL)areBodySlotsAvailableForItem:(DSAObject *)item inModel:(DSACharacter *)model {
    for (NSNumber *slotType in item.occupiedBodySlots) {
        if (![self findFreeBodySlotOfType:[slotType integerValue] inModel:model]) {
            return NO; // At least one required slot is occupied
        }
    }
    return YES;
}


- (BOOL)transferMultiSlotItem:(DSAObject *)item
                    fromModel:(DSACharacter *)sourceModel
                      toModel:(DSACharacter *)targetModel
                  toSlotIndex:(NSInteger)targetSlotIndex
    sourceInventoryIdentifier:(NSString *)sourceInventoryIdentifier
              sourceSlotIndex:(NSInteger)sourceSlotIndex
    targetInventoryIdentifier:(NSString *)targetInventoryIdentifier { // Add targetInventoryIdentifier

    NSLog(@"DSAInventoryManager: TRANSFERRING MULTI-SLOT ITEM");

    // Validate parameters
    if (!item || !sourceModel || !targetModel || !targetInventoryIdentifier) {
        NSLog(@"Invalid parameters for transferring multi-slot item.");
        return NO;
    }

    // Find the target slot using the targetInventoryIdentifier
    DSASlot *targetSlot = [[DSAInventoryManager sharedManager]
                           findSlotInModel:targetModel
                           withInventoryIdentifier:targetInventoryIdentifier // Use the passed identifier
                           atIndex:targetSlotIndex];

    // Validate the target slot
    if (!targetSlot) {
        NSLog(@"Target slot not found in the model.");
        return NO;
    }

    // Handle general slots (DSASlotTypeGeneral)
    if (targetSlot.slotType == DSASlotTypeGeneral) {
        NSLog(@"DSAInventoryManager: Assigning multi-slot item to a general slot.");
        targetSlot.object = item;
        targetSlot.quantity = 1; // Multi-slot items are always quantity 1 in a general slot

        // Clean up source slots
        [[DSAInventoryManager sharedManager] cleanUpSourceSlotsForItem:item
                                                              inModel:sourceModel
                                             sourceInventoryIdentifier:sourceInventoryIdentifier
                                                     sourceSlotIndex:sourceSlotIndex];

        [self postDSAInventoryChangedNotificationForSourceModel:sourceModel targetModel:targetModel];
        return YES;
    }

    // Handle multi-slot assignment to body part inventories
    NSLog(@"DSAInventoryManager: Assigning multi-slot item to body slots.");
    NSMutableArray<DSASlot *> *targetSlots = [NSMutableArray array];
    NSCountedSet *slotTypeSet = [[NSCountedSet alloc] initWithArray:item.occupiedBodySlots];

    for (NSNumber *slotType in slotTypeSet) {
        NSInteger requiredCount = [slotTypeSet countForObject:slotType];
        NSInteger foundCount = 0;

        // Look for the necessary free body slots in the target model
        for (NSString *propertyName in targetModel.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [targetModel.bodyParts valueForKey:propertyName];

            for (DSASlot *slot in inventory.slots) {
                if (slot.slotType == [slotType integerValue] && slot.object == nil) {
                    [targetSlots addObject:slot];
                    foundCount++;

                    if (foundCount == requiredCount) {
                        break; // Stop once enough slots are found
                    }
                }
            }
            if (foundCount == requiredCount) {
                break;
            }
        }

        // Check if we found enough slots for this slot type
        if (foundCount < requiredCount) {
            NSLog(@"Not enough free slots of type %@ available in target model.", slotType);
            return NO; // Fail if we can't find enough slots
        }
    }

    // Assign the item to all required slots
    for (DSASlot *slot in targetSlots) {
        slot.object = item;
        slot.quantity = 1; // Multi-slot items occupy exactly 1 per slot
    }

    // Clean up source slots
    [[DSAInventoryManager sharedManager] cleanUpSourceSlotsForItem:item
                                                          inModel:sourceModel
                                     sourceInventoryIdentifier:sourceInventoryIdentifier
                                             sourceSlotIndex:sourceSlotIndex];

    // Post inventory change notifications
    [self postDSAInventoryChangedNotificationForSourceModel:sourceModel targetModel:targetModel];
    return YES;
}


- (BOOL)cleanUpSourceSlotsForItem:(DSAObject *)item
                          inModel:(DSACharacter *)sourceModel
        sourceInventoryIdentifier:(NSString *)sourceInventoryIdentifier
                sourceSlotIndex:(NSInteger)sourceSlotIndex {
    NSLog(@"DSAInventoryManager: Cleaning up source slots for item: %@ from inventory: %@, slot: %ld",
          item.name, sourceInventoryIdentifier, (long)sourceSlotIndex);

    // Find the source slot
    DSASlot *sourceSlot = [self findSlotInModel:sourceModel
                        withInventoryIdentifier:sourceInventoryIdentifier
                                        atIndex:sourceSlotIndex];
    if (!sourceSlot) {
        NSLog(@"DSAInventoryManager: Source slot not found.");
        return NO;
    }

    if (sourceSlot.slotType == DSASlotTypeGeneral) {
        // Clean a single slot if the source is a general inventory slot
        NSLog(@"DSAInventoryManager: Cleaning single general slot in source inventory.");
        sourceSlot.object = nil;
        sourceSlot.quantity = 0;
        return YES;
    }

    if (item.occupiedBodySlots.count == 0) {
        // Clean a single slot for non-multi-slot items
        NSLog(@"DSAInventoryManager: Cleaning single body slot for non-multi-slot item.");
        sourceSlot.object = nil;
        sourceSlot.quantity = 0;
        return YES;
    }

    // Clean all slots occupied by a multi-slot item
    NSLog(@"DSAInventoryManager: Cleaning all occupied slots for multi-slot item.");
    NSCountedSet *slotTypeSet = [[NSCountedSet alloc] initWithArray:item.occupiedBodySlots];

    for (NSNumber *slotType in slotTypeSet) {
        NSInteger requiredCount = [slotTypeSet countForObject:slotType];
        NSInteger clearedCount = 0;

        for (NSString *propertyName in sourceModel.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [sourceModel.bodyParts valueForKey:propertyName];

            for (DSASlot *slot in inventory.slots) {
                if (slot.slotType == [slotType integerValue] && slot.object == item) {
                    slot.object = nil;
                    slot.quantity = 0;
                    clearedCount++;

                    if (clearedCount == requiredCount) {
                        break; // Stop once we've cleared enough slots of this type
                    }
                }
            }
            if (clearedCount == requiredCount) {
                break;
            }
        }
    }

    NSLog(@"DSAInventoryManager: Finished cleaning up source slots.");
    return YES;
}

/*
- (BOOL)transferMultiSlotItem:(DSAObject *)item
                    fromModel:(DSACharacter *)sourceModel
                      toModel:(DSACharacter *)targetModel
                  toSlotIndex:(NSInteger)targetSlotIndex
    sourceInventoryIdentifier:(NSString *)sourceInventoryIdentifier
              sourceSlotIndex:(NSInteger)sourceSlotIndex {

    NSLog(@"DSAInventoryManager: TRANSFERRING MULTI-SLOT ITEM");

    if (!item || !sourceModel || !targetModel) {
        NSLog(@"Invalid parameters for transferring multi-slot item.");
        return NO;
    }

    DSASlot *targetSlot = [[DSAInventoryManager sharedManager]
                           findSlotInModel:targetModel
                           withInventoryIdentifier:@"inventory"
                           atIndex:targetSlotIndex];

    // Handle the case where the target is DSASlotTypeGeneral
    if (targetSlot && targetSlot.slotType == DSASlotTypeGeneral && targetSlot.object == nil) {
        // Move the item to the general inventory slot
        targetSlot.object = item;
        targetSlot.quantity = 1; // Multi-slot items always have a quantity of 1
        NSLog(@"DSAInventoryManager: Placed multi-slot item into general slot.");
    } else {
        // Otherwise, find and fill body slots for the multi-slot item
        NSMutableArray<DSASlot *> *targetSlots = [NSMutableArray array];
        NSCountedSet *slotTypeSet = [[NSCountedSet alloc] initWithArray:item.occupiedBodySlots];

        for (NSNumber *slotType in slotTypeSet) {
            NSInteger requiredCount = [slotTypeSet countForObject:slotType];
            NSInteger foundCount = 0;

            for (NSString *propertyName in targetModel.bodyParts.inventoryPropertyNames) {
                DSAInventory *inventory = [targetModel.bodyParts valueForKey:propertyName];

                for (DSASlot *slot in inventory.slots) {
                    if (slot.slotType == [slotType integerValue] && slot.object == nil) {
                        [targetSlots addObject:slot];
                        foundCount++;

                        if (foundCount == requiredCount) {
                            break; // Stop once we find enough slots
                        }
                    }
                }
                if (foundCount == requiredCount) {
                    break;
                }
            }

            if (foundCount < requiredCount) {
                NSLog(@"Not enough free slots of type %@ available in target model.", slotType);
                return NO; // Fail if we can't find enough slots
            }
        }

        // Assign the item to all required target slots
        for (DSASlot *slot in targetSlots) {
            slot.object = item;
            slot.quantity = 1;
        }
    }

    // Clean up the source slots
    DSASlot *sourceSlot = [[DSAInventoryManager sharedManager]
                           findSlotInModel:sourceModel
                           withInventoryIdentifier:sourceInventoryIdentifier
                           atIndex:sourceSlotIndex];

    if (sourceSlot.slotType == DSASlotTypeGeneral) {
        NSLog(@"DSAInventoryManager: Cleaning single general slot in source inventory.");
        sourceSlot.object = nil;
        sourceSlot.quantity = 0;
    } else {
        NSLog(@"DSAInventoryManager: Cleaning all occupied body slots for multi-slot item.");
        NSCountedSet *slotTypeSet = [[NSCountedSet alloc] initWithArray:item.occupiedBodySlots];

        for (NSNumber *slotType in slotTypeSet) {
            NSInteger requiredCount = [slotTypeSet countForObject:slotType];
            NSInteger clearedCount = 0;

            for (NSString *propertyName in sourceModel.bodyParts.inventoryPropertyNames) {
                DSAInventory *inventory = [sourceModel.bodyParts valueForKey:propertyName];

                for (DSASlot *slot in inventory.slots) {
                    if (slot.slotType == [slotType integerValue] && slot.object == item) {
                        slot.object = nil;
                        slot.quantity = 0;
                        clearedCount++;

                        if (clearedCount == requiredCount) {
                            break; // Stop once we've cleared enough slots
                        }
                    }
                }
                if (clearedCount == requiredCount) {
                    break;
                }
            }
        }
    }

    [self postDSAInventoryChangedNotificationForSourceModel:sourceModel targetModel:targetModel];
    return YES;
}
*/

/*
- (BOOL)transferMultiSlotItem:(DSAObject *)item
                    fromModel:(DSACharacter *)sourceModel
                      toModel:(DSACharacter *)targetModel
                  toSlotIndex:(NSInteger)targetSlotIndex
    sourceInventoryIdentifier:(NSString *)sourceInventoryIdentifier
              sourceSlotIndex:(NSInteger)sourceSlotIndex {

    NSLog(@"TRANSFERRING MULTI SLOT ITEM");
    if (!item || !sourceModel || !targetModel) {
        NSLog(@"Invalid parameters for transferring multi-slot item.");
        return NO;
    }

    // Attempt to find all required target slots for the item
    NSMutableArray<DSASlot *> *targetSlots = [NSMutableArray array];
    NSCountedSet *slotTypeSet = [[NSCountedSet alloc] initWithArray:item.occupiedBodySlots];

    for (NSNumber *slotType in slotTypeSet) {
        NSInteger requiredCount = [slotTypeSet countForObject:slotType];
        NSInteger foundCount = 0;

        for (NSString *propertyName in targetModel.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [targetModel.bodyParts valueForKey:propertyName];

            for (DSASlot *slot in inventory.slots) {
                if (slot.slotType == [slotType integerValue] && slot.object == nil) {
                    [targetSlots addObject:slot];
                    foundCount++;

                    if (foundCount == requiredCount) {
                        break; // Stop once we find enough slots
                    }
                }
            }
            if (foundCount == requiredCount) {
                break;
            }
        }

        if (foundCount < requiredCount) {
            NSLog(@"Not enough free slots of type %@ available in target model.", slotType);
            return NO; // Fail if we can't find enough slots
        }
    }

    // Assign the item to all required target slots
    for (DSASlot *slot in targetSlots) {
        slot.object = item;
        slot.quantity = 1; // multi-slot items are always of quantity 1
    }

    // Clean up the source slots
    DSASlot *sourceSlot = [self findSlotInModel:sourceModel
                         withInventoryIdentifier:sourceInventoryIdentifier
                                         atIndex:sourceSlotIndex];

    if (sourceSlot.slotType == DSASlotTypeGeneral) {
        // Clean a single source slot if it's DSASlotTypeGeneral
        NSLog(@"Cleaning single general inventory slot.");
        sourceSlot.object = nil;
        sourceSlot.quantity = 0;
    } else if ([item.occupiedBodySlots count] == 0) {
        // Clean a single slot if it's not a multi-slot item
        NSLog(@"Cleaning single body slot for non-multi-slot item.");
        sourceSlot.object = nil;
        sourceSlot.quantity = 0;
    } else {
        // Clean all slots occupied by the multi-slot item
        NSLog(@"Cleaning multi-slot item from body slots.");
        for (NSNumber *slotType in slotTypeSet) {
            NSInteger requiredCount = [slotTypeSet countForObject:slotType];
            NSInteger clearedCount = 0;

            for (NSString *propertyName in sourceModel.bodyParts.inventoryPropertyNames) {
                DSAInventory *inventory = [sourceModel.bodyParts valueForKey:propertyName];

                for (DSASlot *slot in inventory.slots) {
                    if (slot.slotType == [slotType integerValue] && slot.object == item) {
                        slot.object = nil;
                        slot.quantity = 0;
                        clearedCount++;

                        if (clearedCount == requiredCount) {
                            break; // Stop once we've cleared enough slots
                        }
                    }
                }
                if (clearedCount == requiredCount) {
                    break;
                }
            }
        }
    }

    // Post inventory change notifications
    [self postDSAInventoryChangedNotificationForSourceModel:sourceModel targetModel:targetModel];
    return YES;
}
*/
- (DSAObject *)findItemInModel:(DSACharacter *)model
           inventoryIdentifier:(NSString *)inventoryIdentifier
                     slotIndex:(NSInteger)slotIndex {
    if ([inventoryIdentifier isEqualToString:@"inventory"]) {
        DSASlot *slot = model.inventory.slots[slotIndex];
        return slot.object;
    } else if ([inventoryIdentifier isEqualToString:@"body"]) {
        NSInteger cumulativeIndex = 0;
        for (NSString *propertyName in model.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [model.bodyParts valueForKey:propertyName];
            if (slotIndex < cumulativeIndex + inventory.slots.count) {
                DSASlot *slot = inventory.slots[slotIndex - cumulativeIndex];
                return slot.object;
            }
            cumulativeIndex += inventory.slots.count;
        }
    }
    return nil;
}

- (DSASlot *)findFreeBodySlotOfType:(NSInteger)slotType inModel:(DSACharacter *)model {
    for (NSString *propertyName in model.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [model.bodyParts valueForKey:propertyName];

        for (DSASlot *slot in inventory.slots) {
            // Check if the slot matches the type and is empty
            if (slot.slotType == slotType && slot.object == nil) {
                return slot; // Return the first available free slot of the given type
            }
        }
    }
    return nil; // No free slot of the required type found
}

@end
