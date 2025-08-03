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

#import "DSASpellDruidRitual.h"
#import "DSASpellResult.h"
#import "DSACharacter.h"
#import "Utils.h"
#import "DSAInventoryManager.h"

@implementation DSASpellDruidRitual
static NSDictionary<NSString *, Class> *typeToClassMap = nil;

+ (void)initialize
{
  if (self == [DSASpellDruidRitual class])
    {
      @synchronized(self)
        {
          if (!typeToClassMap)
            {
              typeToClassMap = @{
                _(@"Die Miniatur der Herrschaft"): [DSASpellDruidRitualHerrschaftsritualMiniatur class],
                _(@"Das Amulett der Herrschaft"): [DSASpellDruidRitualHerrschaftsritualAmulett class],
                _(@"Die Wurzel der Herrschaft"): [DSASpellDruidRitualHerrschaftsritualWurzel class],
                _(@"Der Kristall der Herrschaft"): [DSASpellDruidRitualHerrschaftsritualKristall class],
                _(@"Sumus Blut"): [DSASpellDruidRitualMetamagieSumusBlut class],
                _(@"1. Dolchritual"): [DSASpellDruidRitualDolchritualEins class],
                _(@"2. Dolchritual"): [DSASpellDruidRitualDolchritualZwei class],
                _(@"3. Dolchritual"): [DSASpellDruidRitualDolchritualDrei class],                
                _(@"Die Kraft des Dolches"): [DSASpellDruidRitualDolchritualKraft class],
                _(@"Der Weg des Dolches"): [DSASpellDruidRitualDolchritualWeg class],
                _(@"Das Licht des Dolches"): [DSASpellDruidRitualDolchritualLicht class],
              };
            }
        }
    }
}

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
{
  Class subclass = [typeToClassMap objectForKey: name];
  if (subclass)
    {
      NSLog(@"DSASpellMAgeRitual: ritualWithName: %@ going to call initRitual...", name);
      return [[subclass alloc] initRitual: name
                                ofVariant: variant
                        ofDurationVariant: durationVariant
                               ofCategory: category
                                 withTest: test
                          withMaxDistance: maxDistance
                             withVariants: variants    
                     withDurationVariants: durationVariants
                              withPenalty: penalty
                              withASPCost: aspCost
                     withPermanentASPCost: permanentASPCost
                               withLPCost: lpCost
                      withPermanentLPCost: permanentLPCost];
    }
  // handle unknown type
  NSLog(@"DSASpellMageRitual: ritualWithName: %@ not found returning NIL", name);
  return nil;
}

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
       withPermanentLPCost: (NSInteger) permanentLPCost
{
  self = [super initSpell: name
                ofVariant: variant
        ofDurationVariant: durationVariant
               ofCategory: category
                  onLevel: 0
               withOrigin: nil
                 withTest: test
          withMaxDistance: maxDistance       
             withVariants: variants
     withDurationVariants: durationVariants
   withMaxTriesPerLevelUp: 0
        withMaxUpPerLevel: 0
          withLevelUpCost: 0];
  if (self)
    {
      self.penalty = penalty;    
      self.aspCost = aspCost;
      self.permanentASPCost = permanentASPCost;
      self.lpCost = lpCost;
      self.permanentLPCost = permanentLPCost;
      
      self.removalCostASP = aspCost;
      self.spellDuration = -1;
      self.spellingDuration = -1;      // can easily switch on and off     
    }
  return self;
}

- (BOOL) levelUp;  // nothing to level up here
{
  NSLog(@"DSASpellDruidRitual levelUp NOT YET implemented");
  return YES;
}

- (BOOL) isActiveSpell
{
  return YES;
}

- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitual castOnTarget for spell: %@ called! %@", self.name, self);
  DSASpellResult *result = [[DSASpellResult alloc] init];
  result.resultDescription = [NSString stringWithFormat: _(@"%@ ist noch nicht implementiert."), self.name];
  return result;
}
@end

