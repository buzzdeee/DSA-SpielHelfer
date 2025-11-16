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
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"
#import "DSAActionResult.h"

@interface DSAConversationDialogSheetController ()

@property (nonatomic, strong) DSADialogManager *dialogManager;
@property (nonatomic, strong) NSTextField *npcTextField;
@property (nonatomic, strong) NSView *optionsContainer;
@property (nonatomic, strong) NSButton *continueButton;
@property (nonatomic, strong) NSPanel *panel;
@property (nonatomic, strong) NSImageView * thumbnailImageView;

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
    self.panel = [[NSPanel alloc] initWithContentRect:frame
                                             styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
    [self.panel setTitle:@"Gespräch"];
    
    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    [self.panel setContentView:contentView];

    //
    // 🟦 Thumbnail oben links
    //
    self.thumbnailImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 260, 128, 128)];
    self.thumbnailImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    [self.thumbnailImageView setImage:nil];            // no image by default
    [contentView addSubview:self.thumbnailImageView];

    //
    // 🟨 NPC Text rechts daneben
    // (angepasst: 10px rechts vom Bild)
    //
    self.npcTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(148, 260, 342, 130)];
    [self.npcTextField setEditable:NO];
    [self.npcTextField setBordered:NO];
    [self.npcTextField setDrawsBackground:NO];
    [self.npcTextField setSelectable:NO];
    [self.npcTextField setBezeled:NO];
    [self.npcTextField setBackgroundColor:[NSColor clearColor]];
    
    [contentView addSubview:self.npcTextField];

    //
    // 🟩 Player Options Container
    //
    self.optionsContainer = [[NSView alloc] initWithFrame:NSMakeRect(10, 50, 480, 200)];
    [contentView addSubview:self.optionsContainer];

    //
    // 🟥 Continue Button
    //
    CGFloat buttonWidth = 100;
    CGFloat buttonHeight = 30;
    CGFloat margin = 10;
    CGFloat buttonX = contentView.bounds.size.width - buttonWidth - margin;
    CGFloat buttonY = margin;

    NSButton *closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(buttonX, buttonY, buttonWidth, buttonHeight)];
    
    [closeButton setButtonType:NSMomentaryPushInButton];
    [closeButton setTarget:self];
    [closeButton setAction:@selector(continueButtonPressed:)];
    [contentView addSubview:closeButton];

    self.continueButton = closeButton;

    [self setWindow:self.panel];
}


- (void)updateUIForCurrentNode {
    NSLog(@"DSAConversationDialogSheetController updateUIForCurrentNode called!");
    DSADialogNode *node = [self.dialogManager currentNode];
    NSLog(@"DSAConversationDialogSheetController updateUIForCurrentNode current node %@", node);
    if (!node) {
        NSLog(@"DSAConversationDialogSheetController updateUIForCurrentNode no node, closing sheet");
        [self closeSheet:nil];
        return;
    }
    
    if (node.title)
      {
          [self.panel setTitle: node.title];
      }

    // 🔹 Thumbnail wählen: Node → Dialog → Kein Bild
    NSString *thumbName = node.thumbnailImageName ?: self.dialogManager.currentDialog.thumbnailImageName;
    if (thumbName && thumbName.length > 0) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:thumbName ofType: nil];
        NSImage *img = [[NSImage alloc] initWithContentsOfFile:imagePath];
        if (img) {
            [self.thumbnailImageView setImage:img];
        } else {
            NSLog(@"DSAConversationDialogSheetController updateUIForCurrentNode: Thumbnail not found: %@", thumbName);
        }
        
    } else {
        NSLog(@"DSAConversationDialogSheetController updateUIForCurrentNode: no thumbnail image given");
    }      

    NSString *mainImageName = node.mainImageName ?: self.dialogManager.currentDialog.mainImageName;
    if (mainImageName && mainImageName.length > 0) {
        NSDictionary *userInfo = @{ @"imageName": mainImageName };
        [[NSNotificationCenter defaultCenter] postNotificationName: DSAUpdateMainImageViewNotification
                                                            object:self
                                                          userInfo:userInfo];        
    }    
          
    // Setze die Node-Beschreibung (TrailSigns: "description")
    self.npcTextField.stringValue = node.nodeDescription ?: [node randomText];

    if ((node.playerOptions.count == 0 && !node.endEncounter) || node.skillCheck) {
         [self.continueButton setTitle:@"Weiter"];
         [self.continueButton setHidden:NO];
    } else if (node.endEncounter) {
         [self.continueButton setTitle:@"Schließen"];
         [self.continueButton setAction:@selector(closeSheet:)];
         [self.continueButton setHidden:NO];      
    } else {
         [self.continueButton setHidden:YES];
    }    
    // Entferne alte Buttons
    for (NSView *subview in self.optionsContainer.subviews) {
        [subview removeFromSuperview];
    }

    if (node.skillCheck != nil) {
        NSLog(@"DSAConversationDialogSheetController updateUIForCurrentNode: SkillCheck Node – keine Buttons anzeigen, UI wartet auf automatische Weiterleitung.");
        return;
    }    
    
    if (node.endEncounter) {
        NSLog(@"EndEncounter erreicht. Encounter Dauer: %ld Minuten", (long)self.dialogManager.accumulatedDuration);
        return; // falls du sofort schließen willst, hier closeSheet:nil
    }
    
    NSUInteger index = 0;
    for (DSADialogOption *option in node.playerOptions) {
        NSArray *texts = option.textVariants ?: @[@"[...]"];
        NSString *buttonTitle = texts.count > 0 ? texts[arc4random_uniform((uint32_t)texts.count)] : @"[...]";

        // Button erstellen
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, self.optionsContainer.bounds.size.width, 30)];
        [button setTitle:buttonTitle];
        [button setTarget:self];
        [button setAction:@selector(optionClicked:)];
        [button setTag:index];

        // Position vertikal stapeln
        CGFloat buttonY = self.optionsContainer.bounds.size.height - ((index + 1) * 40);
        [button setFrame:NSMakeRect(0, buttonY, self.optionsContainer.bounds.size.width, 30)];

        [self.optionsContainer addSubview:button];
        index++;
    }
}

