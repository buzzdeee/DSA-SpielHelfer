/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-10 21:46:58 +0200 by sebastia

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

#import "DSADialogOption.h"
#import "DSADialogAction.h"

@implementation DSADialogOption

+ (instancetype)optionFromDictionary:(NSDictionary *)dict {
    //NSLog(@"DSADialogOption optionFromDictionary: dict: %@", dict);
    DSADialogOption *opt = [[DSADialogOption alloc] init];
    opt.textVariants = dict[@"texts"];
    opt.nextNodeID = dict[@"nextNodeID"];
    opt.hintCategory = dict[@"hintCategory"];
    opt.duration = [dict[@"duration"] integerValue];
    opt.skillCheck = dict[@"skillCheck"];
    return opt;
}


- (NSString *)randomText {
    if (self.textVariants.count == 0) {
        return @"...";
    }
    NSUInteger index = arc4random_uniform((uint32_t)self.textVariants.count);
    return self.textVariants[index];
}
@end