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
#import "DSALocalMapViewController.h"
#import "DSAShopViewController.h"
#import "DSAShoppingCart.h"
#import "DSAShopBargainController.h"
#import "DSAWallet.h"
#import "DSAConversationController.h"
#import "DSADonationViewController.h"
#import "DSAInnRentRoomViewController.h"
#import "DSAGod.h"
#import "DSAAdventureClock.h"
#import "DSAPricingEngine.h"
#import "DSAOrderMealViewController.h"
#import "DSASleepViewController.h"
#import "DSADialogManager.h"
#import "DSADialog.h"
#import "DSAConversationDialogSheetController.h"

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
                    _(@"donate"): [DSAActionIconDonate class],
                    _(@"buy"): [DSAActionIconBuy class],
                    _(@"sell"): [DSAActionIconSell class],
                    _(@"rentRoom"): [DSAActionIconRoom class],
                    _(@"sleep"): [DSAActionIconSleep class],
                    _(@"useTalent"): [DSAActionIconTalent class],
                    _(@"useMagic"): [DSAActionIconMagic class],
                    _(@"orderMeal"): [DSAActionIconMeal class],
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
    if (group.membersCount > 0)
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
    if (group.membersCount > 1)
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
    
    if ([currentTile isKindOfClass:[DSALocalMapTileBuildingInn class]])
      {
        DSALocalMapTileBuildingInn *innTile = (DSALocalMapTileBuildingInn*) currentTile;
        if ([@[DSALocalMapTileBuildingInnTypeHerberge, DSALocalMapTileBuildingInnTypeHerbergeMitTaverne] containsObject:innTile.type] && 
            [@[@"room", @"tavern"] containsObject: currentPosition.room])
          {
            currentPosition.room = @"reception";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureLocationUpdated" object:self];
            return;
          }
      }
    
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
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"speak-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Unterhalten");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    if (activeGroup.membersCount > 0)
      {
        return YES;
      }
    return NO;
}
- (void)handleEvent {
    NSLog(@"DSAActionIconChat handleEvent called");

    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) return;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;

    DSALocation *location = [[DSALocations sharedInstance] locationWithName:currentPosition.localLocationName ofType:@"local"];
    if (![location isKindOfClass:[DSALocalMapLocation class]]) return;

    DSALocalMapTile *tile = [(DSALocalMapLocation *)location tileAtCoordinate:currentPosition.mapCoordinate];
 
    NSString *dialogNPC = nil;
    if ([tile isKindOfClass:[DSALocalMapTileBuildingInn class]]) {
      if ([tile.type isEqualToString: DSALocalMapTileBuildingInnTypeHerberge])
        {
          dialogNPC = @"innkeeper";
        }
      else if ([tile.type isEqualToString: DSALocalMapTileBuildingInnTypeTaverne])
        {
          dialogNPC = @"tavern";
        }
      else  // DSALocalMapTileBuildingInnTypeHerbergeMitTaverne
        {
          if ([currentPosition.room isEqualToString: @"reception"])
            {
              dialogNPC = @"innkeeper";
            }
          else if ([currentPosition.room isEqualToString: @"tavern"])
            {
              dialogNPC = @"tavern";
            }
        }
    } else if ([tile isKindOfClass:[DSALocalMapTileBuildingShop class]]) {
        if ([tile.type isEqualToString:@"Krämer"])
          {
            dialogNPC = @"shopkeeper_general";
          }
        else if ([tile.type isEqualToString:@"Waffenhändler"])
          {
            dialogNPC = @"shopkeeper_weapon";
          }
        else if ([tile.type isEqualToString:@"Kräuterhändler"])
          {
            dialogNPC = @"shopkeeper_herbs";
          }
        else
          {
            NSLog(@"DSAActionIconChat handleEvent unbekannter shop Type: %@", tile.type);
          }
    } else if ([tile isKindOfClass:[DSALocalMapTileBuildingSmith class]]) {
        dialogNPC = @"blacksmith";
    } else if ([tile isKindOfClass:[DSALocalMapTileBuildingHealer class]]) {
        dialogNPC = @"healer";
    } else if ([tile isKindOfClass:[DSALocalMapTileBuildingTemple class]]) {
        dialogNPC = @"temple_priest";
    } else {
      NSLog(@"DSAActionIconChat handleEvent: unknown tile, don't know what type of dialogue to use");
    }
    if (!dialogNPC) {
        NSLog(@"DSAActionIconChat handleEvent: no NPC around to talk to?");
        return;
    }

    // Dialog laden
    DSADialogManager *manager = [[DSADialogManager alloc] init];
    NSString *dialogFileName = [NSString stringWithFormat:@"dialogue_%@", dialogNPC];
    if (![manager loadDialogFromFile: dialogFileName]) {
        NSLog(@"DSAActionIconChat handleEvent: unable to load dialog file: %@", dialogFileName);
        return;
    }

    manager.currentNodeID = manager.currentDialog.startNodeID;

    // Dialog UI anzeigen als Sheet
    DSAConversationDialogSheetController *dialogController = [[DSAConversationDialogSheetController alloc] initWithDialogManager:manager];

    // Present dialogController.window as sheet attached to main window
    [windowController.window beginSheet:dialogController.window completionHandler:^(NSModalResponse returnCode) {
        // Optional: handle sheet dismissal here
        NSLog(@"Dialog sheet closed");
    }];
}

