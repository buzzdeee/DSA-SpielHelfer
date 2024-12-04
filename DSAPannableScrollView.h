/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-03 20:47:44 +0100 by sebastia

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

#ifndef _DSAPANNABLESCROLLVIEW_H_
#define _DSAPANNABLESCROLLVIEW_H_

#import <AppKit/AppKit.h>

@interface DSAPannableScrollView : NSScrollView
@property (nonatomic) BOOL isDragging;
@property (nonatomic) NSPoint dragStartPoint;
@property (nonatomic) NSPoint initialOrigin;
@end

#endif // _DSAPANNABLESCROLLVIEW_H_

