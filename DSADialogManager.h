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

#ifndef _DSADIALOGMANAGER_H_
#define _DSADIALOGMANAGER_H_

#import "DSABaseObject.h"
@class DSADialog;
@class DSADialogNode;
@class DSACharacter;
@class DSADialogNodeSkillCheck;

NS_ASSUME_NONNULL_BEGIN
@interface DSADialogManager : DSABaseObject

@property (nonatomic, strong) DSADialog *currentDialog;
@property (nonatomic, strong) NSString *currentNodeID;
@property (nonatomic) NSInteger accumulatedDuration; // Gesamtdauer in Minuten

// skill check related properties
@property BOOL skillCheckPending;                    // to divide skill check nodes in two steps 
@property (nonatomic, strong, nullable) NSArray<DSACharacter *> *lastSkillCheckSuccess;
@property (nonatomic, strong, nullable) NSArray<DSACharacter *> *lastSkillCheckFailure;
@property (nonatomic, strong, nullable) DSADialogNodeSkillCheck *lastSkillCheckNode;
+ (instancetype)sharedManager;

- (BOOL)loadDialogFromFile:(NSString *)filename;
- (DSADialogNode *)currentNode;
- (void)presentCurrentNode;  // and eventuall do action...
- (void)performPendingSkillCheck;

@end
NS_ASSUME_NONNULL_END
#endif // _DSADIALOGMANAGER_H_

