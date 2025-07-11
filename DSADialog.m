/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:51:01 +0200 by sebastia

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

#import "DSADialog.h"
#import "DSADialogNode.h"

@implementation DSADialog

+ (nullable instancetype)dialogFromJSONFile:(NSString *)filePath {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"Fehler: Konnte JSON-Datei nicht lesen: %@", filePath);
        return nil;
    }

    NSError *error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![jsonObj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Fehler beim Parsen der Datei %@: %@", filePath.lastPathComponent, error);
        return nil;
    }

    return [DSADialog dialogFromDictionary:(NSDictionary *)jsonObj];
}

+ (nullable instancetype)dialogFromDictionary:(NSDictionary *)dict {
    DSADialog *dialog = [[DSADialog alloc] init];

    dialog.npcName = dict[@"npcName"];
    dialog.startNodeID = dict[@"startNodeID"];
    
    NSDictionary *nodesDict = dict[@"nodes"];
    NSMutableDictionary *nodes = [NSMutableDictionary dictionary];
    
    for (NSString *nodeID in nodesDict) {
        NSLog(@"DSADialog dialogFromDictionary: nodeID: %@", nodeID);
        NSDictionary *nodeDict = nodesDict[nodeID];
        DSADialogNode *node = [DSADialogNode nodeFromDictionary:nodeDict];
        if (node) {
            nodes[nodeID] = node;
        }
    }
    dialog.nodes = [nodes copy];

    if (!dialog.npcName || !dialog.startNodeID) {
        NSLog(@"Warnung: Dialog JSON unvollständig");
        return nil;
    }

    return dialog;
}

- (DSADialogNode *)nodeForID:(NSString *)nodeID {
    return self.nodes[nodeID];
}

@end
