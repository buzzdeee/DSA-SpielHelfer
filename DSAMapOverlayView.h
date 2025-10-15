/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-16 20:59:12 +0100 by sebastia

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

#ifndef _DSAMAPOVERLAYVIEW_H_
#define _DSAMAPOVERLAYVIEW_H_

#import <AppKit/AppKit.h>

@interface DSAMapOverlayView : NSView
@property (nonatomic, strong) NSArray *features;  // Generic features array
@property (nonatomic, assign) CGFloat zoomFactor;
- (instancetype)initWithFrame:(NSRect)frame features:(NSArray *)features;
@end

@interface DSARegionsOverlayView : DSAMapOverlayView
@property (nonatomic, strong) NSMutableDictionary *regionColors;
@end

@interface DSAStreetsOverlayView : DSAMapOverlayView
@end

@interface DSARouteOverlayView : DSAMapOverlayView
@property (nonatomic, strong) NSArray<NSValue *> *routePoints; // Points along the route
- (void)updateRouteWithPoints:(NSArray<NSValue *> *)points;
-(void)fadeOut;
@end



#endif // _DSAMAPOVERLAYVIEW_H_

