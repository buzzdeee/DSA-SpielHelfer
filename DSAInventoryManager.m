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
#import "Utils.h"
#import "DSAAdventure.h"
#import "DSAAdventureClock.h"

@implementation DSAInventoryManager

+ (instancetype)sharedManager {
    static DSAInventoryManager *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (BOOL)transferItemFromSlot: (NSInteger) sourceSlotIndex
                 inInventory: (NSString *) sourceInventory
                     inModel: (DSACharacter *) sourceModel
                      toSlot: (NSInteger) targetSlotIndex
                     inModel: (DSACharacter *) targetModel
         inventoryIdentifier: (NSString *) targetInventoryIdentifier
               mousePosition: (NSPoint) mousePosition
                      inView: (DSAInventorySlotView *) view
{
    // Get the source and target slots directly from the parameters
    DSASlot *sourceSlot = [self findSlotInModel:sourceModel
                        withInventoryIdentifier:sourceInventory // Pass source inventory
                                        atIndex:sourceSlotIndex];
    DSASlot *targetSlot = [self findSlotInModel:targetModel
                        withInventoryIdentifier:targetInventoryIdentifier // Pass target inventory
                                        atIndex:targetSlotIndex];

    // get a handle to current adventure
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    // NSLog(@"DSAInventoryManager transferItemFromSlot : TRANSFERRING SINGLE SLOT ITEM");
    // Validate the source and target slots
    if (!sourceSlot || !targetSlot) {
        NSLog(@"DSAInventoryManager transferItemFromSlot: Invalid slot indices or model references. source slot: %@ targetSlot %@", sourceSlot, targetSlot);
        return NO;
    }

    // Ensure that source slot has an item
    if (!sourceSlot.object) {
        NSLog(@"DSAInventoryManager transferItemFromSlot: Source slot is empty.");
        return NO;
    }
    
    // Check for the valid slot type (e.g., item can only go into compatible slots)
    if (![self isItem:sourceSlot.object compatibleWithSlot:targetSlot]) {
        NSLog(@"DSAInventoryManager transferItemFromSlot: Incompatible item for target slot.");
        return NO;
    }
    
    // in case we drag a container around, onto a general slot, and the dragged container contains items
    // ask if move everything, or unpack items
    if (targetSlot.object == nil && 
        targetSlot.slotType == DSASlotTypeGeneral && 
        [sourceSlot.object isKindOfClass: [DSAObjectContainer class]])
      {
        NSLog(@"DSAInventoryManager transferItemFromSlot: SOURCE IS a CONTAINER, TARGET is empty and of type GENERAL");
        DSAObjectContainer *container = (DSAObjectContainer *) sourceSlot.object;
        
        for (DSASlot *slot in container.slots)
          {
            if (slot.object != nil)
              {
                 return [self handleUnpackOperationForItemFromSlot:sourceSlot
                                                           inModel:sourceModel
                                                            toSlot:targetSlot
                                                           inModel:targetModel
                                                     mousePosition:mousePosition
                                                            inView:view];
              }
          }
      }
      
    if (targetSlot.object != nil &&
        [targetSlot.object isKindOfClass:[DSAObjectContainer class]])
        {
          return [self transferItemFromSlot: sourceSlot
                                    inModel: sourceModel
                                toContainer: (DSAObjectContainer *)targetSlot.object
                                    inModel: targetModel];
        }
    if ([self canUseItem: sourceSlot.object withItemInSlot: targetSlot])  
      {
        NSLog(@"DSAInventoryManager transferItemFromSlot: GOING TO USE TWO OBJECTS WITH EACH OTHER");
        NSDictionary *useWithDict;
        for (NSString *key in [targetSlot.object.useWith allKeys])
          {
            if ([sourceSlot.object.name isEqualToString: key] ||
                [sourceSlot.object.category isEqualToString: key] ||
                [sourceSlot.object.subCategory isEqualToString: key] ||
                [sourceSlot.object.subSubCategory isEqualToString: key])
              {
                useWithDict = targetSlot.object.useWith[key];
                break;
              }  
          }
        
        switch ([useWithDict[@"action"] integerValue])
          {
            case DSAUseObjectWithActionTypeSmoking:
              {
                NSLog(@"DSAInventoryManager transferItemFromSlot: use object %@ with DSAUseObjectWithActionTypeSmoking action", targetSlot.object.name);
                // nothing special
                break;
              }
            case DSAUseObjectWithActionTypePoisoning:
              {
                NSLog(@"DSAInventoryManager transferItemFromSlot: use object %@ with DSAUseObjectWithActionTypePoisoning action", targetSlot.object.name);
                break;
              }
            case DSAUseObjectWithActionTypeWeaponMaintenance:
              {
                NSLog(@"DSAInventoryManager transferItemFromSlot: use object %@ with DSAUseObjectWithActionTypeWeaponMaintenance action", targetSlot.object.name);
                break;              
              }
            default:
              {
                NSLog(@"DSAInventoryManager transferItemFromSlot: use object %@ with unknown action type: %@ action ABORTING", targetSlot.object.name, useWithDict[@"action"]);
                abort();
              }
          }
        BOOL result = [sourceSlot.object useOnceWithDate: adventure.gameClock.currentDate
                                                  reason: nil];
        if (result)
          {
            [self handleItemInSourceSlot: sourceSlot
                           ofSourceModel: sourceModel];


            NSDictionary *userInfo = @{ @"severity": @(LogSeverityInfo),
                                         @"message": [NSString stringWithFormat: [useWithDict objectForKey: @"useWithText"], sourceModel.name]
                                      };
            [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                                object: sourceModel
                                                              userInfo: userInfo];
               [self postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];
            return YES;
         }
         return NO;
      }
    
    
    // Check if we can transfer the item (check max item count, etc.)
    NSInteger remainingCapacity = targetSlot.maxItemsPerSlot - targetSlot.quantity;
    
    if (sourceSlot.object.canShareSlot && remainingCapacity >= 0) {
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
        //NSLog(@"Before updating slots: Source Slot: %@, Quantity: %ld", sourceSlot.object, sourceSlot.quantity);
        //NSLog(@"Before updating slots: Target Slot: %@, Quantity: %ld", targetSlot.object, targetSlot.quantity);    
        // If item can't share slot, just move it over if target is empty
        targetSlot.object = sourceSlot.object;
        targetSlot.quantity = sourceSlot.quantity;

        // Clear source slot
        sourceSlot.object = nil;
        sourceSlot.quantity = 0;
        
        NSLog(@"DSAInventoryManager transferItemFromSlot: After updating slots: Source Slot: %@, Quantity: %ld", sourceSlot.object, sourceSlot.quantity);
        NSLog(@"DSAInventoryManager transferItemFromSlot: After updating slots: Target Slot: %@, Quantity: %ld", targetSlot.object, targetSlot.quantity);
        
        [self postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];
        return YES;
    }

    NSLog(@"DSAInventoryManager transferItemFromSlot: Transfer failed: No space or incompatible item.");
    return NO;
}

-(void)handleItemInSourceSlot: (DSASlot *) sourceSlot
                ofSourceModel: (DSACharacter *) sourceModel
{                
    DSASlot *slot = sourceSlot;
    DSAObject *item = slot.object;
        
    //NSLog(@"DSAInventoryManager handleItemInSourceSlot: item just depleted???? %@", @([item justDepleted]));
    
    if ([item justDepleted])
      {
        //NSLog(@"DSAInventoryManager handleItemInSourceSlot: sourceModel item is depleted, cleaning up slot");                
        slot.quantity -= 1;
        if (slot.quantity == 0)
          {

            if ([slot.object transitionWhenEmpty])
              {
                //NSLog(@"DSAInventoryManager handleItemInSourceSlot: was called, and [slot.object transitionWhenEmpty] was true");
                NSString *transitionToName = [slot.object transitionWhenEmpty];
                //NSLog(@"DSAInventoryManager handleItemInSourceSlot: was called, and transitionToName: %@", transitionToName);
                slot.object = nil;
                slot.object = [[DSAObject alloc] initWithName: transitionToName forOwner: [sourceModel modelID]];
              }
            else if ([slot.object disappearWhenEmpty])
              {
                //NSLog(@"DSAInventoryManager handleItemInSourceSlot: was called, and [slot.object disappearWhenEmpty] was true");
                slot.object = nil;
              }
            else
              {
                //NSLog(@"DSAInventoryManager handleItemInSourceSlot: disappearWhenEmpty was default NO, and transitionWhenEmpty was empty assuming it should disappear!");
                slot.object = nil;
              }
          }
        else
          {
            [slot.object resetCurrentUsageToMax];    // there might be depletable objects in multiple slots, have to reset the count...
          }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAInventoryChangedNotification"
                                                            object:sourceModel
                                                          userInfo:@{@"sourceModel": sourceModel}];
      }
    else
      {
        //NSLog(@"DSAInventoryManager handleItemInSourceSlot: sourceModel item is not yet depleted, not cleaning up slot!");
      }
}            


