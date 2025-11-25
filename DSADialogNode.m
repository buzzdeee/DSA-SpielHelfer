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
#import "DSAActionResult.h"

@implementation DSADialogNode

+ (nullable instancetype)nodeFromDictionary:(NSDictionary *)dict {
    if (dict[@"skillCheckAll"]) {
        NSLog(@"DSADialogNode nodeFromDictionary going to return DSADialogNodeSkillCheckAll");
        DSADialogNodeSkillCheckAll *node = [DSADialogNodeSkillCheckAll new];
        [node setupWithDictionary:dict];
        return node;
    } else if (dict[@"skillCheck"]) {
        NSLog(@"DSADialogNode nodeFromDictionary going to return DSADialogNodeSkillCheck");
        DSADialogNodeSkillCheck *node = [DSADialogNodeSkillCheck new];
        [node setupWithDictionary:dict];
        return node;
    } else if (dict[@"playerOptions"]) {
        NSLog(@"DSADialogNode nodeFromDictionary going to return DSADialogNodeOption");
        DSADialogNodeOption *node = [DSADialogNodeOption new];
        [node setupWithDictionary:dict];
        return node;
    } else {
        NSLog(@"DSADialogNode nodeFromDictionary going to return plain DSADialogNode");
        DSADialogNode *node = [DSADialogNode new];
        [node setupWithDictionary:dict];
        return node;
    }
}

- (void) setupWithDictionary:(NSDictionary *)dict {
    NSLog(@"DSADialogNode setupWithDictionary dict: %@", dict);

    _nodeID = dict[@"id"];

    NSString *region = dict[@"imageRegion"];
    NSString *gender = dict[@"imageGender"];
    
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    DSAPosition *currentPosition = activeGroup.position;
    NSString *seed = currentPosition.description;
    
    NSString *thumbKey = dict[@"thumbnailImage"];
    if (thumbKey)
      {
        _thumbnailImageName = [Utils randomImageNameForKey: thumbKey
                                            withSizeSuffix: @"128x128"
                                                 forRegion: region
                                                    gender: gender
                                                seedString: seed];
       }
    NSLog(@"DSADialogNode setupWithDictionary: thumbnailImageName: %@", _thumbnailImageName);   
    NSString *mainKey = dict[@"mainImage"];   
    if (mainKey)
      {
        NSLog(@"DSADialogNode going to look for mainImage without size suffix");
        _mainImageName = [Utils randomImageNameForKey: mainKey
                                       withSizeSuffix: nil
                                            forRegion: region
                                               gender: gender
                                           seedString: seed];
       }    
    NSLog(@"DSADialogNode setupWithDictionary: mainImageName: %@", _mainImageName);
       
    _texts = dict[@"texts"];
    NSLog(@"DSADialogNode setupWithDictionary: texts: %@", _texts);
    _title = dict[@"title"];
    _nodeDescription = dict[@"description"];
    _hintCategory = dict[@"hintCategory"];
    _duration = [dict[@"duration"] integerValue];
    _endEncounter = [dict[@"endEncounter"] boolValue];

//    if (!node.nodeDescription) {
//        node.nodeDescription = @"Ihr untersucht die Umgebung genauer...";
//    }    
    
    NSLog(@"DSADialogNode nodeFromDictionary returning node: %@", self);
}

- (NSString *)randomText {
    NSLog(@"DSADialogNode selecting random text from texts: %@", self.texts);
    if (self.texts.count == 0) {
        return @"...";
    }
    NSUInteger index = arc4random_uniform((uint32_t)self.texts.count);
    return self.texts[index];
}

@end


@implementation DSADialogNodeOption

- (void)setupWithDictionary:(NSDictionary *)dict {

    // Basisdaten laden
    [super setupWithDictionary:dict];

    NSArray *optionsArray = dict[@"playerOptions"];
    NSMutableArray *parsed = [NSMutableArray array];

    for (NSDictionary *optDict in optionsArray) {
        DSADialogOption *opt = [DSADialogOption optionFromDictionary:optDict];
        if (opt) [parsed addObject:opt];
    }

    _playerOptions = parsed.copy;
}

@end

@implementation DSADialogNodeSkillCheck
- (void)setupWithDictionary:(NSDictionary *)dict {
    [super setupWithDictionary:dict];
    NSDictionary *check = dict[@"skillCheck"];
    
    _talent = check[@"talent"];
    _penalty = [check[@"penalty"] integerValue];
    _successNodeID = check[@"successNode"];
    _failureNodeID = check[@"failureNode"];
    _failureEffect = check[@"failureEffect"];
    _successEffect = check[@"successEffect"];
    self.duration = [check[@"duration"] integerValue];    
}