@end
@implementation DSAActionIconPray
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"pray-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Göttliches Wunder erbitten");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    if (activeGroup.membersCount > 0)
      {
        return YES;
      }
    return NO;
}

- (void)handleEvent {
    NSLog(@"DSAActionIconPray handleEvent called");
    
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
    NSLog(@"DSAActionIconPray handleEvent currentPosition: %@", currentPosition);
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
    NSLog(@"DSAActionIconPray handleEvent currentLocation: %@, %@", [currentLocation class], currentLocation.name);
    NSString *godName;
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        NSLog(@"DSAActionIconPray handleEvent currentLocation: %@", currentTile);
        if ([currentTile isKindOfClass: [DSALocalMapTileBuildingTemple class]])
          {
            godName = [(DSALocalMapTileBuildingTemple*)currentTile god];
          }
      }
    DSAGod *god = adventure.godsByName[godName];
    DSAMiracleResult *miracleResult;
    BOOL result = [god requestMiracleWithFame: god.reputation
                                     forGroup: activeGroup
                                       atDate: adventure.gameClock.currentDate
                                       result: &miracleResult];
    NSString *resultString;
    if (result)
      {
        resultString = [NSString stringWithFormat: @"Eure Bitten wurden von %@ erhört: %@", godName, miracleResult.effectDescription];
      }
    else
      {
        resultString = [NSString stringWithFormat: @"Eure Bitten wurden von %@ nicht erhört.", godName];
      }
    [god decreaseReputationBy: 1];
    
    
    DSAConversationController *conversationSelector = [[DSAConversationController alloc] initWithWindowNibName: @"DSAConversationTextOnly"];
    [conversationSelector window];  // trigger loading .gorm file
    conversationSelector.fieldText.stringValue = resultString;
    NSLog(@"DSAActionIconDonate, handleEvent: conversationSelector.fieldText.stringValue %@", conversationSelector.fieldText.stringValue);
    conversationSelector.completionHandler = ^(BOOL result) {
      if (result)
        {
           NSLog(@"DSAActionIconDonate, handleEvent: finally, praying finished");
        }
    };
    [windowController.window beginSheet: conversationSelector.window completionHandler:nil];  
}
@end
@implementation DSAActionIconDonate
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"donate-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Spenden");
        [self updateAppearance];
    }
    return self;
}
- (BOOL)isActive {
    DSAAdventureWindowController *windowController = self.window.windowController;

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    if (activeGroup.membersCount > 0)
      {
        return YES;
      }
    return NO;
}
- (void)handleEvent {
    NSLog(@"DSAActionIconBuy handleEvent called");
    
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
    NSLog(@"DSAActionIconDonate handleEvent currentPosition: %@", currentPosition);
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];    

    // Step 2: Present the shop view sheet
    DSADonationViewController *selector =
        [[DSADonationViewController alloc] initWithWindowNibName:@"DSADonation"];
    selector.activeGroup = activeGroup;
    __block BOOL donationResult = NO;
    __block float donatedSilver;
    selector.completionHandler = ^(BOOL result) {
        if (result) {
            NSLog(@"DSAActionDonate sheet completion handler called.... ");
            donationResult = result;
            donatedSilver = [[selector.fieldFinalSilver stringValue] floatValue];
          }
       
    };
    
    [windowController.window beginSheet:selector.window completionHandler:nil];
    if (!donationResult)
      {
        return;
      }
    [activeGroup subtractSilber: donatedSilver];
    NSString *godName;
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        NSLog(@"DSAActionIconPray handleEvent currentLocation: %@", currentTile);
        if ([currentTile isKindOfClass: [DSALocalMapTileBuildingTemple class]])
          {
            godName = [(DSALocalMapTileBuildingTemple*)currentTile god];
          }
      }
    DSAGod *god = adventure.godsByName[godName];
    [god increaseReputationBy: roundf(donatedSilver)];
    
    NSLog(@"DSAActionIconDonate handleEvent current reputation: %@", [NSNumber numberWithInteger: god.reputation]);
          
    DSAConversationController *conversationSelector = [[DSAConversationController alloc] initWithWindowNibName: @"DSAConversationTextOnly"];
    [conversationSelector window];  // trigger loading .gorm file
    conversationSelector.fieldText.stringValue = @"Der Geweihte an der Opferschale bedankt sich für eure großzügige Spende.";
    NSLog(@"DSAActionIconDonate, handleEvent: conversationSelector.fieldText.stringValue %@", conversationSelector.fieldText.stringValue);
    conversationSelector.completionHandler = ^(BOOL result) {
      if (result)
        {
           NSLog(@"DSAActionIconDonate, handleEvent: finally, donation finished");
        }
    };
    [windowController.window beginSheet: conversationSelector.window completionHandler:nil];  
}
@end
@implementation DSAActionIconBuy
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"buy_icon-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Kaufen");
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
    NSLog(@"DSAActionIconBuy isActive currentPosition: %@", currentPosition);
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
    NSLog(@"DSAActionIconBuy isActive currentLocation: %@, %@", [currentLocation class], currentLocation.name);   
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        NSLog(@"DSAActionIconBuy isActive currentLocation: %@", currentTile);
        if ([currentTile isKindOfClass: [DSALocalMapTileBuildingShop class]])
          {
            return YES;
          }
      }
    return NO;
}

