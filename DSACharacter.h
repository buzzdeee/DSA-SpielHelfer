/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-08 00:03:31 +0200 by sebastia

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

#ifndef _DSACHARACTER_H_
#define _DSACHARACTER_H_

#import <Foundation/Foundation.h>

@interface DSACharacter : NSObject <NSSecureCoding>
{

}

// copy properties, to prevent others fiddling with the model...
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;

@end

#endif // _DSACHARACTER_H_

