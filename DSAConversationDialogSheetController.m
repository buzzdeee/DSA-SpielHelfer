/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-11 20:56:19 +0200 by sebastia

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

#import "DSAConversationDialogSheetController.h"
#import "DSADialogManager.h"
#import "DSADialog.h"
#import "DSADialogNode.h"
#import "DSADialogOption.h"

@interface DSAConversationDialogSheetController ()

@property (nonatomic, strong) DSADialogManager *dialogManager;
@property (nonatomic, strong) NSTextField *npcTextField;
@property (nonatomic, strong) NSView *optionsContainer;

@end

@implementation DSAConversationDialogSheetController

- (instancetype)initWithDialogManager:(DSADialogManager *)dialogManager {
    self = [super initWithWindow:nil];
    if (self) {
        _dialogManager = dialogManager;
        [self createDialogWindow];
        [self updateUIForCurrentNode];
    }
    return self;
}

- (DSADialogNode *)currentNode {
    return [self.dialogManager.currentDialog.nodes objectForKey:self.dialogManager.currentNodeID];
}

- (void)createDialogWindow {
    NSRect frame = NSMakeRect(0, 0, 500, 400);
    NSPanel *panel = [[NSPanel alloc] initWithContentRect:frame
                                                 styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO];
    [panel setTitle:@"Gespräch"];
    
    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    [panel setContentView:contentView];

    // NPC text area
/*    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 260, 480, 130)];
    [scrollView setHasVerticalScroller:YES];

    self.npcTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 480, 130)];
    [self.npcTextField setEditable:NO];
    [scrollView setDocumentView:self.npcTextField]; */
    
    self.npcTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 260, 480, 130)];
    [self.npcTextField setEditable:NO];
    [self.npcTextField setBordered:NO];                        // ⬅️ Kein Rahmen
    [self.npcTextField setDrawsBackground:NO];                // ⬅️ Kein weißer Hintergrund
    [self.npcTextField setSelectable:NO];                     // Optional, wenn du keine Textauswahl willst
    [self.npcTextField setBezeled:NO];                        // ⬅️ Kein Innenrahmen
    [self.npcTextField setBackgroundColor:[NSColor clearColor]]; // ⬅️ Hintergrund transparent (zur Sicherheit)    
    
    [contentView addSubview:self.npcTextField];

    // Player option buttons container
    self.optionsContainer = [[NSView alloc] initWithFrame:NSMakeRect(10, 50, 480, 200)];
    [contentView addSubview:self.optionsContainer];

    // Close button below options
    NSButton *closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 80, 30)];
    [closeButton setTitle:@"Schließen"];
    [closeButton setButtonType:NSMomentaryPushInButton];
    //[closeButton setBezelStyle:NSRoundedBezelStyle];
    [closeButton setTarget:self];
    [closeButton setAction:@selector(closeSheet:)];
    [contentView addSubview:closeButton];

    [self setWindow:panel];
}

- (void)updateUIForCurrentNode {
    DSADialogNode *node = [self.dialogManager currentNode];
    NSLog(@"DSAConversationDialogSheetController updateUIForCurrentNode current node.nodeID: %@", node.nodeID);
    if (!node) {
        [self closeSheet:nil];
        return;
    }

    // Setze den NPC-Text
    self.npcTextField.stringValue = [node randomText];

    // Entferne alte Buttons
    for (NSView *subview in self.optionsContainer.subviews) {
        [subview removeFromSuperview];
    }

    NSUInteger index = 0;
    for (DSADialogOption *option in node.playerOptions) {
        NSArray *texts = option.textVariants ?: @[@"[...]"];
        NSString *buttonTitle = texts.count > 0 ? texts[arc4random_uniform((uint32_t)texts.count)] : @"[...]";

        // Klassische NSButton-Erzeugung (GNUstep-kompatibel)
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 300, 30)];
        [button setTitle:buttonTitle];
        [button setTarget:self];
        [button setAction:@selector(optionClicked:)];
        [button setTag:index];
        //[button setBezelStyle:NSRoundedBezelStyle]; // ggf. anpassen für GNUstep

        // Positionierung: Einfach vertikal gestapelt
        CGFloat buttonY = self.optionsContainer.bounds.size.height - ((index + 1) * 40);
        [button setFrame:NSMakeRect(0, buttonY, self.optionsContainer.bounds.size.width, 30)];

        [self.optionsContainer addSubview:button];
        index++;
    }
}

- (void)optionClicked:(NSButton *)sender {
    NSUInteger index = sender.tag;

    [self.dialogManager advanceToNextNodeForOptionAtIndex:index];

    [self updateUIForCurrentNode];
}

- (void)closeSheet:(id)sender {
    // GNUstep hat kein endSheet:, wir schließen einfach das Panel
    [self.window orderOut:nil];
    [self.window close];
}

@end