- (NSString *)performSkillCheck
{
    DSAAdventure *adv = [DSAAdventureManager sharedManager].currentAdventure;
    DSACharacter *character = [adv.activeGroup characterWithBestTalentWithName:self.talent negate:NO];

    DSAActionResult *result = [character useTalent:self.talent withPenalty:self.penalty];
    // return next node based on result
    return (result.result == DSAActionResultSuccess ||
            result.result == DSAActionResultEpicSuccess ||
            result.result == DSAActionResultAutoSuccess)
            ? self.successNodeID : self.failureNodeID;
}
@end

@implementation DSADialogNodeSkillCheckAll
- (void)setupWithDictionary:(NSDictionary *)dict {
    [super setupWithDictionary:dict];
    NSDictionary *checkAll = dict[@"skillCheckAll"];
    _partialFailureNodeID = checkAll[@"partialFailureNode"];

    NSString *mode = checkAll[@"successMode"];
    if (mode && [mode isKindOfClass:[NSString class]]) {
        _successMode = mode;
    } else {
        // Default fallback
        _successMode = @"all";
    }
}

- (NSString *)performSkillCheck
{
    DSAAdventure *adv = [DSAAdventureManager sharedManager].currentAdventure;
    NSArray<DSACharacter *> *members = adv.activeGroup.allCharacters;

    NSInteger total = members.count;
    NSInteger successes = 0;
    NSInteger failures = 0;

    BOOL someoneSucceeded = NO;

    NSMutableSet *testedCharacters = [NSMutableSet set];

    BOOL (^isSuccess)(DSAActionResult *) = ^BOOL(DSAActionResult *res) {
        return (res.result == DSAActionResultSuccess ||
                res.result == DSAActionResultEpicSuccess ||
                res.result == DSAActionResultAutoSuccess);
    };

    //
    // MODE: "first done"
    //
    if ([self.successMode isEqualToString:@"first done"]) {

        for (DSACharacter *c in members) {

            DSAActionResult *res = [c useTalent:self.talent withPenalty:self.penalty];
            [testedCharacters addObject:c];

            if (isSuccess(res)) {
                // Erfolg -> sofort Erfolg
                return self.successNodeID;
            } else {
                // Fehlschlag -> weitermachen
            }
        }

        // Wenn keiner Erfolg hatte → kompletter Fehlschlag
        return self.failureNodeID;
    }

    //
    // MODE: "any"
    //
    if ([self.successMode isEqualToString:@"any"]) {

        for (DSACharacter *c in members) {

            DSAActionResult *res = [c useTalent:self.talent withPenalty:self.penalty];
            [testedCharacters addObject:c];

            if (isSuccess(res)) {
                someoneSucceeded = YES;
            }
        }

        if (someoneSucceeded) {
            return self.successNodeID;
        } else {
            return self.failureNodeID;
        }
    }

    //
    // MODE: "all"
    //
    if ([self.successMode isEqualToString:@"all"]) {

        for (DSACharacter *c in members) {

            DSAActionResult *res = [c useTalent:self.talent withPenalty:self.penalty];
            [testedCharacters addObject:c];

            if (isSuccess(res)) {
                successes++;
            } else {
                failures++;
            }
        }

        if (successes == total) {
            return self.successNodeID;
        } else {
            return self.failureNodeID;
        }
    }

    //
    // MODE: "majority"
    //
    if ([self.successMode isEqualToString:@"majority"]) {

        NSInteger half = total / 2;   // Bei 3 Leuten → 1, Majority = >1

        for (DSACharacter *c in members) {

            DSAActionResult *res = [c useTalent:self.talent withPenalty:self.penalty];
            [testedCharacters addObject:c];

            if (isSuccess(res)) {
                successes++;
            } else {
                failures++;
            }

            // Frühabbruch optimiert:
            if (successes > half) {
                return self.successNodeID;
            }
            if (failures > half) {
                return self.failureNodeID;
            }
        }

        // Falls exakt Gleichstand (bei gerader Zahl)
        // ist majority nicht erreicht
        if (successes > failures) {
            return self.successNodeID;
        } else {
            return self.failureNodeID;
        }
    }

    //
    // Default fallback
    //
    return self.failureNodeID;
}

@end