- (void)handleEvent {
    NSLog(@"DSAActionIconBuy handleEvent called");
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
    NSString *shopType;
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        NSLog(@"DSAActionIconBuy isActive currentLocation: %@", currentTile);
        if ([currentTile isKindOfClass: [DSALocalMapTileBuildingShop class]])
          {
            shopType = currentTile.type;
          }
      }
    NSLog(@"DSAActionIconBuy handleEvent shopType: %@", shopType);
    // Step 2: Present the shop view sheet
    DSAShopViewController *selector =
        [[DSAShopViewController alloc] initWithWindowNibName:@"DSAShopView"];
    selector.mode = DSAShopModeBuy;
    selector.maxSilber = [activeGroup totalWealthOfGroup];
    selector.allItems = [Utils getAllDSAObjectsForShop: shopType];    
    NSLog(@"DSAActionIconBuy handleEvent allItems count: %@", [NSNumber numberWithInteger: [selector.allItems count]]);
    __block DSAShoppingCart *localShoppingCart;
    selector.completionHandler = ^(DSAShoppingCart *shoppingCart) {
        NSLog(@"DSAActionIconBuy handleEvent: completionHandler aufgerufen mit: %@", shoppingCart);
        if (shoppingCart) {
            NSLog(@"DSAActionIcon sheet completion handler called.... ");
            if ([shoppingCart countAllObjects] == 0)
              {
                return;
              }
            localShoppingCart = shoppingCart;
            
          }
        else
          {
            return;
          }
       
    };
    windowController.shopViewController = selector;
    
    [windowController.window beginSheet:selector.window completionHandler:nil];
    if ([localShoppingCart countAllObjects] == 0)
      {
        return;
      }
    
    DSAShopBargainController *bargainSelector =
        [[DSAShopBargainController alloc] initWithWindowNibName:@"DSAShopBargain"];
    bargainSelector.mode = DSAShopModeBuy;
    bargainSelector.shoppingCart = localShoppingCart;
    bargainSelector.activeGroup = activeGroup;
    __block float finalPercent = 0;
    __block NSString *finalComment;
    __block float finalPrice;
    bargainSelector.completionHandler = ^(BOOL result) {
        finalPercent = [bargainSelector.fieldPercentValue.stringValue floatValue];
        finalComment = bargainSelector.fieldBargainResult.stringValue;    
      if (result)
        {
          finalPrice = localShoppingCart.totalSum - (localShoppingCart.totalSum * finalPercent / 100);
        }
      else
        {
          finalPrice = localShoppingCart.totalSum;
        }
    };
    [windowController.window beginSheet:bargainSelector.window completionHandler:nil];
    NSLog(@"DSAActionIconBuy handleEvent: final percent is %.2f, finalComment: %@", finalPercent, finalComment);
    
    // float finalPrice = localShoppingCart.totalSum - (localShoppingCart.totalSum * finalPercent / 100);
    
    [activeGroup subtractSilber: finalPrice];
    for (NSDictionary *cartItem in [localShoppingCart.cartContents allValues])
      {
        [activeGroup distributeItems:[[cartItem objectForKey: @"items"] objectAtIndex: 0] count: [[cartItem objectForKey: @"items"] count]];
      }
      
    DSAConversationController *conversationSelector = [[DSAConversationController alloc] initWithWindowNibName: @"DSAConversationTextOnly"];
    [conversationSelector window];  // trigger loading .gorm file
    conversationSelector.fieldText.stringValue = [NSString stringWithFormat: @"Finaler Preis: %.2f Silber. %@", finalPrice, finalComment];
    NSLog(@"DSAActionIcon, handleEvent: conversationSelector.fieldText.stringValue %@", conversationSelector.fieldText.stringValue);
    conversationSelector.completionHandler = ^(BOOL result) {
      if (result)
        {
           NSLog(@"DSAActionIcon, handleEvent: finally, shopping finished");
        }
    };
    [windowController.window beginSheet: conversationSelector.window completionHandler:nil];   
}
@end

