/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-04 21:57:37 +0100 by sebastia

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

#import "DSAInventorySlotView.h"
#import "DSAInventoryManager.h"

@implementation DSAInventorySlotView

- (void)mouseDown:(NSEvent *)theEvent {
NSLog(@"DSAInventorySlotView mouseDown called!!!!");
    if ([self initiatesDrag]) {
        NSLog(@"DSAInventorySlotView: mouseDown initiating Drag");

        DSAObject *draggedItem = self.item;
        NSLog(@"The dragged item: %@", draggedItem);
        if (draggedItem != nil) {
            // Create the pasteboard
            NSLog(@"DSAInventorySlotView: mouseDown dragged item is not nil!");
            NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];

            // Create a unique identifier for the dragged item, including modelID, inventory, and slot index
            NSString *draggedItemID = [NSString stringWithFormat:@"%@:%@:%ld", [self.model.modelID UUIDString], self.inventoryIdentifier, self.slotIndex];

            // Store necessary information on the pasteboard
            [pasteboard declareTypes:@[NSStringPboardType] owner:self];
            [pasteboard setString:draggedItemID forType:NSStringPboardType];

            NSLog(@"DSAInventorySlotView: mouseDown dragging data: %@, inventory: %@, slot: %ld",
                  [self.model.modelID UUIDString], self.inventoryIdentifier, (long)self.slotIndex);

            NSLog(@"mouseDown: Pasteboard contains %@", [pasteboard stringForType:NSStringPboardType]);
            // Start the drag
            NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil]; // Convert mouse location to the view's coordinate system
            NSSize imageSize = self.image.size;
            
            // Offset to place the image below the mouse (and a little to the left)
            NSSize offset = NSMakeSize(-imageSize.width / 2, imageSize.height / 2);

            [self dragImage:self.image
                         at:p
                     offset:offset
                      event:theEvent
                 pasteboard:pasteboard
                     source:self
                  slideBack:YES];

            NSLog(@"DSAInventorySlotView: mouseDown finished initiating drag");
        } else {
            NSLog(@"DSAInventorySlotView: mouseDown but no item to drag");
        }
    }
}

- (void)setImage:(NSImage *)image {
    // Check if the slot is empty and set the placeholder image
    if (!self.slot.object) {
        image = [self placeholderImageForSlotType:self.slot.slotType];
    }

    // Call the superclass method directly to update the view
    [super setImage:image];
    
    // Mark the view for redrawing
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    NSLog(@"DSAInventorySlotView: draggingSourceOperationMaskForLocal: %@", isLocal ? @"YES" : @"NO");

    // If the drag is within the same app, return NSDragOperationMove
    if (isLocal) {
        return NSDragOperationMove; // Move is typical for inventory management
    }

    // If the drag is external (e.g., to another app), allow Copy
    return NSDragOperationCopy;
}
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSLog(@"DSAInventorySlotView: draggingEntered");

    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *draggedItemID = [pasteboard stringForType:NSStringPboardType];
    
    if (draggedItemID == nil) {
        NSLog(@"draggingEntered: Pasteboard contains no valid draggedItemID");
        return NSDragOperationNone;
    }
    
    NSLog(@"draggingEntered: draggedItemID %@", draggedItemID);

    // Parse draggedItemID into components
    NSArray *components = [draggedItemID componentsSeparatedByString:@":"];
    if (components.count == 3) {
        NSUUID *sourceModelID = [[NSUUID alloc] initWithUUIDString: components[0]];
        NSString *sourceInventory = components[1];
        NSInteger sourceSlotIndex = [components[2] integerValue];

        // Validate dragged item
        DSACharacter *sourceModel = [DSACharacter characterWithModelID:sourceModelID];
        if (!sourceModel) {
            NSLog(@"draggingEntered: Source model not found");
            return NSDragOperationNone;
        }
        
        DSAObject *draggedItem = [[DSAInventoryManager sharedManager] findItemInModel:sourceModel
                                                                   inventoryIdentifier:sourceInventory
                                                                              slotIndex:sourceSlotIndex];
        if (!draggedItem) {
            NSLog(@"draggingEntered: No dragged item found");
            return NSDragOperationNone;
        }

        NSLog(@"draggingEntered: Found draggedItem: %@", draggedItem);

        // Check compatibility based on multi-slot or single-slot item
        if (draggedItem.occupiedBodySlots && draggedItem.occupiedBodySlots.count > 0) {
            // Multi-slot item logic
            if ([draggedItem.occupiedBodySlots containsObject:@(self.slot.slotType)]) {
                if ([[DSAInventoryManager sharedManager] isItem:draggedItem compatibleWithSlot:self.slot forModel:sourceModel]) {
                    [self highlightTargetView:YES];
                    NSLog(@"draggingEntered: Multi-slot item drag is valid for this slot");
                    return NSDragOperationMove;
                } else {
                    NSLog(@"draggingEntered: Multi-slot item slot is incompatible");
                }
            } else {
                NSLog(@"draggingEntered: Slot type %@ not listed in occupiedBodySlots: %@",
                      @(self.slot.slotType), draggedItem.occupiedBodySlots);
            }
        }
        
        if (draggedItem.validSlotTypes && draggedItem.validSlotTypes.count > 0) {
            // Single-slot item logic
            NSLog(@"DSAInventorySlotView draggingEntered: checking single slot item logic ");
            if ([draggedItem.validSlotTypes containsObject:@(self.slot.slotType)]) {
                NSLog(@"DSAInventorySlotView draggingEntered: draggedItem validSlotTypes: %@ self.slot.slotType: %@", draggedItem.validSlotTypes,  @(self.slot.slotType));
                if ([[DSAInventoryManager sharedManager] isItem:draggedItem compatibleWithSlot:self.slot forModel:sourceModel]) {
                    [self highlightTargetView:YES];
                    NSLog(@"draggingEntered: Single-slot item drag is valid for this slot");
                    return NSDragOperationMove;
                } else {
                    NSLog(@"draggingEntered: Single-slot item slot is incompatible");
                }
            } else {
                NSLog(@"draggingEntered: Slot type %@ not listed in validSlotTypes: %@",
                      @(self.slot.slotType), draggedItem.validSlotTypes);
            }
        }
    } else {
        NSLog(@"draggingEntered: Invalid draggedItemID format");
    }

    // Default to not allowing the drop
    [self highlightTargetView:NO];
    return NSDragOperationNone;
}