- (BOOL) transferItemFromSlot: (DSASlot *) sourceSlot
                      inModel: (DSACharacter *) sourceModel
                  toContainer: (DSAObjectContainer *) targetContainer
                      inModel: (DSACharacter *) targetModel
{
  BOOL transferred = NO;
  for (DSASlot *slot in targetContainer.slots)  // recursively dive into containers ...
    {
      if ([self isItem:sourceSlot.object compatibleWithSlot:slot])
        {
          if (slot.object != nil && [slot.object isKindOfClass: [DSAObjectContainer class]])
            {
               transferred = [self transferItemFromSlot: sourceSlot
                                                inModel: sourceModel
                                            toContainer: (DSAObjectContainer *) slot.object
                                                inModel: targetModel];
               if (transferred == YES) // no need to postDSAInventoryChangedNotificationForSourceModel, the innermost did already...
                 {
                   return transferred;
                 }
            }
          else
            {
              NSInteger remainingQuantity = slot.maxItemsPerSlot - slot.quantity;
              NSInteger quantityToTransfer = sourceSlot.quantity <= remainingQuantity ? sourceSlot.quantity : remainingQuantity;
              slot.quantity += quantityToTransfer;
              slot.object = sourceSlot.object;
              sourceSlot.quantity -= quantityToTransfer;
              if (sourceSlot.quantity == 0)
                {
                  sourceSlot.object = nil;
                }
              [self postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];         
              return YES;
            }
        }
    }
  return NO;
}                      

