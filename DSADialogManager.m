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
#import "DSAAdventure.h"
#import "DSAActionResult.h"
#import "DSAAdventureGroup.h"
#import "DSAAdventureClock.h"


@implementation DSADialogManager

- (BOOL)loadDialogFromFile:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSLog(@"DSADialogManager loadDialogFromFile: %@ BEGIN", filename);
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

    self.currentDialog = [DSADialog dialogFromDictionary:dict];
    NSLog(@"DSADialogManager loadDialogFromFile: self.currentDialog: %@", self.currentDialog);
    NSArray *startNodes = dict[@"startNodes"];
    if (startNodes && startNodes.count > 0) {
        self.currentNodeID = startNodes[arc4random_uniform((uint32_t)startNodes.count)];
    } else {
        self.currentNodeID = self.currentDialog.startNodeID;
    }

    self.accumulatedDuration = 0;
    NSLog(@"DSADialogManager loadDialogFromFile: %@ currentNodeID: %@ FINISHED", filename, self.currentNodeID);
    return YES;
}

- (DSADialogNode *)currentNode {
    NSLog(@"DSADialogManager currentNode:  was called ID: %@", self.currentNodeID);
    NSLog(@"DSADialogManager currentNode: currentDialog: %@", self.currentDialog);
    return [self.currentDialog nodeForID: self.currentNodeID];
}

- (void)presentCurrentNode {
    NSLog(@"DSADialogManager presentCurrentNode: currentNode: %@", [self currentNode]);
    DSADialogNode *node = [self currentNode];
    if (!node) {
        NSLog(@"DSADialogManager presentCurrentNode: Kein Knoten gefunden für ID: %@", self.currentNodeID);
        return;
    }
    
    if ([node isMemberOfClass: [DSADialogNodeSkillCheck class]] && !self.skillCheckPending) {
        DSADialogNodeSkillCheck *skillCheckNode = (DSADialogNodeSkillCheck *)node;
        self.skillCheckPending = YES;

        // Beschreibung dynamisch ersetzen
        NSString *text = skillCheckNode.nodeDescription ?: @"";
        DSACharacter *character = [[DSAAdventureManager sharedManager].currentAdventure.activeGroup 
                                  characterWithBestTalentWithName: skillCheckNode.talent negate:NO];

        if (character) {
            self.currentDialog.actingCharacterName = character.name;
            if ([text containsString:@"%@"]) {
                skillCheckNode.nodeDescription = [NSString stringWithFormat:text, character.name];
            }
        }

        return; // UI zeigt den SkillCheck-Node an, ohne den Check auszuführen
    }    
    // Dauer aufsummieren
    self.accumulatedDuration += node.duration;
    NSLog(@"DSADialogManager presentCurrentNode: currentNode: %@", node);
    // Text aus description oder npcTexts
    NSString *text = node.nodeDescription ?: [node randomText];
    if ([text containsString:@"%@"]) {
        node.nodeDescription = [NSString stringWithFormat:text, self.currentDialog.actingCharacterName];
    }    
    NSLog(@"DSADialogManager presentCurrentNode: npcName %@: characterName: %@ text: %@", self.currentDialog.npcName, self.currentDialog.actingCharacterName, text);

    // PlayerOptions anzeigen
    if ([node isMemberOfClass: [DSADialogNodeSkillCheck class]])
      {
        NSUInteger idx = 0;
        DSADialogNodeOption *optionNode = (DSADialogNodeOption*) node;
        for (DSADialogOption *option in optionNode.playerOptions) {
       
            NSArray *texts = option.textVariants;
            NSString *playerText = texts.count > 0 ? texts[arc4random_uniform((uint32_t)texts.count)] : @"[...]";
            NSLog(@"DSADialogManager presentCurrentNode XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX: index: %lu: playerText: %@", (unsigned long)idx, playerText);
            idx++;
        }
      }
    NSLog(@"DSADialogManager presentCurrentNode: AFTER OPTION LOOP npcName %@: characterName: %@ text: %@", self.currentDialog.npcName, self.currentDialog.actingCharacterName, text);
    // Wenn keine Optionen und endEncounter -> Dialog beendet
    if (![node isMemberOfClass: [DSADialogNodeSkillCheck class]] && node.endEncounter) {
        NSLog(@"DSADialogManager presentCurrentNode: Ende des Encounters. Drehe die Uhr vor, Gesamtdauer: %ld Minuten", (long)self.accumulatedDuration);

        // GameClock aktualisieren
        DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
        [adventure.gameClock advanceTimeByMinutes:self.accumulatedDuration sendNotification: YES];
    }
}

- (void)performPendingSkillCheck {
    self.skillCheckPending = NO;

    DSADialogNode *node = [self currentNode];
    DSADialogNodeSkillCheck *skillCheckNode;
    if ([node isMemberOfClass: [DSADialogNodeSkillCheck class]])
      {
         skillCheckNode = (DSADialogNodeSkillCheck *)node;
      }
    else
      {
        NSLog(@"DSADialogManager performPendingSkillCheck expected a DSADialogNodeSkillCheck class but got: %@, aborting.", [node class]);
        abort();
      }

    NSString *talent = skillCheckNode.talent;
    NSInteger penalty = skillCheckNode.penalty;
    NSString *successNode = skillCheckNode.successNodeID;
    NSString *failureNode = skillCheckNode.failureNodeID;

    DSAAdventure *adv = [DSAAdventureManager sharedManager].currentAdventure;
    DSACharacter *character = [adv.activeGroup characterWithBestTalentWithName:talent negate:NO];

    DSAActionResult *result = [character useTalent:talent withPenalty:penalty];
    // advance to next node, and set nodeDescription string accordingly
    self.currentNodeID = (result.result == DSAActionResultSuccess ||
                          result.result == DSAActionResultEpicSuccess ||
                          result.result == DSAActionResultAutoSuccess)
                            ? successNode : failureNode;
    node = [self currentNode];  
    NSString *text = node.nodeDescription ?: [node randomText];
    if ([text containsString:@"%@"]) {
        node.nodeDescription = [NSString stringWithFormat:text, self.currentDialog.actingCharacterName];
    }    
}

/*
- (void)handlePlayerSelectionAtIndex:(NSUInteger)index {
    NSLog(@"DSADialogManager handlePlayerSelectionAtIndex: called.");
    DSADialogNode *node = [self currentNode];
    if (!node || index >= node.playerOptions.count) {
        NSLog(@"DSADialogManager handlePlayerSelectionAtIndex: Ungültige Auswahl.");
        return;
    }

    DSADialogOption *option = node.playerOptions[index];
    NSString *nextNodeID = option.nextNodeID;
    NSInteger duration = option.duration;
    
    // Dauer hinzufügen
    self.accumulatedDuration += duration;

    self.currentNodeID = nextNodeID;
    [self presentCurrentNode];
}
*/
@end