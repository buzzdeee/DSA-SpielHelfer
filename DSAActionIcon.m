/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-14 22:30:10 +0100 by sebastia

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

#import "DSAActionIcon.h"
#import "DSACharacter.h"
#import "DSAInventoryManager.h"
#import "Utils.h"
#import "DSATalent.h"
#import "DSAAdventure.h"
#import "DSAAdventureDocument.h"
#import "DSAAdventureWindowController.h"
#import "DSAAdventureGroup.h"
#import "DSACharacterSelectionWindowController.h"

@implementation DSAActionIcon

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set up any initial properties or behaviors for the action icons
        _clickOnlyMode = NO;

    }
    return self;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"DSAActionIcon clicked: %@", self.actionType);

    if ([self.actionType isEqualToString:@"addCharacter"]) {
        [self handleAddCharacter];
    } else if ([self.actionType isEqualToString:@"removeCharacter"]) {
        [self handleRemoveCharacter];
/*    } else if ([self.actionType isEqualToString:@"splitGroup"]) {
        [self handleSplitGroup];
    } else if ([self.actionType isEqualToString:@"mergeGroup"]) {
        [self handleMergeGroup];
    } else if ([self.actionType isEqualToString:@"speak"]) {
        [self handleSpeak];
    } else if ([self.actionType isEqualToString:@"leaveLocation"]) {
        [self handleLeaveLocation]; */
    } else {
        NSLog(@"Unhandled action: %@", self.actionType);
    }
}

