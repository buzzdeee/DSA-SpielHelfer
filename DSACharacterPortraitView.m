/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-02-28 21:40:13 +0100 by sebastia

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

#import "DSACharacterPortraitView.h"
#import "DSACharacterDocument.h"
#import "DSAAdventureDocument.h"
#import "DSAAdventureWindowController.h"
#import "DSACharacter.h"

extern NSString * const DSACharacterHighlightedNotification;

@implementation DSACharacterPortraitView

static DSACharacterPortraitView *currentlyHighlightedView = nil;
static NSString * const DSACharacterDragType = @"DSACharacterDragType";

- (void)awakeFromNib {
    [super awakeFromNib];
    // Register this view as a drag destination
    [self registerForDraggedTypes:@[DSACharacterDragType]];
}



- (void)mouseDown:(NSEvent *)event {
    if (event.clickCount == 2) {
        if (self.characterDocument) {
            [self.characterDocument showCharacterWindow];
        }
        return; // Prevent further processing for double-clicks
    }

    // Store the initial click location
    self.initialClickLocation = [self convertPoint:event.locationInWindow fromView:nil];

    // Schedule highlighting with a delay to differentiate from drag
    [self performSelector:@selector(handleClickHighlight) withObject:nil afterDelay:0.1];

    [super mouseDown:event];
}

- (void)handleClickHighlight {
    // If dragging started, cancel highlighting
    NSPoint currentLocation = [self.window mouseLocationOutsideOfEventStream];
    currentLocation = [self convertPoint:currentLocation fromView:nil];

    CGFloat distance = hypot(currentLocation.x - self.initialClickLocation.x, 
                             currentLocation.y - self.initialClickLocation.y);
    if (distance > 5) { // Threshold to detect drag
        return; // Do not highlight if dragging started
    }

    // Handle selection highlighting (only if not dragging)
    if (self == currentlyHighlightedView) {
        [self highlightTargetView:NO];
        currentlyHighlightedView = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:DSACharacterHighlightedNotification
                                                            object: nil
                                                          userInfo:nil];        
    } else {
        [currentlyHighlightedView highlightTargetView:NO];
        currentlyHighlightedView = self;
        [self highlightTargetView:YES];

        [[NSNotificationCenter defaultCenter] postNotificationName:DSACharacterHighlightedNotification
                                                            object:self.characterDocument
                                                          userInfo:nil];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.characterDocument || !self.characterDocument.model) {
        return; // No valid character to drag
    }

    NSUUID *modelID = self.characterDocument.model.modelID; // Get the UUID

    // Use the pasteboard for drag-and-drop
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:@[DSACharacterDragType] owner:self];
    [pboard setString:[modelID UUIDString] forType:DSACharacterDragType]; // Store modelID

    // Scale the image to 64x64 before dragging
    NSImage *dragImage = self.image ?: [[NSImage alloc] initWithSize:self.bounds.size];
    if (dragImage) {
        NSImage *scaledImage = [[NSImage alloc] initWithSize:NSMakeSize(64, 64)];
        [scaledImage lockFocus];

#ifdef GNUSTEP
        // GNUstep alternative: Scale image manually using setSize before drawing
        NSSize originalSize = dragImage.size;
        [dragImage setSize:NSMakeSize(64, 64)];  // Scale image
        [dragImage compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
        [dragImage setSize:originalSize];  // Restore original size
#else
        // macOS version
        [dragImage drawInRect:NSMakeRect(0, 0, 64, 64)
                     fromRect:NSMakeRect(0, 0, dragImage.size.width, dragImage.size.height)
                    operation:NSCompositingOperationSourceOver
                     fraction:1.0];
#endif

        [scaledImage unlockFocus];

        dragImage = scaledImage; // Use the resized image
    }

    // Get drag position
    NSPoint dragPosition = [self convertPoint:event.locationInWindow fromView:nil];

    // Start drag operation with resized image
    [self dragImage:dragImage
                 at:dragPosition
             offset:NSZeroSize
              event:event
         pasteboard:pboard
             source:self
          slideBack:YES];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSString *draggedModelID = [pboard stringForType:DSACharacterDragType];

    if (draggedModelID) {
        DSAAdventureWindowController *windowController = (DSAAdventureWindowController *)self.window.windowController;
        DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)windowController.document;
        NSMutableArray *characters = [adventureDoc.characterDocuments mutableCopy];

        // Find the dragged character and the target character
        DSACharacterDocument *draggedCharacter = nil;
        DSACharacterDocument *targetCharacter = self.characterDocument;

        for (DSACharacterDocument *charDoc in characters) {
            if ([charDoc.model.modelID isEqual:[[NSUUID alloc] initWithUUIDString: draggedModelID]]) {
                draggedCharacter = charDoc;
                break;
            }
        }

        if (draggedCharacter && targetCharacter && draggedCharacter != targetCharacter) {
            NSUInteger draggedIndex = [characters indexOfObject:draggedCharacter];
            NSUInteger targetIndex = [characters indexOfObject:targetCharacter];

            [characters exchangeObjectAtIndex:draggedIndex withObjectAtIndex:targetIndex];
            [adventureDoc updateChangeCount: NSChangeDone];
            // Update the document’s character order
            adventureDoc.characterDocuments = characters;

            // Refresh UI
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
            //[windowController handleCharacterChanges]; // replaced with above

            return YES;
        }
    }

    return NO;
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    NSLog(@"DSACharacterPortraitView: draggingSourceOperationMaskForLocal: %@", isLocal ? @"YES" : @"NO");

    // If the drag is within the same app, return NSDragOperationMove
    if (isLocal) {
        return NSDragOperationMove; // Move is typical for inventory management
    }

    // If the drag is external (e.g., to another app), allow Copy
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([pboard availableTypeFromArray:@[DSACharacterDragType]]) {
        return NSDragOperationMove; // Allow moving characters
    }
    
    return NSDragOperationNone;
}