- (BOOL) handleUnpackOperationForItemFromSlot: (DSASlot *) sourceSlot
                                      inModel: (DSACharacter *) sourceModel
                                       toSlot: (DSASlot *) targetSlot
                                      inModel: (DSACharacter *) targetModel
                                mousePosition: (NSPoint) mousePosition
                                       inView: (DSAInventorySlotView *) view
{
  NSLog(@"DSAInventoryManager: handleUnpackOperationForItemFromSlot CALLED!");
  DSAObjectContainer *container = (DSAObjectContainer *)sourceSlot.object;
  NSLog(@"handleUnpackOperationForItemFromSlot: view's window is first responder? %@", ([[view window] firstResponder] == view) ? @"YES" : @"NO");
  [[view window] makeFirstResponder:view];
  NSLog(@"handleUnpackOperationForItemFromSlot: view's window is first responder? %@", ([[view window] firstResponder] == view) ? @"YES" : @"NO");
  
  self.itemActionMenu = [[NSMenu alloc] initWithTitle: @""];
  NSLog(@"setting delegate to VIEW: %@", view);
  [self.itemActionMenu setDelegate:self];
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.paragraphSpacingBefore = 0.0; // Small top padding
  paragraphStyle.paragraphSpacing = 0.0;      // Small bottom padding

  NSDictionary *attrs = @{ NSParagraphStyleAttributeName: paragraphStyle, 
                                     NSFontAttributeName: [NSFont systemFontOfSize: [NSFont systemFontSize]]};  
  //[self.itemActionMenu setAutoenablesItems: NO];
  NSAttributedString *title = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%@ mit Inhalt bewegen", container.name]
                                                              attributes: attrs];
  NSMenuItem *moveEverythingItem = [[NSMenuItem alloc] initWithTitle: @""
                                                              action: @selector(moveWholeContainer:) 
                                                       keyEquivalent: @""];
  [moveEverythingItem setAttributedTitle: title];
  moveEverythingItem.target = self;
  moveEverythingItem.representedObject = @{ @"sourceSlot": sourceSlot,
                                            @"sourceModel": sourceModel,
                                            @"targetSlot": targetSlot,
                                            @"targetModel": targetModel
                                          };
  [self.itemActionMenu addItem: moveEverythingItem];
  for (DSASlot *slot in container.slots)
    {
      if (slot.object != nil)
        {
          NSAttributedString *itemTitle = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%@ auspacken", slot.object.name]
                                                                          attributes: attrs];
          NSMenuItem *takeOutItem = [[NSMenuItem alloc] initWithTitle: @""
                                                               action: @selector(removeItemFromContainer:)
                                                        keyEquivalent: @""];
          [takeOutItem setAttributedTitle: itemTitle];
          takeOutItem.target = self;
          takeOutItem.representedObject = @{ @"sourceSlot": slot,
                                             @"sourceModel": sourceModel,
                                             @"targetSlot": targetSlot,
                                             @"targetModel": targetModel
                                           };
          [self.itemActionMenu addItem:takeOutItem];
        }
      
    }
  NSPoint locationInView = [NSEvent mouseLocation];
  NSPoint locationOnScreen = [view.window.contentView convertPoint:locationInView toView:nil]; // Convert to window coordinates

  [self.itemActionMenu popUpMenuPositioningItem: nil atLocation: locationOnScreen inView: nil];
  return YES;
}