@implementation DSAActionIconSell
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"sell_icon-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Verkaufen");
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
    NSLog(@"DSAActionIconSell isActive currentPosition: %@", currentPosition);
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
    NSLog(@"DSAActionIconSell isActive currentLocation: %@, %@", [currentLocation class], currentLocation.name);   
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        NSLog(@"DSAActionIconSell isActive currentLocation: %@", currentTile);
        if ([currentTile isKindOfClass: [DSALocalMapTileBuildingShop class]])
          {
            return YES;
          }
      }
    return NO;
}
- (void)handleEvent {
    NSLog(@"DSAActionIconSell handleEvent called");
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
    NSString *shopType;
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        NSLog(@"DSAActionIconSell isActive currentLocation: %@", currentTile);
        if ([currentTile isKindOfClass: [DSALocalMapTileBuildingShop class]])
          {
            shopType = currentTile.type;
          }
      }
    NSLog(@"DSAActionIconBuy handleEvent shopType: %@", shopType);
    // Step 2: Present the shop view sheet
    DSAShopViewController *selector =
        [[DSAShopViewController alloc] initWithWindowNibName:@"DSAShopView"];
    selector.mode = DSAShopModeSell;
    selector.allSlots = [activeGroup getAllDSASlotsForShop: shopType];    
    NSLog(@"DSAActionIconSell handleEvent allSlots count: %@", [NSNumber numberWithInteger: [selector.allSlots count]]);
    __block DSAShoppingCart *localShoppingCart;
    selector.completionHandler = ^(DSAShoppingCart *shoppingCart) {
        NSLog(@"DSAActionIconSell handleEvent: completionHandler aufgerufen mit: %@", shoppingCart);
        if (shoppingCart) {
            NSLog(@"DSAActionIconSell sheet completion handler called.... ");
            if ([shoppingCart countAllObjects] == 0)
              {
                return;
              }
            localShoppingCart = shoppingCart;
          }
        else
          {
            return;
          }
       
    };
    windowController.shopViewController = selector;
    
    [windowController.window beginSheet:selector.window completionHandler:nil];
    if ([localShoppingCart countAllObjects] == 0)
      {
        return;
      }
    
    DSAShopBargainController *bargainSelector =
        [[DSAShopBargainController alloc] initWithWindowNibName:@"DSAShopBargain"];
    bargainSelector.mode = DSAShopModeBuy;
    bargainSelector.shoppingCart = localShoppingCart;
    bargainSelector.activeGroup = activeGroup;
    __block float finalPercent = 0;
    __block NSString *finalComment;
    __block float finalPrice;
    bargainSelector.completionHandler = ^(BOOL result) {
        finalPercent = [bargainSelector.fieldPercentValue.stringValue floatValue];
        finalComment = bargainSelector.fieldBargainResult.stringValue;    
      if (result)
        {
          finalPrice = localShoppingCart.totalSum + (localShoppingCart.totalSum * finalPercent / 100);
        }
      else
        {
          finalPrice = localShoppingCart.totalSum;
        }
    };
    [windowController.window beginSheet:bargainSelector.window completionHandler:nil];
    NSLog(@"DSAActionIconBuy handleEvent: final percent is %.2f, finalComment: %@", finalPercent, finalComment);
    
    // float finalPrice = localShoppingCart.totalSum - (localShoppingCart.totalSum * finalPercent / 100);
    
    [activeGroup addSilber: finalPrice];
    for (NSString *key in [localShoppingCart.cartContents allKeys])
      {
        //[activeGroup distributeItems:[[cartItem objectForKey: @"items"] objectAtIndex: 0] count: [[cartItem objectForKey: @"items"] count]];
        
        NSArray<NSString *> *components = [key componentsSeparatedByString:@"|"];
        NSInteger quantity = [[localShoppingCart.cartContents[key] objectForKey: @"items"] count];
        //NSString *itemName;
        NSString *slotID;
        if (components.count == 2) {
           //itemName = components[0];
           slotID = components[1];
        } else {
           NSLog(@"DSAActionIconSell, handleEvent: invalid key: %@", key);
        }
        DSASlot *slot = [DSASlot slotWithSlotID: [[NSUUID alloc] initWithUUIDString:slotID]];
        __unused NSInteger remainder = [slot removeObjectWithQuantity: quantity];
        NSLog(@"DSAActionIconSell handleEvent going to enumerate model IDs");
        for (NSUUID *modelID in [activeGroup allMembers])
          {
            NSLog(@"DSAActionIconSell handleEvent enumerating model with ID: %@", [modelID UUIDString]);
            DSACharacter *character = [DSACharacter characterWithModelID: modelID];
            if ([[DSAInventoryManager sharedManager] isSlotWithID: slotID inModel: character])
              {
                [[DSAInventoryManager sharedManager] postDSAInventoryChangedNotificationForSourceModel: character 
                                                                                           targetModel: character];
                break;
              }
          }
        
      }
      
    DSAConversationController *conversationSelector = [[DSAConversationController alloc] initWithWindowNibName: @"DSAConversationTextOnly"];
    [conversationSelector window];  // trigger loading .gorm file
    conversationSelector.fieldText.stringValue = [NSString stringWithFormat: @"Finaler Preis: %.2f. %@", finalPrice, finalComment];
    NSLog(@"DSAActionIcon, handleEvent: conversationSelector.fieldText.stringValue %@", conversationSelector.fieldText.stringValue);
    conversationSelector.completionHandler = ^(BOOL result) {
      if (result)
        {
           NSLog(@"DSAActionIcon, handleEvent: finally, shopping finished");
        }
    };
    [windowController.window beginSheet: conversationSelector.window completionHandler:nil];   
}
@end

