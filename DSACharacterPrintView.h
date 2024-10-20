/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-10-20 17:58:36 +0200 by sebastia

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

#ifndef _DSACHARACTERPRINTVIEW_H_
#define _DSACHARACTERPRINTVIEW_H_

#import "NSFlippedView.h"

@class DSACharacter;

#define PAGE_WIDTH 564
#define PAGE_HEIGHT 792
#define MARGIN 18

@interface DSACharacterPrintView : NSFlippedView
@property (nonatomic, strong) DSACharacter *model; // This can hold your model properties or data
@property (nonatomic, strong) NSMutableArray *spellCategoriesAlreadyDone;  // to track over multiple pages how many Spell Categories are already dealt with
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger pages;
@end


#endif // _DSACHARACTERPRINTVIEW_H_