-(void) moveWholeContainer: (NSMenuItem *) sender
{

    NSLog(@"DSAInventoryManager moveWholeContainer called!");
    NSDictionary *info = sender.representedObject;
    DSASlot *sourceSlot = info[@"sourceSlot"];
    DSASlot *targetSlot = info[@"targetSlot"];
    DSACharacter *sourceModel = info[@"sourceModel"];
    DSACharacter *targetModel = info[@"targetModel"];
    
    targetSlot.object = sourceSlot.object;
    targetSlot.quantity = sourceSlot.quantity;

    // Clear source slot
    sourceSlot.object = nil;
    sourceSlot.quantity = 0;
        
    NSLog(@"After updating slots: Source Slot: %@, Quantity: %ld", sourceSlot.object, sourceSlot.quantity);
    NSLog(@"After updating slots: Target Slot: %@, Quantity: %ld", targetSlot.object, targetSlot.quantity);
        
    [self postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];   
    [self.itemActionMenu close]; 
}

- (void) removeItemFromContainer: (NSMenuItem *) sender
{
    NSLog(@"DSAInventoryManager removeItemFromContainer called!");
    NSDictionary *info = sender.representedObject;
    DSASlot *sourceSlot = info[@"sourceSlot"];
    DSASlot *targetSlot = info[@"targetSlot"];
    DSACharacter *sourceModel = info[@"sourceModel"];
    DSACharacter *targetModel = info[@"targetModel"];
    
    targetSlot.object = sourceSlot.object;
    targetSlot.quantity = sourceSlot.quantity;

    // Clear source slot
    sourceSlot.object = nil;
    sourceSlot.quantity = 0;
        
    NSLog(@"After updating slots: Source Slot: %@, Quantity: %ld", sourceSlot.object, sourceSlot.quantity);
    NSLog(@"After updating slots: Target Slot: %@, Quantity: %ld", targetSlot.object, targetSlot.quantity);
        
    [self postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];
    [self.itemActionMenu close];
}

