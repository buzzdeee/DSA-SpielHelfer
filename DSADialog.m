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
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"
#import "Utils.h"

@implementation DSADialog
+ (nullable instancetype)dialogFromDictionary:(NSDictionary *)dict {
    DSADialog *dialog = [[DSADialog alloc] init];

    dialog.npcName = dict[@"npcName"];
    
    NSString *region = dict[@"imageRegion"];
    NSString *gender = dict[@"imageGender"];
    
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;
    NSString *seed = currentPosition.description;
    
    NSString *thumbKey = dict[@"thumbnailImage"];
    if (thumbKey)
      {
        dialog.thumbnailImageName = [Utils randomImageNameForKey: thumbKey
                                                  withSizeSuffix: @"128x128"
                                                       forRegion: region
                                                          gender: gender
                                                      seedString: seed];
       }
       
    //NSLog(@"DSADialog dialogFromDictionary: thumbnailImageName: %@", dialog.thumbnailImageName);
    NSString *mainKey = dict[@"mainImage"];   
    if (mainKey)
      {
        NSLog(@"DSADialog going to look for mainImage without size suffix");
        dialog.mainImageName = [Utils randomImageNameForKey: mainKey
                                             withSizeSuffix: nil
                                                  forRegion: region
                                                     gender: gender
                                                 seedString: seed];
       }
    //NSLog(@"DSADialog dialogFromDictionary: mainImageName: %@", dialog.mainImageName);          
    dialog.startNodeID = dict[@"startNodeID"];
    
    NSDictionary *nodesDict = dict[@"nodes"];
    NSMutableDictionary *nodes = [NSMutableDictionary dictionary];
    
    for (NSString *nodeID in nodesDict) {
        //NSLog(@"DSADialog dialogFromDictionary: nodeID: %@", nodeID);
        NSDictionary *nodeDict = nodesDict[nodeID];
        //NSLog(@"DSADialog dialogFromDictionary: got nodeDict from file: %@", nodeDict);
        DSADialogNode *node = [DSADialogNode nodeFromDictionary:nodeDict];
        //NSLog(@"DSADialog dialogFromDictionary adding node to Dialog: %@", node);
        if (node) {
            nodes[nodeID] = node;
        }
    }
    dialog.nodes = [nodes copy];
    //NSLog(@"DSADialog dialogFromDictionary created dialog with nodes: %@", dialog.nodes);
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
