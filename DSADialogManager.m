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
#import "DSAExecutionManager.h"

@implementation DSADialogManager

static DSADialogManager *_sharedManager = nil;

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        _sharedManager = [[self alloc] initPrivate];
    }
    return _sharedManager;
}

// private init, verhindert externen Init-Aufruf
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _currentNodeID = nil;
        _currentDialog = nil;
        _accumulatedDuration = 0;
        _lastSkillCheckSuccess = nil;
        _lastSkillCheckFailure = nil;
        _lastSkillCheckNode = nil;
    }
    return self;
}

// override default init, um Missbrauch zu verhindern
- (instancetype)init {
    [NSException raise:@"Singleton" format:@"Use +[DSADialogManager sharedManager]"];
    return nil;
}

- (BOOL)loadDialogFromFile:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    //NSLog(@"DSADialogManager loadDialogFromFile: %@ BEGIN", filename);
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
    //NSLog(@"DSADialogManager loadDialogFromFile: self.currentDialog: %@", self.currentDialog);
    NSArray *startNodes = dict[@"startNodes"];
    // random start node
    if (startNodes && startNodes.count > 0) {
        self.currentNodeID = startNodes[arc4random_uniform((uint32_t)startNodes.count)];
    } else {
        self.currentNodeID = self.currentDialog.startNodeID;
    }

    self.accumulatedDuration = 0;
    
    // reset skillcheck tracking
    _lastSkillCheckSuccess = nil;
    _lastSkillCheckFailure = nil;
    _lastSkillCheckNode = nil;    
    
    //NSLog(@"DSADialogManager loadDialogFromFile: %@ currentNodeID: %@ FINISHED", filename, self.currentNodeID);
    return YES;
}

- (DSADialogNode *)currentNode {
    NSLog(@"DSADialogManager currentNode:  was called ID: %@", self.currentNodeID);
    //NSLog(@"DSADialogManager currentNode: currentDialog: %@", self.currentDialog);
    return [self.currentDialog nodeForID: self.currentNodeID];
}

- (void)presentCurrentNode {
    //NSLog(@"DSADialogManager presentCurrentNode: currentNode: %@", [self currentNode]);
    DSADialogNode *node = [self currentNode];
    if (!node) {
        NSLog(@"DSADialogManager presentCurrentNode: Kein Knoten gefunden für ID: %@, aborting", self.currentNodeID);
        abort();
        return;
    }
    
    if ([node isKindOfClass: [DSADialogNodeSkillCheck class]] && !self.skillCheckPending) {
        DSADialogNodeSkillCheck *skillCheckNode = (DSADialogNodeSkillCheck *)node;
        self.skillCheckPending = YES;
        //NSLog(@"DSADialogManager presentCurrentNode: we're on a DSADialogNodeSkillCheck node: %@", self.currentNodeID);
        // Beschreibung dynamisch ersetzen
        NSString *text = skillCheckNode.nodeDescription ?: @"";
        DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
        DSACharacter *character = [adventure.activeGroup characterWithBestCheckType:skillCheckNode.checkType
                                                                          checkName: skillCheckNode.checkName
                                                                             negate:NO];
        //NSLog(@"DSADialogManager presentCurrentNode: we're on a DSADialogNodeSkillCheck node, acting character: %@", character.name);
        if (character) {
            self.currentDialog.actingCharacter = character;
            if ([text containsString:@"%@"]) {
                skillCheckNode.nodeDescription = [NSString stringWithFormat:text, character.name];
            }
        }
        return; // UI zeigt den SkillCheck-Node an, ohne den Check auszuführen
    }    
    // Dauer aufsummieren
    self.accumulatedDuration += node.duration;
    //NSLog(@"DSADialogManager presentCurrentNode: currentNode: %@", node);
    // Text aus description oder npcTexts
    NSString *text = node.nodeDescription ?: [node randomText];
    if ([text containsString:@"%@"]) {
        node.nodeDescription = [NSString stringWithFormat:text, self.currentDialog.actingCharacter.name];
    }    
    //NSLog(@"DSADialogManager presentCurrentNode: npcName %@: characterName: %@ text: %@", self.currentDialog.npcName, self.currentDialog.actingCharacter.name, text);
    NSLog(@"DSADialogManager presentCurrentNode: %@ checking for node.actions.count > 0", node.nodeID);
    if (node.actions.count > 0) {
        NSLog(@"DSADialogManager presentCurrentNode going to execute actions for node: %@", node.nodeID);
        [[DSAExecutionManager sharedManager] executeActions:node.actions];
    }
    
    
    // Wenn endEncounter -> Dialog beendet
    if (node.endEncounter) {
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
    // if DSADialogNodeSkillCheck or DSADialogNodeSkillCheckAll
    if ([node isKindOfClass: [DSADialogNodeSkillCheck class]])
      {
         skillCheckNode = (DSADialogNodeSkillCheck *)node;
      }
    else
      {
        NSLog(@"DSADialogManager performPendingSkillCheck expected a DSADialogNodeSkillCheck class but got: %@, aborting.", [node class]);
        abort();
      }

    NSString *nextID = [skillCheckNode performSkillCheck];

    // ✅ Ergebnisse sichern
    if ([skillCheckNode isKindOfClass:[DSADialogNodeSkillCheckAll class]]) {
        DSADialogNodeSkillCheckAll *all = (id)skillCheckNode;
        self.lastSkillCheckSuccess = all.successfulCharacters;
        self.lastSkillCheckFailure = all.failedCharacters;
    } else {
        // Einzelprobe => entweder success ODER failure
        DSACharacter *actor = self.currentDialog.actingCharacter;
        if ([nextID isEqualToString:skillCheckNode.successNodeID]) {
            self.lastSkillCheckSuccess = @[actor];
            self.lastSkillCheckFailure = @[];
        } else {
            self.lastSkillCheckSuccess = @[];
            self.lastSkillCheckFailure = @[actor];
        }
    }
    self.lastSkillCheckNode = skillCheckNode;
    self.currentNodeID = nextID;
    NSLog(@"DSADialogManager performPendingSkillCheck: nextID: %@", nextID);          
    node = [self currentNode];
    NSString *text = node.nodeDescription ?: [node randomText];
    if ([text containsString:@"%@"]) {
        node.nodeDescription = [NSString stringWithFormat:text, self.currentDialog.actingCharacter.name];
    }
}

@end