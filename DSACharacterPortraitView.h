/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-02-28 21:40:12 +0100 by sebastia

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

#ifndef _DSACHARACTERPORTRAITVIEW_H_
#define _DSACHARACTERPORTRAITVIEW_H_

#import <AppKit/AppKit.h>

@class DSACharacterDocument;

@interface DSACharacterPortraitView : NSImageView

@property (nonatomic, strong) DSACharacterDocument *characterDocument;
@property (nonatomic, strong) NSBox *highlightView;
@property (nonatomic, assign) BOOL isHighlighted;
@property (nonatomic, assign) NSPoint initialClickLocation;

- (void)updateCharacterNameLabel;
@end

#endif // _DSACHARACTERPORTRAITVIEW_H_