- (BOOL)canAcceptDraggedItem:(DSAObject *)draggedItem withQuantity:(NSInteger)draggedQuantity {
    if (self.slot.object != nil && (
        [[self.slot.object.useWith allKeys] containsObject: draggedItem.name] ||
        [[self.slot.object.useWith allKeys] containsObject: draggedItem.category] ||
        [[self.slot.object.useWith allKeys] containsObject: draggedItem.subCategory] ||
        [[self.slot.object.useWith allKeys] containsObject: draggedItem.subSubCategory]))
      {
        return YES; // these items can be uses with each other
      }
    // Check if the slot type is valid for the dragged item
    if (![draggedItem.validSlotTypes containsObject:@(self.slot.slotType)]) {
        return NO; // Slot type mismatch
    }

    if (self.slot.object == nil) {
        // Slot is empty; accept the item
        return YES;
    }

    if (!draggedItem.canShareSlot || !self.slot.object.canShareSlot) {
        // Slot or dragged item cannot share slots
        return NO;
    }

    if (self.slot.object == draggedItem) {
        // Same item type, check max capacity
        return (self.slot.quantity + draggedQuantity <= self.slot.maxItemsPerSlot);
    }

    // Different item type, cannot share the slot
    return NO;
}


- (void)draggingExited:(id<NSDraggingInfo>)sender {
    NSLog(@"DSAInventorySlotView: draggingExited for slot %@", @(self.slotIndex));
    [self highlightTargetView:NO];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"DSAInventorySlotView: prepareForDragOperation");
    return YES;  // Allow the operation to proceed
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"DSAInventorySlotView: performDragOperation");

    // Get the pasteboard content
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *draggedItemID = [pasteboard stringForType:NSStringPboardType];

    // Parse draggedItemID into inventoryIdentifier and slotIndex
    NSArray *components = [draggedItemID componentsSeparatedByString:@":"];
    if (components.count == 3) { // modelID:inventoryIdentifier:slotIndex
        NSUUID *sourceModelID = [[NSUUID alloc] initWithUUIDString: components[0]];
        NSString *sourceInventory = components[1];
        NSInteger sourceSlotIndex = [components[2] integerValue];

        // Retrieve the source model from the registry
        DSACharacter *sourceModel = [DSACharacter characterWithModelID:sourceModelID];
        if (!sourceModel) {
            NSLog(@"DSAInventorySlotView: Source model not found.");
            return NO;
        }

        // Retrieve the dragged item from the source model's inventory
        DSAObject *draggedItem = [[DSAInventoryManager sharedManager] findItemInModel:sourceModel
                                                                   inventoryIdentifier:sourceInventory
                                                                              slotIndex:sourceSlotIndex];
        if (!draggedItem) {
            NSLog(@"DSAInventorySlotView: No dragged item found.");
            return NO;
        }

        // Multi-slot item logic (from general to body or body to general)
        if (draggedItem.occupiedBodySlots && draggedItem.occupiedBodySlots.count > 0) {
            if (self.slot.slotType == DSASlotTypeGeneral && self.slot.object == nil) {
                // Case: Moving from body slots to general inventory
                NSLog(@"DSAInventorySlotView: Attempting multi-slot transfer to general slot.");

                BOOL success = [[DSAInventoryManager sharedManager]
                transferMultiSlotItem:draggedItem
                             fromModel:sourceModel
                               toModel:self.model
                           toSlotIndex:self.slotIndex
             sourceInventoryIdentifier:sourceInventory
                       sourceSlotIndex:sourceSlotIndex
             targetInventoryIdentifier:self.inventoryIdentifier];
                                                    
                if (success) {
                    NSLog(@"DSAInventorySlotView: Multi-slot transfer to general slot succeeded.");
                    [self highlightTargetView:NO];
                    return YES;
                }
            } else if (self.slot.slotType != DSASlotTypeGeneral && self.slot.object == nil) {
                // Case: Moving from general inventory to body slots
                NSLog(@"DSAInventorySlotView: Attempting multi-slot transfer to body slots.");

                BOOL success = [[DSAInventoryManager sharedManager]
                transferMultiSlotItem:draggedItem
                             fromModel:sourceModel
                               toModel:self.model
                           toSlotIndex:self.slotIndex
             sourceInventoryIdentifier:sourceInventory
                       sourceSlotIndex:sourceSlotIndex
             targetInventoryIdentifier:self.inventoryIdentifier];
                                                                                           
                if (success) {
                    NSLog(@"DSAInventorySlotView: Multi-slot transfer to body slots succeeded.");
                    [self highlightTargetView:NO];
                    return YES;
                }
            }
        }

        // Single-slot item logic
        NSPoint mousePosition = self.frame.origin;

        NSPoint mousePos = [self convertPoint:mousePosition fromView:nil]; // Converted to view coordinates
        
        if ([[DSAInventoryManager sharedManager] isItem:draggedItem compatibleWithSlot:self.slot]) {
            BOOL success = [[DSAInventoryManager sharedManager]
                            transferItemFromSlot:sourceSlotIndex
                                         inInventory:sourceInventory
                                             inModel:sourceModel
                                              toSlot:self.slotIndex
                                             inModel:self.model
                                 inventoryIdentifier:self.inventoryIdentifier
                                       mousePosition: mousePos
                                              inView: self];
            if (success) {
                NSLog(@"DSAInventorySlotView: Single-slot item transfer succeeded.");
                [self highlightTargetView:NO];
                return YES;
            }
        }
    }

    NSLog(@"DSAInventorySlotView: Transfer failed.");
    [self highlightTargetView:NO];
    return NO;
}