@implementation DSAActionIconRoom
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"rent_a_room-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Zimmer");
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
    if ([currentPosition.room isEqualToString: @"reception"])
      {
        return YES;
      }
    return NO;
}

- (void)handleEvent {
    NSLog(@"DSAActionIconRoom handleEvent called");

    // Step 1: Zugriff auf das Model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }

    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;

    NSString *roomKey = [activeGroup.position roomKey];
    NSLog(@"DSAActionIconRoom handleEvent roomKey: %@", roomKey);                   
    NSInteger groupMembers = activeGroup.membersCount;
    NSInteger membersWithRoom = [activeGroup charactersWithBookedRoomOfKey:roomKey];
    
    NSLog(@"DSAActionIconRoom handleEvent membersWithRoom: %ld", membersWithRoom);                   
    if (groupMembers == membersWithRoom) {                    // everyone has a room, we go onto the room
        activeGroup.position.room = @"room";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureLocationUpdated" object:self];
        return;
    }

    NSInteger membersWithoutRoom = groupMembers - membersWithRoom;

    // Step 2: Fenster für Zimmerbuchung anzeigen
    DSAInnRentRoomViewController *selector =
        [[DSAInnRentRoomViewController alloc] initWithWindowNibName:@"DSAInnRentRoom"];
    [selector window];  // .gorm laden
    selector.activeGroup = activeGroup;
    NSMutableDictionary *roomPrices = [[NSMutableDictionary alloc] init];
    NSLog(@"DSAActionIconRoom handleEvent seed: %@", activeGroup.position.description);
    DSAPricingResult *dormitory = [DSAPricingEngine priceForServiceCategory: DSAServiceCategoryInnRoom
                                                                    subtype: DSARoomTypeDormitory
                                                                       seed: activeGroup.position.description];
    DSAPricingResult *single = [DSAPricingEngine priceForServiceCategory: DSAServiceCategoryInnRoom
                                                                 subtype: DSARoomTypeSingle
                                                                    seed: activeGroup.position.description];
    DSAPricingResult *suite = [DSAPricingEngine priceForServiceCategory: DSAServiceCategoryInnRoom
                                                                subtype: DSARoomTypeSuite
                                                                   seed: activeGroup.position.description];                                                                               [roomPrices setObject: [NSNumber numberWithFloat: dormitory.price]
                   forKey: dormitory.name];
    [roomPrices setObject: [NSNumber numberWithFloat: single.price]
                   forKey: single.name];
    [roomPrices setObject: [NSNumber numberWithFloat: suite.price]
                   forKey: suite.name];
    selector.roomPrices = roomPrices;                 

//    __block BOOL rentResult = NO;
    __block NSInteger nights = 0;
    __block NSString *roomType = nil;

    __weak typeof(selector) weakSelector = selector;
    selector.completionHandler = ^(BOOL result) {
        typeof(selector) strongSelf = weakSelector;
        if (!strongSelf || !result) {
            return;
        }

        NSLog(@"DSAActionIconRoom sheet completion handler called.... ");

//        rentResult = YES;
        nights = round([strongSelf.sliderNights doubleValue]);

        NSString *fullRoomTitle = [[strongSelf.popupRooms selectedItem] title];
        roomType = [[fullRoomTitle componentsSeparatedByString:@" "] firstObject];
        NSLog(@"DSAActionIconRoom handleEvent roomType: %@", roomType);
        double pricePerPersonPerNight = [strongSelf.roomPrices[roomType] doubleValue];
        double totalPrice = pricePerPersonPerNight * nights * membersWithoutRoom;

        [activeGroup subtractSilber: totalPrice];

        DSAAventurianDate *expirationDate =
            [adventure.gameClock.currentDate dateByAddingYears:0 days:nights hours:0 minutes:0];

        for (DSACharacter *character in activeGroup.allCharacters) {
            if (![character hasAppliedCharacterEffectWithKey:roomKey]) {
                DSACharacterEffect *effect = [[DSACharacterEffect alloc] init];
                effect.uniqueKey = roomKey;
                effect.effectType = DSAMiracleResultTypeNothing;
                effect.expirationDate = expirationDate;
                effect.reversibleChanges = @{ roomType: [DSAPricingEngine roomTypeFromName: roomType] };

                [character addEffect:effect];
                NSLog(@"DSAActionIconRoom handleEvent added effect: %@", effect);
            }
        }
     
        // Begrüßungstext inkl. Preis
        DSAConversationController *conversationSelector = [[DSAConversationController alloc] initWithWindowNibName:@"DSAConversationTextOnly"];
        [conversationSelector window];

        NSString *priceString;
        if (totalPrice >= 1.0) {
            int silver = (int)totalPrice;
            int heller = (int)round((totalPrice - silver) * 10);
            if (heller > 0)
                priceString = [NSString stringWithFormat:@"%dS %dH", silver, heller];
            else
                priceString = [NSString stringWithFormat:@"%dS", silver];
        } else {
            int heller = (int)round(totalPrice * 10);
            priceString = [NSString stringWithFormat:@"%dH", heller];
        }

        conversationSelector.fieldText.stringValue = [NSString stringWithFormat:
            @"Ihr bezahlt %@ für %@ Nächte im %@. Der Wirt bedankt sich, und ihr werdet herzlich willkommen geheißen.",
            priceString, @(nights), roomType];

        conversationSelector.completionHandler = ^(BOOL result) {
            if (result) {
                NSLog(@"DSAActionIconRoom, handleEvent: finally, renting finished");
            }
        };

        [windowController.window beginSheet:conversationSelector.window completionHandler:nil];

    };

    [windowController.window beginSheet:selector.window completionHandler:nil];
}

