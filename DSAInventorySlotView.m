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

@implementation DSAInventorySlotView
- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"mouseDown triggered");
    if ([self initiatesDrag]) {
        DSAInventorySlotView *sourceView = (DSAInventorySlotView *)self; // This assumes self is a DSAInventorySlotView
        DSAObject *draggedItem = sourceView.item;
        
        if (draggedItem != nil) {
            NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
            
            // Generate a unique identifier using inventoryType and slotIndex
            NSString *draggedItemID = [NSString stringWithFormat:@"%@:%ld", sourceView.inventoryType, sourceView.slotIndex];
            
            [pboard declareTypes:@[NSStringPboardType] owner:self];
            [pboard setString:draggedItemID forType:NSStringPboardType];
            
            NSPoint p = [theEvent locationInWindow];
            [self dragImage:self.image
                         at:p
                     offset:NSZeroSize
                      event:theEvent
                 pasteboard:pboard
                     source:self
                  slideBack:YES];
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSLog(@"mouseUp triggered");
    [super mouseUp:theEvent];
/*    if ([self draggingSource] == self) {
        // Manually invoke performDragOperation if necessary
        [self performDragOperation:[theEvent draggingInfo]];
    } */
}




- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSLog(@"draggingEntered draggingSource: %@ self: %@", [sender draggingSource], self);

    if ([sender draggingSource] != self) { // Ignore self to avoid redundant highlighting
        [self highlightTargetView:YES];
        return NSDragOperationMove;
    }

    return NSDragOperationNone; // No operation if dragging over the source
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    NSLog(@"draggingExited");
    [self highlightTargetView:NO];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"performDragOperation");
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *draggedItemID = [pasteboard stringForType:NSStringPboardType];
    
    // Split the identifier into parts (inventoryType and slotIndex)
    NSArray *components = [draggedItemID componentsSeparatedByString:@":"];
    if (components.count == 2) {
        NSString *inventoryType = components[0];
        NSInteger slotIndex = [components[1] integerValue];
        
        // Log the dragged item details (for debugging)
        NSLog(@"Dragged Item: %@, Inventory Type: %@, Slot Index: %ld", draggedItemID, inventoryType, (long)slotIndex);
        
        // Use inventoryType and slotIndex to find the item in the inventory
        DSAObject *draggedItem = [self findItemWithInventoryType:inventoryType slotIndex:slotIndex];
        
        if (self.item == nil) {  // Target slot is empty
            self.item = draggedItem;
            
            // Determine the correct icon size based on the inventory type
            NSString *iconName = draggedItem.icon; // Get the icon name
            NSString *imagePath = nil;
            
            // If the inventory type is "general", use the 64x64 icon
            if ([inventoryType isEqualToString:@"general"]) {
                iconName = [NSString stringWithFormat:@"%@-64x64", iconName];
            } else if ([inventoryType isEqualToString:@"bodyPart"]) {
                // For body parts, use the 32x32 icon
                iconName = [NSString stringWithFormat:@"%@-32x32", iconName];
            }
            
            // Load the image for the item
            imagePath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"webp"];
            if (imagePath) {
                self.image = [[NSImage alloc] initWithContentsOfFile:imagePath];
            }
            [self highlightTargetView:NO];
            return YES;
        }
    }
    [self highlightTargetView:NO];
    return NO;
}

- (DSAObject *)findItemWithInventoryType:(NSString *)inventoryType slotIndex:(NSInteger)slotIndex {
    // If the inventoryType is "general", look in the general inventory
    if ([inventoryType isEqualToString:@"general"]) {
        // Loop through the slots in the general inventory
        for (DSASlot *slot in self.model.inventory.slots) {
            if (slotIndex == [self.model.inventory.slots indexOfObject:slot]) {
                return slot.object;  // Return the item in the correct slot
            }
        }
    }
    // If the inventoryType is "bodyParts", look in the body parts inventories
    else if ([inventoryType isEqualToString:@"bodyParts"]) {
        // Loop through the body part inventories
        for (NSString *propertyName in self.model.bodyParts.inventoryPropertyNames) {
            DSAInventory *inventory = [self.model.bodyParts valueForKey:propertyName];
            // Check if the slotIndex is valid for this inventory's slots
            if (slotIndex < inventory.slots.count) {
                DSASlot *slot = inventory.slots[slotIndex];
                return slot.object;  // Return the item in the correct slot
            }
        }
    }
    return nil;  // Return nil if no matching item is found
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


@end
