/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-26 12:09:29 +0100 by sebastia

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

#ifndef _DSASPELLMAGERITUAL_H_
#define _DSASPELLMAGERITUAL_H_

#import "DSASpell.h"

@interface DSASpellMageRitual : DSASpell



+ (instancetype)ritualWithName: (NSString *) name
                    ofCategory: (NSString *) category 
                      withTest: (NSArray *) test
              withAlternatives: (NSArray *) alternatives
                   withPenalty: (NSInteger) penalty
                   withASPCost: (NSInteger) aspCost
          withPermanentASPCost: (NSInteger) permanentASPCost
                    withLPCost: (NSInteger) lpCost
           withPermanentLPCost: (NSInteger) permanentLPCost;

- (instancetype)initRitual: (NSString *) name
                ofCategory: (NSString *) category
                  withTest: (NSArray *) test
          withAlternatives: (NSArray *) alternatives      
               withPenalty: (NSInteger) penalty    
               withASPCost: (NSInteger) aspCost
      withPermanentASPCost: (NSInteger) permanentASPCost
                withLPCost: (NSInteger) lpCost
       withPermanentLPCost: (NSInteger) permanentLPCost;

@end

// Stabzauber
@interface DSASpellMageRitualStabzauberEins : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberZwei : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberDrei : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberVier : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberFuenf : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberSechs : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberSieben : DSASpellMageRitual
@end

@interface DSASpellMageRitualStabzauberFackel : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberSeil : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberChamaeleon : DSASpellMageRitual
@end
@interface DSASpellMageRitualStabzauberSpeikobra : DSASpellMageRitualStabzauberChamaeleon
@end
@interface DSASpellMageRitualStabzauberHerbeirufen : DSASpellMageRitual
@end

// Schwertzauber
@interface DSASpellMageRitualSchwertzauber : DSASpellMageRitual
@end

// Schalenzauber
@interface DSASpellMageRitualSchalenzauber : DSASpellMageRitual
@end

// Kugelzauber
@interface DSASpellMageRitualKugelzauberEins : DSASpellMageRitual
@end
@interface DSASpellMageRitualKugelzauberZwei : DSASpellMageRitual
@end
@interface DSASpellMageRitualKugelzauberDrei : DSASpellMageRitual
@end
@interface DSASpellMageRitualKugelzauberVier : DSASpellMageRitual
@end
@interface DSASpellMageRitualKugelzauberFuenf : DSASpellMageRitual
@end

@interface DSASpellMageRitualKugelzauberBrennglas : DSASpellMageRitual
@end
@interface DSASpellMageRitualKugelzauberSchutzfeld : DSASpellMageRitual
@end
@interface DSASpellMageRitualKugelzauberWarnung : DSASpellMageRitual
@end
@interface DSASpellMageRitualKugelzauberHerbeirufen : DSASpellMageRitual
@end
#endif // _DSASPELLMAGERITUAL_H_