@end
@implementation DSAActionIconSleep
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"go_to_sleep-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Schlafen");
        [self updateAppearance];
    }
    return self;
}

- (void)handleEvent {
    NSLog(@"DSAActionIconSleep handleEvent called");

    // Step 1: Zugriff auf das Model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }
            
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;
    

    DSASleepViewController *selector =
        [[DSASleepViewController alloc] initWithWindowNibName:@"DSASleepView"];
    [selector window];  // .gorm laden

    __weak typeof(selector) weakSelector = selector;
    selector.completionHandler = ^(BOOL result) {
        typeof(selector) strongSelf = weakSelector;
        if (!strongSelf || !result) {
            return;
        }

        NSLog(@"DSAActionIconSleep sheet completion handler called.... ");

        NSInteger sleepHours = [strongSelf.sliderHours integerValue];

        NSLog(@"DSAActionIconSleep handleEvent currentPosition: %@", currentPosition);
        DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
        NSLog(@"DSAActionIconSleep handleEvent currentLocation: %@, %@", [currentLocation class], currentLocation.name);
        DSARoomType roomType = DSARoomTypeUnknown;
        DSALocalMapTile *currentTile;
        if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
          {
            DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
            currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
            NSLog(@"DSAActionIconSleep handleEvent currentLocation: %@", currentTile);
            if ([currentTile isKindOfClass: [DSALocalMapTileBuildingInn class]])
              {
                DSACharacter *character = [activeGroup.allCharacters objectAtIndex: 0];
                NSString *roomKey = [activeGroup.position roomKey];
                DSACharacterEffect *effect = [character.appliedEffects objectForKey: roomKey];
                roomType = [[[effect.reversibleChanges allValues] objectAtIndex: 0] integerValue];
              }
          }
        DSASleepQuality sleepQuality = DSASleepQualityUnknown;
        if (roomType != DSARoomTypeUnknown)
          {
            switch (roomType) {
              case DSARoomTypeDormitory: {
                sleepQuality = DSASleepQualityNormal;
                break;
              }
              case DSARoomTypeSingle: {
                sleepQuality = DSASleepQualityGood;
                break;
              }
              case DSARoomTypeSuite: {
                sleepQuality = DSASleepQualityExcellent;
                break;
              }
              case DSARoomTypeUnknown: {
                sleepQuality = DSASleepQualityUnknown;
                break;
              }              
            }
          }
        
        for (DSACharacter *character in activeGroup.allCharacters) {
            [character sleepForHours: sleepHours
                        sleepQuality: sleepQuality];
        }
        [adventure.gameClock advanceTimeByHours: sleepHours];
        // Leave the room and go back to reception, in case we're in a Inn
        if ([currentTile isKindOfClass:[DSALocalMapTileBuildingInn class]])
          {
            DSALocalMapTileBuildingInn *innTile = (DSALocalMapTileBuildingInn*) currentTile;
            if ([@[DSALocalMapTileBuildingInnTypeHerberge, DSALocalMapTileBuildingInnTypeHerbergeMitTaverne] containsObject:innTile.type] && 
                [@[@"room", @"tavern"] containsObject: currentPosition.room])
              {
                currentPosition.room = @"reception";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureLocationUpdated" object:self];
              }
          }       
    };
    [windowController.window beginSheet:selector.window completionHandler:nil];     
}
@end