// Indicate we accept the drop (this is required)
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES; // Always return YES to accept the drop
}



// Cleanup after drop (optional)
- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"Drag operation completed");
}

- (NSString *)toolTip {
    NSLog(@"DSACharacterPortraitView toolTip called");
    // Check if we have a valid characterDocument and its model
    if (self.characterDocument && self.characterDocument.model) {
        DSACharacter *character = self.characterDocument.model;
        
        // Format the tooltip text with the character's name and values
        NSString *toolTipText = [NSString stringWithFormat:
            @"%@\n"
            @"LE: %ld/%ld\n"
            @"AE: %ld/%ld\n"
            @"KE: %ld/%ld",
            character.name, // Character's name
            character.currentLifePoints, character.lifePoints, // Life Points
            character.currentAstralEnergy, character.astralEnergy, // Astral Energy
            character.currentKarmaPoints, character.karmaPoints]; // Karma Points
        
        return toolTipText;
    }
    
    return @"";
}

- (void)highlightTargetView:(BOOL)highlight {

    NSColor *highlightColor = highlight ? [NSColor greenColor] : [NSColor clearColor];

    // Remove existing highlight view if any
    if (self.highlightView) {
        [self.highlightView removeFromSuperview];
        self.highlightView = nil;
    }

    if (highlight) {
        // Create a new highlight view
        self.highlightView = [[NSBox alloc] initWithFrame:self.bounds];
        self.highlightView.boxType = NSBoxCustom;
        self.highlightView.borderType = NSLineBorder;
        self.highlightView.borderColor = highlightColor;
        self.highlightView.borderWidth = 2.0;
        self.highlightView.fillColor = [NSColor clearColor]; // Transparent fill
        self.highlightView.title = nil;
        self.highlightView.titlePosition = NSNoTitle;
        
        [self addSubview:self.highlightView positioned:NSWindowAbove relativeTo:nil];
    }
}


// Ugly hack to fade out the character portraits
// for some reason, setting alphaValue alone doesn't work
// ChatGPT suggested to use fadeFraction as a separate property instead of 
// misusing alphaValue as I do here
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
        NSRect insetRect = NSMakeRect(
            self.bounds.origin.x + 1,                      // Left inset 1px
            self.bounds.origin.y + 2,                      // Top inset 1px
            self.bounds.size.width - (1 + 2),              // width - left(1) - right(2)
            self.bounds.size.height - (1 + 2)              // height - bottom(1) - top(2)
        );
    if (self.image) {
        [self.image drawInRect:insetRect
                      fromRect:NSZeroRect
                     operation: NSCompositeSourceOver
                      fraction:1.0];

        if (self.alphaValue < 1.0) {
            [[NSColor colorWithCalibratedWhite:1.0 alpha:(1.0 - self.alphaValue)] set];
            NSRectFillUsingOperation(insetRect, NSCompositeSourceOver);
        }
    }
}

/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if (self.image) {
        [self.image drawInRect:self.bounds
                      fromRect:NSZeroRect
                     operation: NSCompositeSourceOver
                      fraction:self.alphaValue
                respectFlipped:YES
                         hints:nil];
    }
}
*/
@end