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

@implementation DSADialogNode

+ (instancetype)nodeFromDictionary:(NSDictionary *)dict {
    DSADialogNode *node = [[DSADialogNode alloc] init];
    node.nodeID = dict[@"id"];
    node.hintCategory = dict[@"hintCategory"];
    NSArray *textsArray = dict[@"npcTexts"];
    if ([textsArray isKindOfClass:[NSArray class]]) {
        node.texts = textsArray;
    } else if ([dict[@"npcTexts"] isKindOfClass:[NSString class]]) {
        node.texts = @[dict[@"npcTexts"]];
    } else {
        node.texts = @[@"..."];
    }
    
    NSArray *optionsArray = dict[@"playerOptions"];
    NSMutableArray *optionsMutable = [NSMutableArray array];
    for (NSDictionary *optDict in optionsArray) {
        DSADialogOption *option = [DSADialogOption optionFromDictionary:optDict];
        if (option) {
            [optionsMutable addObject:option];
        }
    }
    node.playerOptions = optionsMutable;
    
    return node;
}

- (NSString *)randomText {
    if (self.texts.count == 0) {
        return @"...";
    }
    NSUInteger index = arc4random_uniform((uint32_t)self.texts.count);
    return self.texts[index];
}

@end