@implementation DSAActionIconTalent
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"use_talent-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Talent anwenden");
        [self updateAppearance];
    }
    return self;
}
@end
@implementation DSAActionIconMagic
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"use_magic-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Magie anwenden");
        [self updateAppearance];
    }
    return self;
}
@end
@implementation DSAActionIconMeal
- (instancetype)initWithImageSize: (NSString *)size
{
    self = [super init];
    if (self) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"order_meal-%@", size] ofType: @"webp"];
        self.image = imagePath ? [[NSImage alloc] initWithContentsOfFile: imagePath] : nil;
        self.toolTip = _(@"Essen");
        [self updateAppearance];
    }
    return self;
}

- (void)handleEvent {
    NSLog(@"DSAActionIconMeal handleEvent called");

    // Step 1: Zugriff auf das Model
    DSAAdventureWindowController *windowController = self.window.windowController;
    if (![windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        NSLog(@"Invalid window controller class");
        return;
    }
            
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    
    NSArray *mealSelectionTexts = @[
      @"Wirtin Rika tritt an euren Tisch, wischt sich die Hände an der Schürze ab und lächelt freundlich. Was darf’s für euch sein, Reisende",
      @"Der Geruch von frisch Gebratenem liegt in der Luft, als der Wirt euch zunickt. Vier Speisen stehen heute zur Wahl, wählt weise!",
      @"Mit einem hölzernen Löffel in der Hand ruft der Koch aus der Küche: Die Töpfe sind voll, der Hunger sei verjagt, was soll ich auftragen?",
      @"Eine Schankmagd kommt lächelnd an euren Tisch. Was soll's denn sein? Warm, kräftig oder feuchtfröhlich? Die Auswahl liegt bei euch!",
      @"Ein alter Stammgast prostet euch zu. Lasst euch die Chance nicht entgehen, heut gibt’s was Feines auf die Zunge!",
      @"Der Duft aus der Küche macht euch das Wasser im Mund zusammenlaufen. 'Wählt, bevor alles fort ist!', ruft der Wirt mit einem Grinsen.",
      @"'Hunger und Durst sollen euch nicht plagen, wir hätten da drei Köstlichkeiten zur Wahl!', bietet die Wirtin freundlich an.",
      @"Der Wirt wischt mit einem Tuch den Tisch ab. 'Also, ihr Lieben, was soll's sein? Vier Möglichkeiten, aber nur ein Magen!'"
    ];
    NSString *randomText = mealSelectionTexts[arc4random_uniform((uint32_t) mealSelectionTexts.count)];
    
    DSAOrderMealViewController *selector =
        [[DSAOrderMealViewController alloc] initWithWindowNibName:@"DSAMealOrderView"];
    [selector window];  // .gorm laden
    [selector.fieldSelectionText setStringValue: randomText];
    NSMutableDictionary *mealPrices = [[NSMutableDictionary alloc] init];
    NSLog(@"DSAActionIconMeal handleEvent seed: %@", activeGroup.position.description);
    DSAPricingResult *simple = [DSAPricingEngine priceForServiceCategory: DSAServiceCategoryMeal
                                                                 subtype: DSAMealQualitySimple
                                                                    seed: activeGroup.position.description];
    DSAPricingResult *good = [DSAPricingEngine priceForServiceCategory: DSAServiceCategoryMeal
                                                               subtype: DSAMealQualityGood
                                                                  seed: activeGroup.position.description];
    DSAPricingResult *fine = [DSAPricingEngine priceForServiceCategory: DSAServiceCategoryMeal
                                                               subtype: DSAMealQualityFine
                                                                  seed: activeGroup.position.description];
    DSAPricingResult *feast = [DSAPricingEngine priceForServiceCategory: DSAServiceCategoryMeal
                                                                subtype: DSAMealQualityFeast
                                                                   seed: activeGroup.position.description];                                                              
    [mealPrices setObject: [NSNumber numberWithFloat: simple.price]
                   forKey: simple.name];
    [mealPrices setObject: [NSNumber numberWithFloat: good.price]
                   forKey: good.name];
    [mealPrices setObject: [NSNumber numberWithFloat: fine.price]
                   forKey: fine.name];
    [mealPrices setObject: [NSNumber numberWithFloat: feast.price]
                   forKey: feast.name];                   
    selector.mealPrices = mealPrices;                 

    //__block NSString *mealType = nil;

    __weak typeof(selector) weakSelector = selector;
    selector.completionHandler = ^(BOOL result) {
        typeof(selector) strongSelf = weakSelector;
        if (!strongSelf || !result) {
            return;
        }

        NSLog(@"DSAActionIconMeal sheet completion handler called.... ");

        NSInteger selectedIndex = strongSelf.popupMeals.indexOfSelectedItem;
        if (selectedIndex < 0 || selectedIndex >= strongSelf.mealDisplayNames.count) {  // selected index out of range???
          return;
        }
        NSString *mealType = strongSelf.mealDisplayNames[selectedIndex];
        double pricePerPersonPerMeal = [strongSelf.mealPrices[mealType] doubleValue];
        double totalPrice = pricePerPersonPerMeal * activeGroup.allMembers.count;
        NSLog(@"DSAActionIconMeal handleEvent mealType: %@", mealType);
        
        [activeGroup subtractSilber: totalPrice];

        DSAMealQuality mealQuality = [[DSAPricingEngine mealQualityFromName: mealType] integerValue];
        float satiation = 0.0;
        switch (mealQuality) {
          case DSAMealQualitySimple: 
            satiation = 0.2;
            break;
          case DSAMealQualityGood: 
            satiation = 0.4;
            break;
          case DSAMealQualityFine: 
            satiation = 0.7;
            break;
          case DSAMealQualityFeast: 
            satiation = 1.0;
            break;
          case DSAMealQualityUnknown:
            NSLog(@"DSAActionIconMeal handleEvent, got DSAMealQualityUnknown!");
            satiation = 0.0;
            break;            
        }
        NSLog(@"DSAActionIconMeal handleEvent satiation: %@", @(satiation));
        for (DSACharacter *character in activeGroup.allCharacters) {
            // Thirst wird immer auf 1.0 gesetzt
            [character updateStateThirstWithValue: @(1.0)];
    
            // Hunger aktualisieren (aber max. 1.0)
            float hunger = [character.statesDict[@(DSACharacterStateHunger)] floatValue];
            float newHunger = hunger + satiation;
            if (newHunger > 1.0f) newHunger = 1.0f;
    
            [character updateStateHungerWithValue: @(newHunger)];
            
            NSLog(@"DSAActionIconMeal handleEvent oldHunger: %@, newHunger: %@", @(hunger), @(newHunger));
            
        }
        [adventure.gameClock advanceTimeByMinutes: 30];
        // Abschlusstext
        DSAConversationController *conversationSelector = [[DSAConversationController alloc] initWithWindowNibName:@"DSAConversationTextOnly"];
        [conversationSelector window];

        NSString *priceString;
        if (totalPrice >= 1.0) {
            int silver = (int)totalPrice;
            int heller = (int)round((totalPrice - silver) * 10);
            if (heller > 0)
                priceString = [NSString stringWithFormat:@"%dS %dH", silver, heller];
            else
                priceString = [NSString stringWithFormat:@"%dS", silver];
        } else {
            int heller = (int)round(totalPrice * 10);
            priceString = [NSString stringWithFormat:@"%dH", heller];
        }

        conversationSelector.fieldText.stringValue = [NSString stringWithFormat:
            @"Ihr bezahlt %@ für %@. Der Wirt bedankt sich freundlich.",
            priceString, mealType];

        conversationSelector.completionHandler = ^(BOOL result) {
            if (result) {
                NSLog(@"DSAActionIconMeal, handleEvent: finally, renting finished");
            }
        };

        [windowController.window beginSheet:conversationSelector.window completionHandler:nil];
    };

    [windowController.window beginSheet:selector.window completionHandler:nil];
    
}

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
    NSLog(@"DSAActionIconMap isActive currentPosition: %@", currentPosition);
    DSALocation *currentLocation = [[DSALocations sharedInstance] locationWithName: currentPosition.localLocationName ofType: @"local"];
    NSLog(@"DSAActionIconMap isActive currentLocation: %@, %@", [currentLocation class], currentLocation.name);   
    if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
      {
        DSALocalMapLocation *lml = (DSALocalMapLocation *)currentLocation;
        DSALocalMapTile *currentTile = [lml tileAtCoordinate: currentPosition.mapCoordinate];
        NSLog(@"DSAActionIconMap isActive currentLocation: %@", currentTile);
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
    
    DSAAdventureWindowController *windowController = self.window.windowController;
    DSAAdventureDocument *document = (DSAAdventureDocument *)windowController.document;
    DSAAdventure *adventure = document.model;
    
    windowController.adventureMapViewController = [[DSALocalMapViewController alloc] initWithMode: DSALocalMapViewModeAdventure adventure: adventure];
    [windowController.adventureMapViewController showWindow:self];
}
@end
