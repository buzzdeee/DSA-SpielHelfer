/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-14 22:30:10 +0100 by sebastia

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

#ifndef _DSAACTIONICON_H_
#define _DSAACTIONICON_H_

#import <AppKit/AppKit.h>
#import "DSAItemInspectionController.h"

@class DSACharacter;

extern NSString * const DSALocalMapTileBuildingInnTypeHerberge;
extern NSString * const DSALocalMapTileBuildingInnTypeHerbergeMitTaverne;
extern NSString * const DSALocalMapTileBuildingInnTypeTaverne;

@interface DSAActionIcon : NSImageView

+ (instancetype)iconWithAction:(NSString *)action andSize: (NSString *)size;
- (void)updateAppearance;
@end

@interface DSAActionIconDragTarget: DSAActionIcon
@end
@interface DSAActionIconExamine: DSAActionIconDragTarget <DSAItemInspectionControllerDelegate>
@property (strong, nonatomic) DSAItemInspectionController *inspectionController;  // to keep a reference to item inspection window
@end
@interface DSAActionIconConsume: DSAActionIconDragTarget
@end
@interface DSAActionIconDispose: DSAActionIconDragTarget
@end

@interface DSAActionIconClickTarget: DSAActionIcon
@end
@interface DSAActionIconAddToGroup: DSAActionIconClickTarget
@end
@interface DSAActionIconRemoveFromGroup: DSAActionIconClickTarget
@end
@interface DSAActionIconSplitGroup: DSAActionIconClickTarget
@end
@interface DSAActionIconJoinGroups: DSAActionIconClickTarget
@end
@interface DSAActionIconSwitchActiveGroup: DSAActionIconClickTarget
@end
@interface DSAActionIconLeave: DSAActionIconClickTarget
@end
@interface DSAActionIconChat: DSAActionIconClickTarget
@end
@interface DSAActionIconPray: DSAActionIconClickTarget
@end
@interface DSAActionIconDonate: DSAActionIconClickTarget
@end
@interface DSAActionIconBuy: DSAActionIconClickTarget
@end
@interface DSAActionIconSell: DSAActionIconClickTarget
@end
@interface DSAActionIconRoom: DSAActionIconClickTarget
@end
@interface DSAActionIconSleep: DSAActionIconClickTarget
@end
@interface DSAActionIconTalent: DSAActionIconClickTarget
@end
@interface DSAActionIconMagic: DSAActionIconClickTarget
@end
@interface DSAActionIconRitual: DSAActionIconClickTarget
@end
@interface DSAActionIconMeal: DSAActionIconClickTarget
@end
@interface DSAActionIconMap: DSAActionIconClickTarget
@end

#endif // _DSAACTIONICON_H_

