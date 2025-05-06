/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-04 22:20:40 +0200 by sebastia

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

#ifndef _DSACHARACTERGENERATOR_H_
#define _DSACHARACTERGENERATOR_H_

#import <Foundation/Foundation.h>

@class DSACharacter;

@interface DSACharacterGenerator : NSObject

@property (weak) DSACharacter *character;  // in the end will be handed over to caller who takes it on...

- (DSACharacter *)generateCharacterWithParameters:(NSDictionary *)parameters;

@end

#endif // _DSACHARACTERGENERATOR_H_