// Herrschaftsrituale
@implementation DSASpellDruidRitualHerrschaftsritualMiniatur
- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitualHerrschaftsritualMiniatur called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  if (![target isKindOfClass: [DSACharacter class]])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  NSInteger penalty = [(DSACharacter *)target mrBonus] + floor(distance / 10000);  // mage resistance + 1 point per 10 miles
  penalty -= round(castingCharacter.level / 2);                                    // halbe Stufe des Druiden gerundet als Bonus
  spellResult = [self testTraitsWithSpellLevel: penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;

      [[(DSACharacter*)target appliedSpells] setObject: [self copy] forKey: self.name];
      NSInteger duration = [Utils rollDice: @"2W6"];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ belegt %@ mit dem \"Miniatur der Herrschaft\" Ritual, das es ihm gestattet %@ für %ld Tage Einbildungen und fixe Ideen vorzugaukeln, sowie Schmerzen zuzufügen.", castingCharacter.name, [(DSACharacter *)target name], [(DSACharacter *)target name], (signed long) duration];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of DSASpellDruidRitualHerrschaftsritualMiniatur

@implementation DSASpellDruidRitualHerrschaftsritualAmulett
- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitualHerrschaftsritualAmulett called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  if (![target isKindOfClass: [DSACharacter class]])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  NSLog(@"DSASpellDruidRitualHerrschaftsritualAmulett castOnTarget : comparing maxDistance: %ld with distance: %ld", (signed long) self.maxDistance, (signed long) distance);
  if (self.maxDistance <= distance)  // too far away
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist zu weit entfernt."), castingCharacter.name];
      return spellResult;
    } 
  NSInteger penalty = [(DSACharacter *)target mrBonus];  // mage resistance + 1 point per 10 miles
  penalty -= round(castingCharacter.level / 2);          // halbe Stufe des Druiden gerundet als Bonus
  spellResult = [self testTraitsWithSpellLevel: penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;

      [[(DSACharacter*)target appliedSpells] setObject: [self copy] forKey: self.name];
      NSInteger duration = [Utils rollDice: @"3W6"];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ belegt %@ mit dem \"Amulett der Herrschaft\" Ritual, das es ihm gestattet %@ für %ld Tage 1x am Tag für eine Stunde dessen Stimme mitzubenutzen oder ihn zu beherrschen. Zudem kann er jederzeit alle 5 Sinne des Opfers mitbenutzen.", castingCharacter.name, [(DSACharacter *)target name], [(DSACharacter *)target name], (signed long) duration];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of DSASpellDruidRitualHerrschaftsritualAmulett

@implementation DSASpellDruidRitualHerrschaftsritualWurzel
- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitualHerrschaftsritualWurzel called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  if (![target isKindOfClass: [DSACharacter class]])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  NSInteger penalty = 2 * [(DSACharacter *)target mrBonus] + floor(distance / 10000);  // 2x mage resistance + 1 point per 10 miles
  penalty -= round(castingCharacter.level / 2);                                        // halbe Stufe des Druiden gerundet als Bonus
  spellResult = [self testTraitsWithSpellLevel: penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;

      [[(DSACharacter*)target appliedSpells] setObject: [self copy] forKey: self.name];
      NSInteger duration = [Utils rollDice: @"4W6"];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ belegt %@ mit dem \"Wurzel der Herrschaft\" Ritual, das es ihm gestattet %@ für %ld Tage 1x am Tag für eine Stunde lang Halluzinationen vorzugaukeln, oder ihm Schadenspunkte zuzufügen.", castingCharacter.name, [(DSACharacter *)target name], [(DSACharacter *)target name], (signed long) duration];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of DSASpellDruidRitualHerrschaftsritualWurzel

@implementation DSASpellDruidRitualHerrschaftsritualKristall
- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitualHerrschaftsritualKristall called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  if (![target isKindOfClass: [DSACharacter class]])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    } 
  NSInteger penalty = 2 * [(DSACharacter *)target mrBonus] + floor(distance / 10000);  // 2x mage resistance + 1 point per 10 miles
  penalty -= round(castingCharacter.level / 2);                                        // halbe Stufe des Druiden gerundet als Bonus
  if (penalty < 7)
    {
      penalty = 7;
    }
  spellResult = [self testTraitsWithSpellLevel: penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;

      [[(DSACharacter*)target appliedSpells] setObject: [self copy] forKey: self.name];
      NSInteger duration = [Utils rollDice: @"5W6"];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ belegt %@ mit dem \"Kristall der Herrschaft\" Ritual, das es ihm gestattet %@ für %ld Tage 1x am Tag einen Zauber druidischen Ursprungs aus der Kategorie Beherrschung oder Verwandlung von Lebewesen zu schleudern.", castingCharacter.name, [(DSACharacter *)target name], [(DSACharacter *)target name], (signed long) duration];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of DSASpellDruidRitualHerrschaftsritualKristall

