/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-09-13 19:41:12 +0200 by sebastia

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

#import "DSAActionResult.h"

@implementation DSAActionResult

-(instancetype)init
{
  self = [super init];
  if (self)
    {
      _result = DSAActionResultNone;
      _resultDescription = @"";
      _diceResults = [[NSMutableDictionary alloc] init];
      _remainingActionPoints = 0;
      _actionDuration = 0;
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
