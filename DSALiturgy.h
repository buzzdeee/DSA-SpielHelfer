/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-17 21:20:40 +0100 by sebastia

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

#ifndef _DSALITURGY_H_
#define _DSALITURGY_H_

#import <Foundation/Foundation.h>
#import "DSACharacter.h"

@interface DSALiturgy : NSObject <NSCoding, NSCopying>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;

- (instancetype)initLiturgy: (NSString *) name
                 ofCategory: (NSString *) category;

@end

#endif // _DSALITURGY_H_