// Metamagie
@implementation DSASpellDruidRitualMetamagieSumusBlut
- (DSASpellResult *) castOnTarget: (id) target
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitualMetamagieSumusBlut called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    } 

  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;

      [[(DSACharacter*)target appliedSpells] setObject: [self copy] forKey: self.name];
      castingCharacter.astralEnergy += 1;
      castingCharacter.currentAstralEnergy += 1;
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ hat sich bis zum Hals ins Erdreich vergraben und das Erdreich um ihn herum mit Astralenergie aufgeladen. So verharrt er einen Tag. Die Erde lockert sich um ihn, und er kann leicht aus dem Loch heraussteigen. Er erhält einen permanenten Astralenergiepunkt.", castingCharacter.name];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      NSInteger sp = [Utils rollDice: @"5W6"];
      castingCharacter.currentLifePoints -= sp;
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ hat sich bis zum Hals ins Erdreich vergraben und das Erdreich um ihn herum mit Astralenergie aufgeladen. So verharrt er einen Tag. Die Erde speit ihn wieder aus, dabei erhält er %lu Schadenspunkte", castingCharacter.name, (signed long)sp];
    }
  
  return spellResult;
}
@end
// End of DSASpellDruidRitualMetamagieSumusBlut



// Dolchrituale
@implementation DSASpellDruidRitualDolchritualEins
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitualDolchritualEins called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Vulkanglasdolch" inModel: castingCharacter];  
    
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  NSInteger penalty = self.penalty - round(castingCharacter.level / 2);                                        // halbe Stufe des Druiden gerundet als Bonus
  spellResult = [self testTraitsWithSpellLevel: penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;

      [target.appliedSpells setObject: [self copy] forKey: self.name];
      target.ownerUUID = [castingCharacter.modelID copy];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ stellt einen geistigen Band zu seinem Vulkanglasdolch her. Dieser wird unzerstörbar.", castingCharacter.name];
      DSASpell *kraftRitual = [DSASpellDruidRitual ritualWithName: _(@"Die Kraft des Dolches")
                                                        ofVariant: nil // variant
                                                ofDurationVariant: nil
                                                       ofCategory: _(@"Dolchritual")
                                                         withTest: @[]
                                                  withMaxDistance: -1
                                                     withVariants: nil
                                             withDurationVariants: nil
                                                      withPenalty: 0
                                                      withASPCost: 17
                                             withPermanentASPCost: 1
                                                       withLPCost: 0
                                              withPermanentLPCost: 0];
      [castingCharacter.specials setObject: kraftRitual forKey: _(@"Die Kraft des Dolches")];                                               
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end

@implementation DSASpellDruidRitualDolchritualZwei
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Vulkanglasdolch" inModel: castingCharacter]; 
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }   
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSAActionResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Vulkanglasdolch aktiv."), self.name];
            return spellResult;
          }
      }
      
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  NSInteger penalty = self.penalty - round(castingCharacter.level / 2);                                        // halbe Stufe des Druiden gerundet als Bonus
  spellResult = [self testTraitsWithSpellLevel: penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;

      [[(DSACharacter*)target appliedSpells] setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann seinen Vulkanglasdolch ab sofort als Orientierungshilfe nutzen.", castingCharacter.name];
      DSASpell *wegRitual = [DSASpellDruidRitual ritualWithName: _(@"Der Weg des Dolches")
                                                        ofVariant: nil // variant
                                                ofDurationVariant: nil
                                                       ofCategory: _(@"Dolchritual")
                                                         withTest: @[]
                                                  withMaxDistance: -1
                                                     withVariants: nil
                                             withDurationVariants: nil
                                                      withPenalty: 0
                                                      withASPCost: 0
                                             withPermanentASPCost: 0
                                                       withLPCost: 0
                                              withPermanentLPCost: 0];
      [castingCharacter.specials setObject: wegRitual forKey: _(@"Der Weg des Dolches")];    
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end

@implementation DSASpellDruidRitualDolchritualDrei
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellDruidRitualDolchritualEins called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Vulkanglasdolch" inModel: castingCharacter]; 
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }   
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSAActionResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Vulkanglasdolch aktiv."), self.name];
            return spellResult;
          }
      }
  
  NSInteger penalty = self.penalty - round(castingCharacter.level / 2);                                        // halbe Stufe des Druiden gerundet als Bonus
  spellResult = [self testTraitsWithSpellLevel: penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSAActionResultSuccess || 
      spellResult.result == DSAActionResultAutoSuccess ||
      spellResult.result == DSAActionResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [[(DSACharacter*)target appliedSpells] setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann seinen Vulkanglasdolch nutzen, um ein mal täglich im Dunkeln zu sehen.", castingCharacter.name];
      DSASpell *lichtRitual = [DSASpellDruidRitual ritualWithName: @"Das Licht des Dolches"
                                                        ofVariant: nil // variant
                                                ofDurationVariant: nil
                                                       ofCategory: _(@"Dolchritual")
                                                         withTest: @[]
                                                  withMaxDistance: -1
                                                     withVariants: nil
                                             withDurationVariants: nil
                                                      withPenalty: 0
                                                      withASPCost: 1
                                             withPermanentASPCost: 0
                                                       withLPCost: 0
                                              withPermanentLPCost: 0]; 
      [castingCharacter.specials setObject: lichtRitual forKey: _(@"Das Licht des Dolches")];     
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end

@implementation DSASpellDruidRitualDolchritualKraft
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Vulkanglasdolch" inModel: castingCharacter]; 
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat keinen persönlichen Vulkanglasdolch."), [(DSAObject *)target name]];
      return spellResult;
    }   
  
  NSInteger lp = [Utils rollDice: @"1W6"];
  if (castingCharacter.currentLifePoints + lp > castingCharacter.lifePoints)
    {                                                          
      lp = castingCharacter.lifePoints - castingCharacter.currentLifePoints;
    }  
  spellResult.resultDescription = [NSString stringWithFormat: @"%@ steckt seinen Vulkanglasdolch in die Erde und konzentriert sich darauf. Seine Lebensenergie steigt um %lu Lebenspunkte.", 
                                                              castingCharacter.name,
                                                              (signed long) lp];
  spellResult.result = DSAActionResultSuccess;
  castingCharacter.currentLifePoints += lp;  

  return spellResult;
}
@end

