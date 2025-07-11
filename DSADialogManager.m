/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-11 20:23:07 +0200 by sebastia

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

#import "DSADialogManager.h"
#import "DSADialog.h"
#import "DSADialogNode.h"
#import "DSAHintManager.h"
#import "DSADialogOption.h"

@implementation DSADialogManager

- (BOOL)loadDialogFromFile:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    if (!path) {
        NSLog(@"❌ Dialog-Datei nicht gefunden: %@", filename);
        return NO;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return NO;

    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"❌ JSON Fehler: %@", error);
        return NO;
    }

    NSLog(@"DSADialogManager loadDialogFromFile: dict: %@", dict);
    self.currentDialog = [DSADialog dialogFromDictionary:dict];
    self.currentNodeID = self.currentDialog.startNodeID;
    NSLog(@"DSADialogManager loadDialogFromFile: %@ currentNodeID: %@", filename, self.currentNodeID);
    return YES;
}

- (void)startDialog {
    [self presentCurrentNode];
}

- (DSADialogNode *)currentNode {
    return [self.currentDialog nodeForID:self.currentNodeID];
}

- (void)advanceToNextNodeForOptionAtIndex:(NSUInteger)index {
    DSADialogNode *node = [self currentNode];
    if (!node || index >= node.playerOptions.count) {
        NSLog(@"⚠️ Ungültige Auswahl.");
        return;
    }

    DSADialogOption *option = node.playerOptions[index];
    self.currentNodeID = option.nextNodeID;
}

- (void)presentCurrentNode {
    DSADialogNode *node = [self.currentDialog nodeForID:self.currentNodeID];
    NSLog(@"DSADialogManager presentCurrentNode: node %@, nodeID: %@", node, node.nodeID);
    if (!node) {
        NSLog(@"⚠️ Kein Knoten gefunden für ID: %@", self.currentNodeID);
        return;
    }

    NSString *npcLine = [node randomText];
    NSLog(@"\n💬 %@ sagt: \"%@\"", self.currentDialog.npcName, npcLine);

    if (node.hintCategory) {
        NSString *hint = [[DSAHintManager sharedInstance] randomHintForLocation:node.hintCategory];
        if (hint) {
            NSLog(@"🧭 Hinweis: %@", hint);
        } else {
            NSLog(@"Leider weiss ich nix zu sagen!");
        }
        
    }

    NSUInteger idx = 0;
    for (NSDictionary *option in node.playerOptions) {
        NSLog(@"DSADialogManager presentCurrentNode: option: %@", option);
        NSArray *texts = option[@"texts"];
        NSString *playerText = texts.count > 0 ? texts[arc4random_uniform((uint32_t)texts.count)] : @"[...]";
        NSLog(@"%lu: %@", (unsigned long)idx, playerText);
        idx++;
    }

    if (node.playerOptions.count == 0) {
        NSLog(@"🏁 Dialog beendet.");
    }
}

- (void)handlePlayerSelectionAtIndex:(NSUInteger)index {
    DSADialogNode *node = [self.currentDialog nodeForID:self.currentNodeID];
    NSLog(@"DSADialogManager handlePlayerSelectionAtIndex %lu, node.playerOptions.count %lu, node: %@", index, node.playerOptions.count, node);
    if (!node || index >= node.playerOptions.count) {
        NSLog(@"⚠️ Ungültige Auswahl.");
        return;
    }

    DSADialogOption *option = node.playerOptions[index];
    NSLog(@"DSADialogManager handlePlayerSelectionAtIndex %lu nextNodeID: %@", (long unsigned)index, option.nextNodeID);
    NSString *nextID = option.nextNodeID;
    self.currentNodeID = nextID;
    [self presentCurrentNode];
}

@end