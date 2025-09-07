/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 00:04:18 +0200 by sebastia

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

#import <objc/runtime.h>
#import "DSASpellResult.h"

@implementation DSASpellResult

-(instancetype)init
{
  self = [super init];
  if (self)
    {
      _result = DSAActionResultNone;
      _diceResults = [[NSMutableArray alloc] init];
      _remainingSpellPoints = 0;
      _spellingDuration = 0;
      _costAE = 0;
    }
  return self;
}

+(NSString *) resultNameForResultValue: (DSAActionResultValue) value
{
  NSArray *resultStrings = @[ _(@"Ohne Ergebnis"), _(@"Erfolg"), _(@"Automatischer Erfolg"),
                              _(@"Epischer Erfolg!"), _(@"Mißerfolg"), _(@"Automatischer Mißerfolg"),
                              _(@"Epischer Mißerfolg!"), _(@"Zauber ist noch nicht implementiert!"),
                              _(@"Nicht genug Astralenergie"), _(@"Zu weit entfernt!"),
                              _(@"Ungültiges Ziel"), _(@"Spruch ist schon auf dem Ziel."),
                              _(@"Ein anderer Zauber ist schon aktiv.") ];
  return resultStrings[value];
}

@end
