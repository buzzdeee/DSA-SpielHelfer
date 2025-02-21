/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-09 00:16:39 +0100 by sebastia

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

#ifndef _DSASPELLDRUIDRITUAL_H_
#define _DSASPELLDRUIDRITUAL_H_

#import "DSASpell.h"

@interface DSASpellDruidRitual : DSASpell

+ (instancetype)ritualWithName: (NSString *) name
                     ofVariant: (NSString *) variant
             ofDurationVariant: (NSString *) durationVariant
                    ofCategory: (NSString *) category 
                      withTest: (NSArray *) test
               withMaxDistance: (NSInteger) maxDistance       
                  withVariants: (NSArray *) variants
          withDurationVariants: (NSArray *) durationVariants
                   withPenalty: (NSInteger) penalty
                   withASPCost: (NSInteger) aspCost
          withPermanentASPCost: (NSInteger) permanentASPCost
                    withLPCost: (NSInteger) lpCost
           withPermanentLPCost: (NSInteger) permanentLPCost;

- (instancetype)initRitual: (NSString *) name
                 ofVariant: (NSString *) variant
         ofDurationVariant: (NSString *) durationVariant
                ofCategory: (NSString *) category
                  withTest: (NSArray *) test
           withMaxDistance: (NSInteger) maxDistance       
              withVariants: (NSArray *) variants    
      withDurationVariants: (NSArray *) durationVariants
               withPenalty: (NSInteger) penalty    
               withASPCost: (NSInteger) aspCost
      withPermanentASPCost: (NSInteger) permanentASPCost
                withLPCost: (NSInteger) lpCost
       withPermanentLPCost: (NSInteger) permanentLPCost;
       
       

@end

// Stabzauber
@interface DSASpellDruidRitualHerrschaftsritualMiniatur : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualHerrschaftsritualAmulett : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualHerrschaftsritualWurzel : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualHerrschaftsritualKristall : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualMetamagieSumusBlut : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualDolchritualEins : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualDolchritualZwei : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualDolchritualDrei : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualDolchritualKraft : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualDolchritualWeg : DSASpellDruidRitual
@end
@interface DSASpellDruidRitualDolchritualLicht : DSASpellDruidRitual
@end


#endif // _DSASPELLDRUIDRITUAL_H_