- (void)updateSlotUIWithSlot:(DSASlot *)slot inSlotView:(DSAInventorySlotView *)slotView {
    if (slot.object) {
        // Update the slot image
        slotView.image = [[NSImage alloc] initWithContentsOfFile:[self imagePathForObject:slot.object]];
    } else {
        // Clear the slot image if empty
        slotView.image = nil;
    }

    // Update the quantity label
    [self updateQuantityLabelWithQuantity:slot.quantity];
    
}

- (DSAObject *)findItemWithInventoryIdentifier:(NSString *)inventoryIdentifier 
                                      slotIndex:(NSInteger)slotIndex 
                                        inModel:(DSACharacter *)model {
    if ([inventoryIdentifier isEqualToString:@"inventory"]) {
        // Loop through the slots in the general inventory
        DSASlot *slot = [model.inventory.slots objectAtIndex:slotIndex];
        return slot.object;  // Return the item in the correct slot
    }
    else if ([inventoryIdentifier isEqualToString:@"body"]) {
        // Cumulative slot index across all body part inventories
        NSInteger cumulativeIndex = 0;

        for (NSString *propertyName in model.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [model.bodyParts valueForKey:propertyName];

            if (slotIndex < (cumulativeIndex + inventory.slots.count)) {
                // Find the slot within this inventory
                DSASlot *slot = inventory.slots[slotIndex - cumulativeIndex];
                return slot.object;  // Return the item in the correct slot
            }

            // Increment cumulative index by the size of the current inventory
            cumulativeIndex += inventory.slots.count;
        }
    }
    return nil;  // Return nil if no matching item is found
}

