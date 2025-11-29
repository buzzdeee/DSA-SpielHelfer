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

#ifndef _DSADIALOGNODE_H_
#define _DSADIALOGNODE_H_

#import "DSABaseObject.h"
@class DSADialogOption;
@class DSAActionDescriptor;
@class DSACharacter;

NS_ASSUME_NONNULL_BEGIN
@interface DSADialogNode : DSABaseObject

@property (nonatomic, strong) NSString *nodeID;
@property (nonatomic, strong, nullable) NSString *nextNodeID;
@property (nonatomic, strong) NSString *thumbnailImageName;
@property (nonatomic, strong) NSString *mainImageName;
@property (nonatomic, strong, nullable) NSString *title;                    // start nodes have a title, to "describe" the dialog
@property (nonatomic, strong) NSArray<NSString *> *texts;
@property (nonatomic, strong, nullable) NSString *hintCategory;
@property (nonatomic) NSInteger duration;  // in minutes
@property (nonatomic) BOOL endEncounter;
@property (nonatomic, strong, nullable) NSString *nodeDescription;
@property (nonatomic, strong, nullable) NSArray<DSAActionDescriptor *> *actions;  // eventual actions for the node

+ (nullable instancetype)nodeFromDictionary:(NSDictionary *)dict;
- (void)setupWithDictionary:(NSDictionary *)dict;

- (NSString *)randomText;

@end

@interface DSADialogNodeOption : DSADialogNode

@property (nonatomic, strong) NSArray<DSADialogOption *> *playerOptions;

@end

@interface DSADialogNodeSkillCheck: DSADialogNode

@property (nonatomic) NSInteger penalty;
@property (nonatomic, strong) NSString *successNodeID;
@property (nonatomic, strong) NSString *failureNodeID;
@property (nonatomic, strong) NSString *checkType;            // "talent" oder "attribute"
@property (nonatomic, strong) NSString *checkName;            // Talentname oder Attributname (i.e. KK, TA, etc.)
// returns NextNodeID
- (NSString *)performSkillCheck;

@end

@interface DSADialogNodeSkillCheckAll: DSADialogNodeSkillCheck
@property (nonatomic, strong) NSString *partialFailureNodeID;
@property (nonatomic, strong) NSString *successMode; // "all", "any", "first done", "majority"
@property (nonatomic, strong, readonly) NSArray<DSACharacter *> *successfulCharacters;
@property (nonatomic, strong, readonly) NSArray<DSACharacter *> *failedCharacters;
@end

NS_ASSUME_NONNULL_END
#endif // _DSADIALOGNODE_H_

