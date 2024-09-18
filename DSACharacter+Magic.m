/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 22:07:51 +0200 by sebastia

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

#import "DSACharacter+Magic.h"

// Define a unique key for associated objects
static const void *SpellDictionaryKey = &SpellDictionaryKey;

@implementation DSACharacter (Magic)

@dynamic spellDictionary;

- (NSMutableDictionary *)spellDictionary {
    return objc_getAssociatedObject(self, @"spellDictionaryKey");
}

- (void)setSpellDictionary: (NSMutableDictionary *)spellDictionary {
    // KVO compliance: Trigger 'willChangeValueForKey'
    [self willChangeValueForKey:@"spellDictionary"];
    
    objc_setAssociatedObject(self, SpellDictionaryKey, spellDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // KVO compliance: Trigger 'didChangeValueForKey'
    [self didChangeValueForKey:@"spellDictionary"];
}

-(void)levelUpSpell: (DSASpell *)spell
{
  NSLog(@"DSACharacter (Magic): levelUpSpell: NOT IMPLEMENTED YET");
}

- (void)encodeMagicPropertiesWithCoder:(NSCoder *)coder {

    // Encode spellDictionary property from the associated object
    NSMutableDictionary *spellDict = objc_getAssociatedObject(self, SpellDictionaryKey);
    if (spellDict)
      {
        [coder encodeObject:spellDict forKey:@"spellDictionary"];
      }
}

- (instancetype)decodeMagicPropertiesWithCoder:(NSCoder *)coder {

    if (self)
      {
        // Decode the spellDictionary property and set the associated object
        NSMutableDictionary *spellDict = [coder decodeObjectForKey:@"spellDictionary"];
        if (spellDict)
          {
            objc_setAssociatedObject(self, SpellDictionaryKey, spellDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
          }
      }

    return self;
}

@end
