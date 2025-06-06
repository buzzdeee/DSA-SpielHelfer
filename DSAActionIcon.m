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
#import "DSACharacterMultiSelectionWindowController.h"
#import "DSAMapCoordinate.h"
#import "DSALocation.h"
#import "DSALocations.h"

@implementation DSAActionIcon

static NSDictionary<NSString *, Class> *typeToClassMap = nil;

+ (void)initialize {
    if (self == [DSAActionIcon class]) {
        @synchronized(self) {
            if (!typeToClassMap) {
                typeToClassMap = @{
                    _(@"examine"): [DSAActionIconExamine class],
                    _(@"consume"): [DSAActionIconConsume class],                    
                    _(@"dispose"): [DSAActionIconDispose class],
                    _(@"addToGroup"): [DSAActionIconAddToGroup class],
                    _(@"removeFromGroup"): [DSAActionIconRemoveFromGroup class],
                    _(@"splitGroup"): [DSAActionIconSplitGroup class],
                    _(@"joinGroups"): [DSAActionIconJoinGroups class],
                    _(@"switchActiveGroup"): [DSAActionIconSwitchActiveGroup class],                    
                    _(@"leave"): [DSAActionIconLeave class],
                    _(@"chat"): [DSAActionIconChat class],
                    _(@"pray"): [DSAActionIconPray class],
                    _(@"buy"): [DSAActionIconBuy class],
                    _(@"sell"): [DSAActionIconSell class],
                    _(@"map"): [DSAActionIconMap class],                             
                };
            }
        }
    }
}

+ (instancetype)iconWithAction:(NSString *) action andSize: (NSString *)size
{
    Class subclass = [typeToClassMap objectForKey:action];
    NSLog(@"DSAActionIcon: action: %@ returning class: %@", action, [subclass class]);
    if (subclass) {
        NSLog(@"DSAActionIcon: action: %@ returning class: %@", action, [subclass class]);
        return [[subclass alloc] initWithImageSize: size];
    }
    // Handle unknown type
    return nil;
}

- (instancetype)initWithImageSize: (NSString *)size
{
    NSLog(@"DSAActionIcon: subclasses %@ shall override initWithSize!", [self class]);
    return nil;
}

- (BOOL)isActive {
    // default to active, subclasses might override where applicable
    return YES;
}

- (void)updateAppearance {
    BOOL active = [self isActive];
    self.alphaValue = active ? 1.0 : 0.4; // Ausgrauen bei Inaktivität
    self.enabled = active; // falls du NSControl ableitest
}


// To make toolTips show up, otherwise they won't since we replace the view....
- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];

    if (self.toolTip) {
        NSString *tip = self.toolTip;
        self.toolTip = nil;
        self.toolTip = tip;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}
@end
// End of DSAActionIcon

@implementation DSAActionIconDragTarget
// This method will be called when the dragged item enters the area of this icon
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    //NSLog(@"DSAActionIconDragTarget: draggingEntered");
    if (![self isActive]) {
        return NSDragOperationNone;
    }
    // Get the pasteboard content (dragged item info)
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *draggedItemID = [pasteboard stringForType:NSStringPboardType];

    if (draggedItemID == nil) {
        NSLog(@"DSAActionIconDragTarget draggingEntered: No valid draggedItemID found on pasteboard");
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
            NSLog(@"DSAActionIconDragTarget draggingEntered: Source model not found for modelID: %@", sourceModelID);
            return NSDragOperationNone;
        }

        // Retrieve the dragged item from the source model's inventory
        DSAObject *draggedItem = [[DSAInventoryManager sharedManager] findItemInModel:sourceModel
                                                                   inventoryIdentifier:sourceInventory
                                                                              slotIndex:sourceSlotIndex];
        if (!draggedItem) {
            NSLog(@"DSAActionIconDragTarget draggingEntered: Dragged item not found in source model's inventory");
            return NSDragOperationNone;
        }

        return NSDragOperationMove;  // Allow the drag to be copied here
    }
    return NSDragOperationNone;  // Reject drag if the item is not compatible
}
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;  // Allow the operation to proceed
}

@end

@implementation DSAActionIconExamine
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"eye-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Dinge ansehen");
        [self registerForDraggedTypes:@[NSStringPboardType]];
        [self updateAppearance];
    }
    return self;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    // Get the pasteboard content
    if (![self isActive]) {
        return NSDragOperationNone;
    }    
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


        [self showPopupForItem:draggedItem];
        return YES;

    }
    
    return NO;
}

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

- (void)itemInspectionControllerDidClose:(DSAItemInspectionController *)controller {
    NSLog(@"DSAActionIconExamine: Inspection window closed for controller: %@", controller);
    [[self.inspectionController window] close];
    //self.inspectionController = nil; // Release the reference, this is causing the whole DSACharacterWindow to disappear :(
}
@end
// End of DSAActionIconExamine

@implementation DSAActionIconConsume
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"mouth-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Dinge konsumieren");
        [self registerForDraggedTypes:@[NSStringPboardType]];
        [self updateAppearance];
    }
    return self;
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

        [self consumeItem: draggedItem
                fromModel: sourceModel
      inventoryIdentifier: sourceInventory
                slotIndex: sourceSlotIndex];
        return YES;

    }
    
    return NO;
}

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
@end
// End of DSAActionIconConsume