- (NSInteger)equipCharacter:(DSACharacter *)character withObject:(DSAObject *)object ofQuantity:(NSInteger)quantity toBodyPart:(NSString *)bodyPart slotType:(DSASlotType)slotType {

    DSAInventory *inventory = [character.bodyParts inventoryForBodyPart:bodyPart];
    if (!inventory) {
        NSLog(@"Invalid body part: %@", bodyPart);
        return 0;
    }
    
    NSInteger equippedCount = 0;
    
    // Sort slots by slot type and ensure preferred slots come first
    NSArray *sortedSlots = [inventory.slots sortedArrayUsingComparator:^NSComparisonResult(DSASlot *slot1, DSASlot *slot2) {
        if (slot1.slotType == slotType && slot2.slotType != slotType) {
            return NSOrderedAscending;
        } else if (slot1.slotType != slotType && slot2.slotType == slotType) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    for (DSASlot *slot in sortedSlots) {
        if (slot.slotType == slotType) {
            // Use the existing compatibility check
            if (![self isItem:object compatibleWithSlot:slot]) {
                continue; // Skip incompatible slots
            }
            
            // Check if the slot is available (either empty or already occupied with the same object)
            NSInteger availableQuantity = slot.maxItemsPerSlot - slot.quantity;
            if (slot.object == nil || [slot.object isEqual:object]) {
                NSInteger toEquip = MIN(quantity - equippedCount, availableQuantity);
                
                if (toEquip > 0) {
                    slot.object = object; // Assign the object to the slot
                    slot.quantity += toEquip; // Increase the quantity of the object in this slot
                    equippedCount += toEquip; // Track how many were successfully equipped
                    
                    if (equippedCount == quantity) {
                        break; // Stop once the requested quantity is fully equipped
                    }
                }
            }
        }
    }
    
    return equippedCount; // Return the number of successfully equipped objects
}

// Implement all the NSMenuDelegate methods:
- (void)menuWillOpen:(NSMenu *)menu {
    // Called just before the menu opens.  You can do any setup here.
    NSLog(@"Menu will open");
}

- (void)menuDidClose:(NSMenu *)menu {
    // Called after the menu closes.  You can perform cleanup or other actions.
    NSLog(@"Menu did close");
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {
    // Called when a menu item is highlighted.
    if (item != nil) { // Check if an item is highlighted (could be nil if nothing is highlighted)
        NSLog(@"Menu item highlighted: %@", item.title);

/*        //You can now check, if the item is the one you are interested in, and call the respective method.
        if ([item.title isEqualToString:@"Move everything"]) {
            [self moveWholeContainer:item];
        } else if ([item.title hasSuffix:@"auspacken"]) {
            [self removeItemFromContainer:item];
        } */
    }
}

- (NSRect)confinementRectForMenu:(NSMenu *)menu onScreen:(NSScreen *)screen {
    // screen is an NSScreen object

    // Option 1: Confine to the screen's visible frame (excluding Dock, menu bar, etc.)
    //NSRect screenRect = [screen visibleFrame];

    // Option 2: Confine to the entire screen bounds.
    NSRect screenRect = [screen frame];

    // Option 3: Return NSZeroRect to allow the menu to appear at the mouse location
    return NSZeroRect;

    // Or define a specific rect
    //NSRect confinementRect = NSMakeRect(100, 100, 200, 200);
    //return confinementRect;

    return screenRect;
}
// End of NSMenuDelegate


- (void) postDSAInventoryChangedNotificationForSourceModel: (DSACharacter *) sourceModel targetModel: (DSACharacter *)targetModel
{
    if (sourceModel == nil && targetModel == nil)
      {
        return;
      }
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
                NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: forModel: Multi-slot item can be dropped into empty general inventory slot.");
                return YES;
            } else {
                if ([slot.object isKindOfClass: [DSAObjectContainer class]])
                  {
                    if (slot.object == item)  // can't drag a container into itself ;)
                      {
                        return NO;
                      }
                    NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: forModel: Multi-slot might be dropped into DSAObjectContainer, or not ;).");
                    return [self isItem: item compatibleWithSlot: slot];
                  }
                NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: forModel: Multi-slot item can not be dropped into occupied general inventory slot.");
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

    NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: forModel: going to check for single-slot item...");
    return [self isItem: item compatibleWithSlot: slot];
}


- (BOOL) canUseItem: (DSAObject *) item withItemInSlot: (DSASlot *)slot
{
    if (slot.object != nil && (
        [[slot.object.useWith allKeys] containsObject: item.name] || 
        [[slot.object.useWith allKeys] containsObject: item.category] ||
        [[slot.object.useWith allKeys] containsObject: item.subCategory] ||
        [[slot.object.useWith allKeys] containsObject: item.subSubCategory] ))
      {
        return YES;
      }
    return NO;
}


- (BOOL)isItem:(DSAObject *)item compatibleWithSlot:(DSASlot *)slot {
    if (slot.object != nil && slot.object == item)  // shall not be able to drop onto myself
      {
        return NO;
      }
    if ([self canUseItem: item withItemInSlot: slot])
      {
        NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: Items can be used with each other");
        return YES; // these items can be uses with each other
      }
    // Check if the slot's type is valid for the item
    if (![item.validSlotTypes containsObject:@(slot.slotType)]) {
        NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: Item type is incompatible with slot type.");
        return NO;
    }

    // If the slot is empty, it's compatible
    if (slot.object == nil) 
      {
        NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: destination slot is empty.");
        return YES;
      }

    
    // If the item cannot share a slot and the slot is already occupied, it's incompatible
    if (!item.canShareSlot && ![slot.object isCompatibleWithObject:item]) {
        NSLog(@"DSAInventoryManager isItem: compatibleWithSlot: Item cannot share slot and the slot is already occupied.");
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

- (BOOL) replaceItem: (DSAObject *) oldItem
             inModel: (DSACharacter *) model
            withItem: (DSAObject *) newItem
{

    DSAInventory *inventory = model.inventory;
    
    for (DSASlot *slot in inventory.slots) {
        // Check if the slot contains an object and if its name matches
        DSAObject *slotObject = slot.object;
        if (slotObject && [slotObject isEqualTo:oldItem]) { // Object found
            slot.object = nil;
            slot.object = newItem;
            if (newItem == nil)
              {
                slot.quantity = 0;
              }
            [self postDSAInventoryChangedNotificationForSourceModel:model targetModel: model];
            return YES;
        }

        // If the object is a container, recursively search inside it
        if ([slotObject isKindOfClass:[DSAObjectContainer class]]) {
            DSAObjectContainer *container = (DSAObjectContainer *) slotObject;
            DSASlot *foundSlot = [self findSlotHoldingItem:oldItem inContainer: container]; 
            if (foundSlot) {
              slot.object = nil;
              slot.object = newItem;
              [self postDSAInventoryChangedNotificationForSourceModel:model targetModel:model];
              return YES;
            }
        }
    }
    return NO; // didn't find the old item
}            

- (DSASlot *) findSlotHoldingItem: (DSAObject *) item
                      inContainer: (DSAObjectContainer *) container
{
    for (DSASlot *slot in container.slots) {
        // Check if the slot contains an object and if it matches
        DSAObject *object = slot.object;
        if (object && [object isEqualTo:item]) {
            return slot; // Object found
        }

        // If the object is a container, recursively search inside it
        if ([object isKindOfClass:[DSAObjectContainer class]]) {
            DSAObjectContainer *container = (DSAObjectContainer *)object;
            DSASlot *foundSlot = [self findSlotHoldingItem: item inContainer: container]; 
            if (foundSlot) {
                return foundSlot; // Object found within container
            }
        }
    }
    return nil; // Return nil if not found  
}

- (DSAObject *)findObjectWithName: (NSString *) name inInventory: (DSAInventory *) inventory {
    for (DSASlot *slot in inventory.slots) {
        // Check if the slot contains an object and if its name matches
        DSAObject *object = slot.object;
        if (object && [object.name isEqualToString:name]) {
            return object; // Object found
        }

        // If the object is a container, recursively search inside it
        if ([object isKindOfClass:[DSAObjectContainer class]]) {
            DSAObjectContainer *container = (DSAObjectContainer *)object;
            DSAObject *foundObject = [self findObjectWithName:name inContainer:container]; 
            if (foundObject) {
                return foundObject; // Object found within container
            }
        }
    }
    return nil; // Return nil if not found
}

- (DSAObject *)findObjectWithName: (NSString *) name 
                      inContainer: (DSAObjectContainer *) container
{
    for (DSASlot *slot in container.slots) {
        // Check if the slot contains an object and if its name matches
        DSAObject *object = slot.object;
        if (object && [object.name isEqualToString:name]) {
            return object; // Object found
        }

        // If the object is a container, recursively search inside it
        if ([object isKindOfClass:[DSAObjectContainer class]]) {
            DSAObjectContainer *container = (DSAObjectContainer *)object;
            DSAObject *foundObject = [self findObjectWithName:name inContainer:container]; 
            if (foundObject) {
                return foundObject; // Object found within container
            }
        }
    }
    return nil; // Return nil if not found
}

- (DSAObject *) findObjectWithName:(NSString *)name inBodyParts:(DSABodyParts *)bodyParts
{
    // Iterate through body parts inventories
    for (NSString *propertyName in bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [bodyParts valueForKey:propertyName];
        DSAObject *foundObject = [self findObjectWithName: name inInventory: inventory];
        if (foundObject) {
            return foundObject; // Object found in body parts inventory
        }
    }
    return nil; // Return nil if not found
}

- (DSAObject *) findItemWithName:(NSString *) name 
                         inModel: (DSACharacter *) model
{
    // Search in general inventory
    DSAObject *foundObject = [self findObjectWithName:name inInventory: model.inventory];
    if (foundObject) {
        return foundObject; // Object found in general inventory
    }

    // Search in body parts
    return [self findObjectWithName:name inBodyParts: model.bodyParts];
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

- (BOOL) isSlotWithID: (NSString *) slotID inModel: (DSACharacter *) model
{
  for (DSASlot *slot in model.inventory.slots)
    {
      if ([[slot.slotID UUIDString] isEqualToString: slotID])
        {
          return YES;
        }
    }
  for (NSString *propertyName in model.bodyParts.inventoryPropertyNames)
    {
      DSAInventory *inventory = [model.bodyParts valueForKey:propertyName];
      for (DSASlot *slot in inventory.slots)
        {
          // Check if the slot matches the type and is empty
          if ([[slot.slotID UUIDString] isEqualToString: slotID])
            {
              return YES;
            }
        }
    }
  return NO;
}

@end
