/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:49:11 +0200 by sebastia

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

#import "DSADialogNode.h"
#import "DSADialogOption.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"
#import "Utils.h"

@implementation DSADialogNode

+ (nullable instancetype)nodeFromDictionary:(NSDictionary *)dict {
    if (dict[@"skillCheckAll"]) {
        DSADialogNodeSkillCheckAll *node = [DSADialogNodeSkillCheckAll new];
        [node setupWithDictionary:dict[@"skillCheckAll"]];
        [node setupCommonPropertiesWithDictionary:dict];
        return node;
    } else if (dict[@"skillCheck"]) {
        DSADialogNodeSkillCheck *node = [DSADialogNodeSkillCheck new];
        [node setupWithDictionary:dict[@"skillCheck"]];
        [node setupCommonPropertiesWithDictionary:dict];
        return node;
    } else {
        DSADialogNode *node = [DSADialogNode new];
        [node setupCommonPropertiesWithDictionary:dict];
        return node;
    }
}

- (void) setupCommonPropertiesWithDictionary:(NSDictionary *)dict {
    NSLog(@"DSADialogNode setupCommonPropertiesWithDictionary dict: %@", dict);
    DSADialogNode *node = [[DSADialogNode alloc] init];
    node.nodeID = dict[@"id"];

    NSString *region = dict[@"imageRegion"];
    NSString *gender = dict[@"imageGender"];
    
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;
    NSString *seed = currentPosition.description;
    
    NSString *thumbKey = dict[@"thumbnailImage"];
    if (thumbKey)
      {
        node.thumbnailImageName = [Utils randomImageNameForKey: thumbKey
                                                withSizeSuffix: @"128x128"
                                                     forRegion: region
                                                        gender: gender
                                                    seedString: seed];
       }
    NSLog(@"DSADialogNode dialogFromDictionary: thumbnailImageName: %@", node.thumbnailImageName);   
    NSString *mainKey = dict[@"mainImage"];   
    if (mainKey)
      {
        NSLog(@"DSADialogNode going to look for mainImage without size suffix");
        node.mainImageName = [Utils randomImageNameForKey: mainKey
                                           withSizeSuffix: nil
                                                forRegion: region
                                                   gender: gender
                                               seedString: seed];
       }    
    NSLog(@"DSADialogNode dialogFromDictionary: mainImageName: %@", node.mainImageName);
       
    node.texts = dict[@"texts"];
    node.title = dict[@"title"];
    node.nodeDescription = dict[@"description"];
    node.hintCategory = dict[@"hintCategory"];
    node.duration = [dict[@"duration"] integerValue];
    node.endEncounter = [dict[@"endEncounter"] boolValue];

    if (!node.nodeDescription) {
        node.nodeDescription = @"Ihr untersucht die Umgebung genauer...";
    }    
    
    NSMutableArray *options = [NSMutableArray array];
    for (NSDictionary *optDict in dict[@"playerOptions"]) {
        DSADialogOption *opt = [DSADialogOption optionFromDictionary:optDict];
        [options addObject:opt];
    }
    node.playerOptions = options;
    //NSLog(@"DSADialogNode nodeFromDictionary returning node: %@", node);
}

- (NSString *)randomText {
    if (self.texts.count == 0) {
        return @"...";
    }
    NSUInteger index = arc4random_uniform((uint32_t)self.texts.count);
    return self.texts[index];
}

@end

@implementation DSADialogNodeSkillCheck
- (void)setupWithDictionary:(NSDictionary *)dict {
    _talent = dict[@"talent"];
    _penalty = [dict[@"penalty"] integerValue];
    _successNodeID = dict[@"successNode"];
    _failureNodeID = dict[@"failureNode"];
    _failureEffect = dict[@"failureEffect"];
    _successEffect = dict[@"successEffect"];
    self.duration = [dict[@"duration"] integerValue];    
}

@end

@implementation DSADialogNodeSkillCheckAll
- (void)setupWithDictionary:(NSDictionary *)dict {
    // Erst die Basisklasse initialisieren
    [super setupWithDictionary:dict];
    
    // Spezifisches Feld für SkillCheckAll
    NSString *mode = dict[@"successMode"];
    if (mode && [mode isKindOfClass:[NSString class]]) {
        _successMode = mode;
    } else {
        // Default fallback
        _successMode = @"all";
    }
}
@end