- (void)optionClicked:(NSButton *)sender {
    NSUInteger index = sender.tag;
    DSADialogNode *node = [self.dialogManager currentNode];
    DSADialogOption *option = node.playerOptions[index];
    NSLog(@"DSAConversationDialogSheetController optionClicked called option: %@", option);
    
    if (option.skillCheck) {
        NSLog(@"DSAConversationDialogSheetController optionClicked seems there was a skill check !!!!!!!!!!!!!!!!");
        NSString *talent = option.skillCheck[@"talent"];
        NSInteger penalty = [option.skillCheck[@"penalty"] integerValue];
        NSString *successNode = option.skillCheck[@"successNode"];
        NSString *failureNode = option.skillCheck[@"failureNode"];

        // Talentwurf durchführen (DSACharacter / DSAActionResult)
        DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
        DSACharacter *character = [adventure.activeGroup characterWithBestTalentWithName:talent negate:NO];
        DSAActionResult *result = [character useTalent:talent withPenalty:penalty];
        
        // Nächstes NodeID abhängig vom Ergebnis
        if (result.result == DSAActionResultSuccess || result.result == DSAActionResultEpicSuccess || result.result == DSAActionResultAutoSuccess) {
            NSLog(@"DSAConversationDialogSheetController optionClicked seems skill check was successful, continuing with successNode: %@", successNode);
            self.dialogManager.currentNodeID = successNode;
        } else {
            NSLog(@"DSAConversationDialogSheetController optionClicked seems skill check was NOT successful, continuing with failureNode: %@", failureNode);
            self.dialogManager.currentNodeID = failureNode;
        }
    } else {
        NSLog(@"DSAConversationDialogSheetController NO SKILL CHECK, continuing with nextNodeID: %@", option.nextNodeID);
        self.dialogManager.currentNodeID = option.nextNodeID;
        [self.dialogManager presentCurrentNode];
    }
    //[self.dialogManager presentCurrentNode];
    [self updateUIForCurrentNode];
}

- (void)continueButtonPressed:(id)sender {
    if (self.dialogManager.skillCheckPending) {
        NSLog(@"DSAConversationDialogSheetController continueButtonPressed going to trigger pending skill check");
        [self.dialogManager performPendingSkillCheck];
    }
    
    [self updateUIForCurrentNode];
}

- (void)closeSheet:(id)sender {
    // GNUstep hat kein endSheet:, wir schließen einfach das Panel
    [self.window orderOut:nil];
    [self.window close];
}

@end