@implementation DSAActionIconDispose
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"trash-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Dinge wegwerfen");
        [self registerForDraggedTypes:@[NSStringPboardType]];
        [self updateAppearance];
    }
    return self;
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

        // Action for trash: ask to discard the item
        [self askToDiscardItem:draggedItem 
                     fromModel:sourceModel 
           inventoryIdentifier:sourceInventory 
                     slotIndex:sourceSlotIndex];
            return YES;
    }
    
    return NO;
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
@end

@implementation DSAActionIconClickTarget
- (void)mouseDown:(NSEvent *)event {
    if (![self isActive]) {
        return; // Ignorieren, wenn inaktiv
    }
    [self handleEvent];
}
- (void)handleEvent {
  NSLog(@"DSAActionIconClickTarget handleEvent: subclasses (%@) are supposed to overwrite", [self class]);
}
@end

@implementation DSAActionIconAddToGroup
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"group_add-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Character in die Gruppe aufnehmen");
        [self updateAppearance];
    }
    return self;
}

- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    NSArray *groups = adventure.groups;    
    NSInteger count = 0;
    for (DSAAdventureGroup *group in groups)
      {
        count += [group.partyMembers count];
      }
    if (count < 6)
      {
        return YES;
      }
    else
      {
        return NO;
      }
}

- (void)handleEvent {
    NSWindowController *windowController = self.window.windowController;
    DSAAdventureDocument * adventureDoc = (DSAAdventureDocument *)windowController.document;
    [adventureDoc addCharacterFromFile];
    // [[DSACharacterManager sharedManager] presentCharacterCreationDialog];
}
@end
// End of DSAActionIconAddToGroup
@implementation DSAActionIconRemoveFromGroup
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"group_remove-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Character entlassen");
        [self updateAppearance];
    }
    return self;
}

- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *group = adventure.activeGroup;    
    if ([group.partyMembers count] > 0)
      {
        return YES;
      }
    else
      {
        return NO;
      }
}

- (void)handleEvent {
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
    
    selector.completionHandler = ^(DSACharacter *selectedCharacter) {
        if (selectedCharacter) {
            NSLog(@"Removing character: %@", selectedCharacter.name);
            [adventure removeCharacterFromActiveGroup:selectedCharacter.modelID];
            [document removeCharacterDocumentForCharacter:selectedCharacter];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
        }
    };

    [windowController.window beginSheet:selector.window completionHandler:nil];
}
@end
// End of DSAActionIconRemoveFromGroup
@implementation DSAActionIconSplitGroup
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"group_split-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Gruppe teilen");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *group = adventure.activeGroup;    
    if ([group.partyMembers count] + [group.npcMembers count] > 1)
      {
        return YES;
      }
    else
      {
        return NO;
      }
}
- (void)handleEvent {
    NSLog(@"DSAActionIconSplitGroup handleEvent called");
    // Step 1: Get access to the model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *group = adventure.activeGroup;

    if ([group.partyMembers count] + [group.npcMembers count] < 2) {
        NSBeep();
        NSLog(@"Not enough characters in the group to split.");
        return;
    }

    // Step 2: Present the character selection sheet
    DSACharacterMultiSelectionWindowController *selector =
        [[DSACharacterMultiSelectionWindowController alloc] initWithWindowNibName:@"DSACharacterMultiSelectionWindow"];
    
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    for (NSUUID *uuid in group.partyMembers)
      {
        DSACharacter *character = [DSACharacter characterWithModelID: uuid];
        NSLog(@"DSAActionIconSplitGroup handleEvent: Added character %@ for modelID: %@", character.name, character.modelID);
        [characters addObject:[DSACharacter characterWithModelID: uuid]];
      }
    for (NSUUID *uuid in group.npcMembers)
      {
        DSACharacter *character = [DSACharacter characterWithModelID: uuid];
        NSLog(@"DSAActionIconSplitGroup handleEvent: Added npc character %@ for modelID: %@", character.name, character.modelID);
        [characters addObject:[DSACharacter characterWithModelID: uuid]];
      }        
    selector.characters = characters;
    
    selector.completionHandler = ^(NSArray *selectedCharacters) {
        if (selectedCharacters) {
            // Create new DSAAdventureGroup without members
            // Copy location
            // copy weather
            DSAAdventureGroup *targetGroup = [[DSAAdventureGroup alloc] initWithPartyMembers: [NSMutableArray array]
                                                                                    position: [adventure.activeGroup.position copy]
                                                                                     weather: [adventure.activeGroup.weather copy]];
            [adventure.groups addObject: targetGroup];
            for (DSACharacter *character in selectedCharacters)
              {
                NSLog(@"DSAActionIconSplitGroup handleEvent completionHandler: moving character: %@", character.name);
                [adventure moveCharacter:character.modelID toGroup: targetGroup];
              }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
        }
    };

    [windowController.window beginSheet:selector.window completionHandler:nil];
}
@end