// This method will be called when the dragged item enters the area of this icon
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if (self.clickOnlyMode) return NSDragOperationNone;
    NSLog(@"DSAActionIcon: draggingEntered");

    // Get the pasteboard content (dragged item info)
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *draggedItemID = [pasteboard stringForType:NSStringPboardType];

    if (draggedItemID == nil) {
        NSLog(@"No valid draggedItemID found on pasteboard");
        return NSDragOperationNone;
    }

    // Parse the dragged item ID (UUID:inventoryIdentifier:slotIndex)
    NSArray *components = [draggedItemID componentsSeparatedByString:@":"];
    if (components.count == 3) {
        NSUUID *sourceModelID = [[NSUUID alloc] initWithUUIDString: components[0]];
        NSString *sourceInventory = components[1];
        NSInteger sourceSlotIndex = [components[2] integerValue];

        // Retrieve the source model using the modelID
        DSACharacter *sourceModel = [DSACharacter characterWithModelID:sourceModelID];
        if (!sourceModel) {
            NSLog(@"Source model not found for modelID: %@", sourceModelID);
            return NSDragOperationNone;
        }

        // Retrieve the dragged item from the source model's inventory
        DSAObject *draggedItem = [[DSAInventoryManager sharedManager] findItemInModel:sourceModel
                                                                   inventoryIdentifier:sourceInventory
                                                                              slotIndex:sourceSlotIndex];
        if (!draggedItem) {
            NSLog(@"Dragged item not found in source model's inventory");
            return NSDragOperationNone;
        }

        // Only allow the drag if the item can be used with the action type
        if ([self.actionType isEqualToString:@"eye"] || [self.actionType isEqualToString:@"mouth"] || [self.actionType isEqualToString:@"trash"]) {
            return NSDragOperationMove;  // Allow the drag to be copied here
        }
    }

    return NSDragOperationNone;  // Reject drag if the item is not compatible
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"DSAActionIcon: prepareForDragOperation");
    return YES;  // Allow the operation to proceed
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    // Get the pasteboard content
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *draggedItemID = [pasteboard stringForType:NSStringPboardType];
    
    if (draggedItemID == nil) {
        NSLog(@"No valid draggedItemID found on pasteboard");
        return NO;
    }

    // Parse the dragged item ID (UUID:inventoryIdentifier:slotIndex)
    NSArray *components = [draggedItemID componentsSeparatedByString:@":"];
    if (components.count == 3) {
        NSUUID *sourceModelID = [[NSUUID alloc] initWithUUIDString: components[0]];
        NSString *sourceInventory = components[1];
        NSInteger sourceSlotIndex = [components[2] integerValue];

        // Retrieve the source model using the modelID
        DSACharacter *sourceModel = [DSACharacter characterWithModelID:sourceModelID];
        if (!sourceModel) {
            NSLog(@"Source model not found for modelID: %@", sourceModelID);
            return NO;
        }
        
        // Retrieve the dragged item from the source model's inventory
        DSAObject *draggedItem = [[DSAInventoryManager sharedManager] findItemInModel:sourceModel
                                                                  inventoryIdentifier:sourceInventory
                                                                            slotIndex:sourceSlotIndex];
        
        if (!draggedItem) {
            NSLog(@"Dragged item not found in source model's inventory");
            return NO;
        }

        // Perform actions based on the action type (eye, mouth, or trash)
        if ([self.actionType isEqualToString:@"eye"]) {
            // Action for the eye: show item info
            [self showPopupForItem:draggedItem];
            return YES;
        } else if ([self.actionType isEqualToString:@"mouth"]) {
            // Action for the mouth: consume item
            [self consumeItem: draggedItem
                    fromModel: sourceModel
          inventoryIdentifier: sourceInventory
                    slotIndex: sourceSlotIndex];
            return YES;
        } else if ([self.actionType isEqualToString:@"trash"]) {
            // Action for trash: ask to discard the item
            [self askToDiscardItem:draggedItem 
                         fromModel:sourceModel 
               inventoryIdentifier:sourceInventory 
                         slotIndex:sourceSlotIndex];
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Action Handlers

- (void)handleAddCharacter {
    NSWindowController *windowController = self.window.windowController;
    DSAAdventureDocument * adventureDoc = (DSAAdventureDocument *)windowController.document;
    [adventureDoc addCharacterFromFile];
    // [[DSACharacterManager sharedManager] presentCharacterCreationDialog];
}


- (void)handleRemoveCharacter {
    NSLog(@"DSAActionIcon handleRemoveCharacter called");
    // Step 1: Get access to the model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *group = adventure.activeGroup;

    if (group.partyMembers.count == 0) {
        NSBeep();
        NSLog(@"No characters in the group to remove.");
        return;
    }

    // Step 2: Present the character selection sheet
    DSACharacterSelectionWindowController *selector =
        [[DSACharacterSelectionWindowController alloc] initWithWindowNibName:@"DSACharacterSelectionWindow"];
    
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    for (NSUUID *uuid in group.partyMembers)
      {
        DSACharacter *character = [DSACharacter characterWithModelID: uuid];
        NSLog(@"DSAActionIcon handleRemoveCharacter: Added character %@ for modelID: %@", character.name, character.modelID);
        [characters addObject:[DSACharacter characterWithModelID: uuid]];
      }
        
    selector.characters = characters;
    
    //__weak typeof(self) weakSelf = self;
    selector.completionHandler = ^(DSACharacter *selectedCharacter) {
        if (selectedCharacter) {
            NSLog(@"Removing character: %@", selectedCharacter.name);
            [adventure removeCharacterFromActiveGroup:selectedCharacter.modelID];
            [document removeCharacterDocumentForCharacter:selectedCharacter];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
/*            [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGroupChangedNotification"
                                                                object:group
                                                              userInfo:@{@"removedCharacter": selectedCharacter}]; */
        }
    };

    [windowController.window beginSheet:selector.window completionHandler:nil];
}
/*
- (void)handleRemoveCharacter {
    NSWindowController *windowController = self.window.windowController;
    DSAAdventureDocument * adventureDoc = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = adventureDoc.model;
    
    [adventure removeCharacter];
    
    [adventureDoc addCharacterFromFile];
    // [[DSACharacterManager sharedManager] removeSelectedCharacter];
}
*/

/*
- (void)handleSplitGroup {
    [[DSAGroupManager sharedManager] splitCurrentGroup];
}

- (void)handleMergeGroup {
    [[DSAGroupManager sharedManager] mergeAllGroups];
}

- (void)handleSpeak {
    [[DSAInteractionManager sharedManager] presentDialogueUI];
}

- (void)handleLeaveLocation {
    [[DSALocationManager sharedManager] moveCharacterOutOfLocation];
}
*/

// Show a short popup with information about the item
- (void)showPopupForItem:(id)item {
    NSLog(@"Showing info for item: %@", item);
    if (!self.inspectionController) {
        // Lazily initialize the controller if it doesn't already exist
        self.inspectionController = [[DSAItemInspectionController alloc] initWithWindowNibName:@"DSAItemInspection"];
        self.inspectionController.delegate = self;
    }
    [self.inspectionController inspectItem:item];
}

// Consume the item (e.g., eating or using the item)
- (void)consumeItem: (DSAObject *)item
          fromModel: (DSACharacter *)sourceModel
inventoryIdentifier: (NSString *)sourceInventory
          slotIndex: (NSInteger)sourceSlotIndex
{
    // Implement logic to consume the item
    NSLog(@"DSAActionItem: Consuming item: %@", item);
    DSASlot *slot = [[DSAInventoryManager sharedManager] findSlotInModel: sourceModel
                                                 withInventoryIdentifier: sourceInventory
                                                                 atIndex: sourceSlotIndex];
    if (slot == nil)  // slot not found, odd???
      {
        return;
      }
    BOOL result = [sourceModel consumeItem: item];
    if (result == YES)
      {
        slot.quantity -= 1;
        if (slot.quantity == 0)
          {
            slot.object = nil;
          }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAInventoryChangedNotification"
                                                            object:sourceModel
                                                          userInfo:@{@"sourceModel": sourceModel}];
      }
}

- (void)askToDiscardItem:(DSAObject *)item 
               fromModel:(DSACharacter *)sourceModel 
     inventoryIdentifier:(NSString *)sourceInventory 
               slotIndex:(NSInteger)sourceSlotIndex {
    // Show a confirmation dialog to confirm the action
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:_(@"Bist du sicher das du das wegwerfen willst?")];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert addButtonWithTitle:_(@"Behalten")];
    [alert addButtonWithTitle:_(@"Wegwerfen")];

    // Set the informative text with the item's name
    [alert setInformativeText:item.name];

    if ([alert runModal] == NSAlertSecondButtonReturn) { // "Wegwerfen" clicked
        NSLog(@"Throwing away item: %@", item);

        // Perform inventory cleanup
        BOOL success = [[DSAInventoryManager sharedManager] 
                        cleanUpSourceSlotsForItem:item
                                         inModel:sourceModel
                         sourceInventoryIdentifier:sourceInventory
                                   sourceSlotIndex:sourceSlotIndex];
        if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAInventoryChangedNotification"
                                                            object:sourceModel
                                                          userInfo:@{@"sourceModel": sourceModel}];        
            NSLog(@"Item successfully discarded from inventory.");
        } else {
            NSLog(@"Failed to discard item from inventory.");
        }
    } else {
        NSLog(@"Item was kept.");
    }
}

- (void)itemInspectionControllerDidClose:(DSAItemInspectionController *)controller {
    NSLog(@"Inspection window closed for controller: %@", controller);
    [[self.inspectionController window] close];
    // self.inspectionController = nil; // Release the reference, this is causing the whole DSACharacterWindow to disappear :(
}
@end