- (DSASlot *)findSlotWithInventoryIdentifier:(NSString *)inventoryIdentifier slotIndex:(NSInteger)slotIndex {
    if ([inventoryIdentifier isEqualToString:@"inventory"]) {
        return self.model.inventory.slots[slotIndex];
    } else if ([inventoryIdentifier isEqualToString:@"body"]) {
        for (NSString *propertyName in self.model.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [self.model.bodyParts valueForKey:propertyName];
            if (slotIndex < inventory.slots.count) {
                return inventory.slots[slotIndex];
            }
            slotIndex -= inventory.slots.count; // Adjust slotIndex for the next inventory
        }
    }
    return nil;
}

- (void)highlightTargetView:(BOOL)highlight {
    NSColor *highlightColor = highlight ? [NSColor greenColor] : [NSColor clearColor];

    // Remove existing highlight view if any
    if (self.highlightView) {
        [self.highlightView removeFromSuperview];
        self.highlightView = nil; // Clear the reference
    }

    if (highlight) {
        // Create a new highlight view (NSBox for the border)
        self.highlightView = [[NSBox alloc] initWithFrame:self.bounds];
        self.highlightView.boxType = NSBoxCustom;
        self.highlightView.borderType = NSLineBorder;
        self.highlightView.borderColor = highlightColor;
        self.highlightView.borderWidth = 2.0;
        self.highlightView.fillColor = [NSColor clearColor]; // Transparent fill
        self.highlightView.title = nil; // Remove the title from the NSBox
        self.highlightView.titlePosition = NSNoTitle; // Make sure no title is drawn
        
        [self addSubview:self.highlightView];
    }
}


- (NSString *)imagePathForObject:(DSAObject *)object {
    if (!object) return nil;

    NSString *iconName = object.icon;
    if ([self.inventoryIdentifier isEqualToString:@"inventory"]) {
        iconName = [NSString stringWithFormat:@"%@-64x64", iconName];
    } else if ([self.inventoryIdentifier isEqualToString:@"body"]) {
        iconName = [NSString stringWithFormat:@"%@-32x32", iconName];
    }

    return [[NSBundle mainBundle] pathForResource:iconName ofType:@"webp"];
}

- (void)updateQuantityLabelWithQuantity:(NSInteger)quantity {
    NSTextField *quantityLabel = [self viewWithTag:999];
    if (!quantityLabel) {
        // Create the quantity label if it doesn't exist
        quantityLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(1, 1, 30, 15)];
        quantityLabel.editable = NO;
        quantityLabel.bordered = NO;
        quantityLabel.bezeled = NO;
        quantityLabel.focusRingType = NSFocusRingTypeNone;
        quantityLabel.backgroundColor = [NSColor blackColor];
        quantityLabel.drawsBackground = YES;
        quantityLabel.textColor = [NSColor redColor];
        quantityLabel.font = [NSFont boldSystemFontOfSize:8]; // Smaller font for body slots
        quantityLabel.alignment = NSTextAlignmentLeft;
        quantityLabel.tag = 999; // Unique tag to identify this label
        [self addSubview:quantityLabel];
    }

    if (quantity > 0) {
        // Update the label with the current quantity
        NSString *quantityString = [NSString stringWithFormat:@"%ld", (long)quantity];
        quantityLabel.stringValue = quantityString;
        quantityLabel.hidden = NO;

        // Calculate the size of the text and adjust the label's frame
        NSDictionary *attributes = @{NSFontAttributeName: quantityLabel.font};
        NSSize textSize = [quantityString sizeWithAttributes:attributes];
        quantityLabel.frame = NSMakeRect(1, 1, textSize.width, textSize.height);
    } else {
        // Hide the label if the quantity is 0
        quantityLabel.hidden = YES;
    }
}