@implementation DSAActionIconJoinGroups
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"group_join-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Gruppen vereinen");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *activeGroupPosition = activeGroup.position;
    
    //NSLog(@"DSAActionIconJoinGroups isActive activeGroup location: %@", activeGroupLocation);
    
    for (DSAAdventureGroup *group in adventure.groups)
      {
        if ([activeGroup isEqualTo: group])
          {
            NSLog(@"DSAActionIconJoinGroups isActive compared against active Group, continuing");
            continue;
          }
        NSLog(@"DSAActionIconJoinGroups isActive comparing aginst some other group");
        if ([activeGroupPosition isEqual: group.position])
           {
              return YES;
           }
      }
    return NO;
}
- (void)handleEvent {
    NSLog(@"DSAActionIconJoinGroup handleEvent called");
    // Step 1: Get access to the model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *activeGroupPosition = activeGroup.position;
    DSAAdventureGroup *otherGroup;
    
    NSInteger groupIndex = 0;
    for (DSAAdventureGroup *group in adventure.groups)
      {
        if ([activeGroup isEqualTo: group])
          {
            groupIndex++;
            continue;
          }
        if ([activeGroupPosition isEqual: group.position])
           {

              otherGroup = group;
              break;
           }
         groupIndex++;
      }    

    NSLog(@"DSAActionIconJoinGroup handleEvent active group: %@ members: %ld", activeGroup, [activeGroup.partyMembers count]);
    NSLog(@"DSAActionIconJoinGroup handleEvent other group: %@ members: %ld", otherGroup, [otherGroup.partyMembers count]);
    if (otherGroup)
      {
        NSLog(@"SAActionIconJoinGroup handleEvent active group UUIDs: %@", activeGroup.partyMembers);
        NSLog(@"SAActionIconJoinGroup handleEvent other group UUIDs: %@", otherGroup.partyMembers);
        for (NSUUID *uuid in otherGroup.partyMembers)
          {
            NSLog(@"DSAActionIconJoinGroup handleEvent other group adding character UUID to activeGroup: %@", uuid);
            [adventure addCharacterToActiveGroup: uuid];
            NSLog(@"DSAActionIconJoinGroup handleEvent other group AFTER adding character UUID to activeGroup: %@", uuid);
          }
        NSLog(@"DSAActionIconJoinGroup handleEvent adventure groups count: %ld removing group at index: %ld", [adventure.groups count], groupIndex); 
        [adventure.groups removeObjectAtIndex: groupIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
      }
    NSLog(@"DSAActionIconJoinGroup handleEvent active group: %@ members: %ld", activeGroup, [activeGroup.partyMembers count]);
    NSLog(@"DSAActionIconJoinGroup handleEvent adventure groups count: %ld", [adventure.groups count]);      
}
@end
// End of DSAActionIconJoinGroups

@implementation DSAActionIconSwitchActiveGroup
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"group_next-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Gruppe wechseln");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    
    //NSLog(@"DSAActionIconJoinGroups isActive activeGroup location: %@", activeGroupLocation);
    if ([adventure.groups count] > 1)
      {
        return YES;
      }
    return NO;
}
- (void)handleEvent {
    NSLog(@"DSAActionIconSwitchactiveGroup handleEvent called");
    // Step 1: Get access to the model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    
    if ([adventure.groups count] > 1) {
        DSAAdventureGroup *firstGroup = adventure.groups[0];
        [adventure.groups removeObjectAtIndex:0];
        [adventure.groups addObject:firstGroup];
    }    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];     
}
@end
@implementation DSAActionIconLeave
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"leave-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Gebäude verlassen");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
        
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        if ([currentTile isKindOfClass: [DSALocalMapTileBuilding class]])
          {
            return YES;
          }
      }
    return NO;
}

- (void)handleEvent {
    NSLog(@"DSAActionIconLeave handleEvent called");
    // Step 1: Get access to the model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
    
    DSALocalMapTile *currentTile = [currentLocation tileAtCoordinate: currentPosition.mapCoordinate];
    
    NSLog(@"DSAActionIconLeave handleEvent currentTile: %@", currentTile);
    if ([currentTile isKindOfClass: [DSALocalMapTileBuilding class]])
      {
        DSALocalMapTileBuilding *buildingTile = (DSALocalMapTileBuilding*)currentTile;
        DSADirection direction = buildingTile.door;
        activeGroup.position = nil;
        activeGroup.position = [currentPosition positionByMovingInDirection: direction steps: 1];
      }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureLocationUpdated" object:self];     
}
@end
@implementation DSAActionIconChat
@end
@implementation DSAActionIconPray
@end
@implementation DSAActionIconBuy
@end
@implementation DSAActionIconSell
@end
@implementation DSAActionIconMap
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"map_icon-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Karte");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
        
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        if ([currentTile isKindOfClass: [DSALocalMapTileStreet class]] || 
            [currentTile isKindOfClass: [DSALocalMapTileGreen class]])
          {
            return YES;
          }
      }
    return NO;
}

- (void)handleEvent {
    NSLog(@"DSAActionIconMap handleEvent called");
    
}
@end