@implementation DSASpellDruidRitualDolchritualWeg
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Vulkanglasdolch" inModel: castingCharacter]; 
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat keinen persönlichen Vulkanglasdolch."), [(DSAObject *)target name]];
      return spellResult;
    }   

  spellResult.result = DSAActionResultSuccess;
  spellResult.resultDescription = [NSString stringWithFormat: @"%@ legt seinen Vulkanglasdolch auf eine ebene Fläche. Dieser dreht sich mit der Spitze zu dem Ort, an dem er geweiht wurde.", castingCharacter.name];   

  return spellResult;
}
@end
@implementation DSASpellDruidRitualDolchritualLicht
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
                 currentAdventure: (DSAAdventure *) adventure                      
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Vulkanglasdolch" inModel: castingCharacter]; 
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat keinen persönlichen Vulkanglasdolch."), [(DSAObject *)target name]];
      return spellResult;
    }   
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSAActionResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  castingCharacter.currentAstralEnergy -= self.aspCost;  
  spellResult.result = DSAActionResultSuccess;
  spellResult.resultDescription = [NSString stringWithFormat: @"%@ ritzt sich mit seinem Vulkanglasdolch in die Stirn. Er kann jetzt für einige Zeit im Dunkeln sehen.", castingCharacter.name];   

  return spellResult;
}
@end