- (void)updateToolTip {
    if (self.slot && self.slot.object) {
        // Generate a tooltip based on the item in the slot
        DSAObject *item = self.slot.object;
        NSString *tooltip = [NSString stringWithFormat: @"%@ (%lu)", item.name, self.slot.slotType];

        self.toolTip = tooltip;
    } else {
        // Clear the tooltip if the slot is empty
        self.toolTip = [NSString stringWithFormat: _(@"leer (%lu)"), self.slot.slotType];
    }
}

- (NSImage *)placeholderImageForSlotType:(DSASlotType)slotType {
    NSString *placeholderImageName = nil;

    switch (slotType) {
        case DSASlotTypeGeneral:
            placeholderImageName = @"placeholder_hand-16x16"; // Placeholder for general slots
            break;
        case DSASlotTypeHeadgear:
            placeholderImageName = @"placeholder_head-16x16"; // Placeholder for head slots
            break;            
        case DSASlotTypeEarring:
            placeholderImageName = @"placeholder_ear-16x16"; // Placeholder for head slots
            break;
        case DSASlotTypeNosering:
            placeholderImageName = @"placeholder_nose-16x16"; // Placeholder for head slots
            break;  
        case DSASlotTypeArmRing:
            placeholderImageName = @"placeholder_handgelenk-16x16"; // Placeholder for head slots
            break;                       
        case DSASlotTypeGlasses:
            placeholderImageName = @"placeholder_eyes-16x16"; // Placeholder for body slots
            break;
        case DSASlotTypeMask:
            placeholderImageName = @"placeholder_face-16x16"; // Placeholder for hand slots
            break;
        case DSASlotTypeNecklace:
            placeholderImageName = @"placeholder_neck-16x16"; // Placeholder for hand slots
            break;            
        case DSASlotTypeArmArmor:
            placeholderImageName = @"placeholder_armarmor-16x16"; // Placeholder for hand slots
            break;
        case DSASlotTypeLegArmor:
            placeholderImageName = @"placeholder_legarmor-16x16"; // Placeholder for hand slots
            break;  
        case DSASlotTypeShoes:
            placeholderImageName = @"placeholder_shoes-16x16"; // Placeholder for hand slots
            break;
        case DSASlotTypeSocks:
            placeholderImageName = @"placeholder_socks-16x16"; // Placeholder for hand slots
            break;  
        case DSASlotTypeVest:
            placeholderImageName = @"placeholder_vest-16x16"; // Placeholder for hand slots
            break; 
        case DSASlotTypeJacket:
            placeholderImageName = @"placeholder_jacket-16x16"; // Placeholder for hand slots
            break;
        case DSASlotTypeBackquiver:
            placeholderImageName = @"placeholder_back-16x16"; // Placeholder for hand slots
            break;
        case DSASlotTypeBackpack:
            placeholderImageName = @"placeholder_back-16x16"; // Placeholder for hand slots
            break;  
        case DSASlotTypeRing:
            placeholderImageName = @"placeholder_finger-16x16"; // Placeholder for hand slots
            break;
        case DSASlotTypeGloves:
            placeholderImageName = @"placeholder_handschuh-16x16"; // Placeholder for hand slots
            break; 
        case DSASlotTypeBodyArmor:
            placeholderImageName = @"placeholder_koerperruestung-16x16"; // Placeholder for hand slots
            break;  
        case DSASlotTypeHip:
            placeholderImageName = @"placeholder_huefte-16x16"; // Placeholder for hand slots
            break;            
        case DSASlotTypeSash:
            placeholderImageName = @"placeholder_schaerpe-16x16"; // Placeholder for hand slots
            break;   
        case DSASlotTypeShirt:
            placeholderImageName = @"placeholder_shirt-16x16"; // Placeholder for hand slots
            break; 
        case DSASlotTypeUnderwear:
            placeholderImageName = @"placeholder_unterwaesche-16x16"; // Placeholder for hand slots
            break;     
        case DSASlotTypeTrousers:
            placeholderImageName = @"placeholder_hose-16x16"; // Placeholder for hand slots
            break;                                                                                                                                                               
        default:
            placeholderImageName = @"placeholder_default-16x16"; // Default placeholder
            break;
    }

    // Load the placeholder image
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:placeholderImageName ofType:@"webp"];
    return imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
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
        
    [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];    
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
        
    [[[DSAInventoryManager alloc] init] postDSAInventoryChangedNotificationForSourceModel: sourceModel targetModel: targetModel];
}

@end
