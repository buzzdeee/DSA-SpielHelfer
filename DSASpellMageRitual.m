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

#import "DSASpellMageRitual.h"
#import "DSASpellResult.h"
#import "DSACharacter.h"
#import "Utils.h"
#import "DSAInventoryManager.h"


@implementation DSASpellMageRitual
static NSDictionary<NSString *, Class> *typeToClassMap = nil;

+ (void)initialize
{
  if (self == [DSASpellMageRitual class])
    {
      @synchronized(self)
        {
          if (!typeToClassMap)
            {
              typeToClassMap = @{
                _(@"1. Stabzauber"): [DSASpellMageRitualStabzauberEins class],
                _(@"2. Stabzauber"): [DSASpellMageRitualStabzauberZwei class],
                _(@"3. Stabzauber"): [DSASpellMageRitualStabzauberDrei class],
                _(@"4. Stabzauber"): [DSASpellMageRitualStabzauberVier class],
                _(@"5. Stabzauber"): [DSASpellMageRitualStabzauberFuenf class],
                _(@"6. Stabzauber"): [DSASpellMageRitualStabzauberSechs class],
                _(@"7. Stabzauber"): [DSASpellMageRitualStabzauberSieben class],
                _(@"Magische Fackel"): [DSASpellMageRitualStabzauberFackel class],
                _(@"Magisches Seil"): [DSASpellMageRitualStabzauberSeil class],
                _(@"Tierverwandlung"): [DSASpellMageRitualStabzauberTierverwandlung class],
                _(@"Stab herbeirufen"): [DSASpellMageRitualStabzauberHerbeirufen class],
                _(@"Schwertzauber"): [DSASpellMageRitualSchwertzauber class],
                _(@"Schalenzauber"): [DSASpellMageRitualSchalenzauber class],
                _(@"1. Kugelzauber"): [DSASpellMageRitualKugelzauberEins class],
                _(@"2. Kugelzauber"): [DSASpellMageRitualKugelzauberZwei class],
                _(@"3. Kugelzauber"): [DSASpellMageRitualKugelzauberDrei class],
                _(@"4. Kugelzauber"): [DSASpellMageRitualKugelzauberVier class],
                _(@"5. Kugelzauber"): [DSASpellMageRitualKugelzauberFuenf class],
                _(@"Brennglas"): [DSASpellMageRitualKugelzauberBrennglas class],
                _(@"Schutzfeld"): [DSASpellMageRitualKugelzauberSchutzfeld class],
                _(@"Auge des Zorns"): [DSASpellMageRitualKugelzauberWarnung class],
                _(@"Kristallkugel herbeirufen"): [DSASpellMageRitualKugelzauberHerbeirufen class],
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
      self.targetType = DSAActionTargetTypeNone;      // the default anyways, ...
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
  NSLog(@"DSASpellMageRitual levelUp NOT YET implemented");
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
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitual castOnTarget for spell: %@ called! %@", self.name, self);
  DSASpellResult *result = [[DSASpellResult alloc] init];
  result.resultDescription = [NSString stringWithFormat: _(@"%@ ist noch nicht implementiert."), self.name];
  return result;
}
@end
// End of 

// Stabzauber
@implementation DSASpellMageRitualStabzauberEins
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberEins castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  if (!variant)
    {
      variant = self.variant;
    }
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  NSLog(@"DSAMageRitualStabzauberEins castOnTarget got spellResult: %@", spellResult);
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      if ([variant isEqualToString: _(@"Standard")])  // when casted on a secondary staff, not the initial staff, on character creation
        {
          castingCharacter.currentAstralEnergy -= self.aspCost;
          castingCharacter.astralEnergy -= self.permanentASPCost;
        }
          /* [target setBreakFactor: -1];
          [target.appliedSpells setObject: [self copy] forKey: self.name];
          target.ownerUUID = [castingCharacter.modelID copy]; */
          [self applyEffectOnTarget: target forOwner: castingCharacter];
          spellResult.resultDescription = [NSString stringWithFormat: @"%@ stellt einen geistigen Band zu seinem Magierstab her. Der Stab wird unzerstörbar.", castingCharacter.name];
    }
  else
    {
      if ([variant isEqualToString: _(@"Standard")])  // when casted on a secondary staff, not the initial staff, on character creation
        {
          castingCharacter.currentAstralEnergy -= self.aspCost;
        }
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}

- (BOOL) applyEffectOnTarget: (id) target forOwner: (DSACharacter *) owner
{
  [(DSAObject *)target setBreakFactor: -1];
  [[(DSAObject *)target appliedSpells] setObject: [self copy] forKey: self.name];
  [(DSAObject *)target setOwnerUUID: [owner.modelID copy]];  
  return YES;
}

@end
// End of DSASpellStabzauberEins

@implementation DSASpellMageRitualStabzauberZwei
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberZwei called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }  
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      DSASpell *fackelRitual = [DSASpellMageRitual ritualWithName: @"Magische Fackel"
                                                        ofVariant: nil // variant
                                                ofDurationVariant: nil
                                                       ofCategory: _(@"Stabzauber")
                                                         withTest: @[]
                                                  withMaxDistance: -1
                                                     withVariants: nil
                                             withDurationVariants: nil
                                                      withPenalty: 0
                                                      withASPCost: 0
                                             withPermanentASPCost: 0
                                                       withLPCost: 0
                                              withPermanentLPCost: 0];
      NSLog(@"THE FACKEL RITUAL: %@", fackelRitual);      
      NSLog(@"CASTING CHARACTER SPECIALS: %@", castingCharacter.specials);
      [castingCharacter.specials setObject: fackelRitual forKey: @"Magische Fackel"];  
      NSLog(@"AFTER ADDING FACKEL RITUAL TO CASTING CHARACTER: %@", fackelRitual);
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann seinen Magierstab von nun an in eine Fackel und zurück verwandeln.", castingCharacter.name]; 
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of Stabzauber Zwei

@implementation DSASpellMageRitualStabzauberDrei
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberDrei called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      DSASpell *ropeRitual = [DSASpellMageRitual ritualWithName: _(@"Magisches Seil")
                                                        ofVariant: nil
                                                ofDurationVariant: nil
                                                       ofCategory: _(@"Stabzauber")
                                                         withTest: @[]
                                                  withMaxDistance: -1       
                                                     withVariants: nil        
                                             withDurationVariants: nil
                                                      withPenalty: 0
                                                      withASPCost: 0
                                             withPermanentASPCost: 0
                                                       withLPCost: 0
                                              withPermanentLPCost: 0];
      [castingCharacter.specials setObject: ropeRitual forKey: _(@"Magisches Seil")];  
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann seinen Magierstab von nun an in ein 10 Schritt langes Seil und zurück verwandeln.", castingCharacter.name];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of Stabzauber Drei

@implementation DSASpellMageRitualStabzauberVier
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberVier called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ spart ab jetzt 2 ASP bei jedem Zaubervorgang.", castingCharacter.name];
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}

@end
// End of Stabzauber Vier

@implementation DSASpellMageRitualStabzauberFuenf
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberFuenf called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
    
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann seinen Magierstab ab sofort in ein Flammenschwert verwandeln.", castingCharacter.name];
    }
  else
    {
      NSInteger diceResult = [Utils rollDice: @"1W3"];
      if (diceResult == 1)
        {
          DSAObject *sword = [[DSAObject alloc] initWithName: @"Schwert" forOwner: castingCharacter.modelID];
          [[DSAInventoryManager sharedManager] replaceItem: target
                                                   inModel: castingCharacter
                                                  withItem: sword];
          spellResult.resultDescription = [NSString stringWithFormat: @"Der Magierstab hat sich in ein gewöhnliches Schwert verwandelt."];
        }
      else if (diceResult == 2)
        {
          [target.states addObject: @(DSAObjectStateNoMoreStabzauber)];
          spellResult.resultDescription = [NSString stringWithFormat: @"Der Magierstab weigert sich von nun an jeglichen weiteren Stabzauber anzunehmen."];
        }
      else if (diceResult == 3)
        {
          NSInteger diceResult = [Utils rollDice: @"1W20"] + 10;
          castingCharacter.currentLifePoints -= diceResult;
          spellResult.resultDescription = [NSString stringWithFormat: @"Der Magierstab verwandelt sich kurzzeitig in ein Flammenschwert, und fügt %@ %ld Schadenspunkte zu.", castingCharacter.name, (signed long) diceResult];
        }
      castingCharacter.currentAstralEnergy -= self.aspCost;
    }
  
  return spellResult;
}
@end
// End of Stabzauber Fünf

@implementation DSASpellMageRitualStabzauberSechs
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberSechs called! %@ %@", self, [[[[Utils getMageRitualsDict] objectForKey: @"Stabzauber"] objectForKey: self.name] objectForKey: @"Varianten" ]);
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [[(DSAObject *)target appliedSpells] setObject: [self copy] forKey: self.name];
      DSASpell *newRitual = [DSASpellMageRitual ritualWithName: _(@"Tierverwandlung")
                                                     ofVariant: variant
                                             ofDurationVariant: nil
                                                    ofCategory: _(@"Stabzauber")
                                                      withTest: @[]
                                               withMaxDistance: -1       
                                                  withVariants: @[variant]
                                          withDurationVariants: nil
                                                   withPenalty: 0
                                                   withASPCost: 0
                                          withPermanentASPCost: 0
                                                    withLPCost: 0
                                           withPermanentLPCost: 0];
      [castingCharacter.specials setObject: newRitual forKey: _(@"Tierverwandlung")];  
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      NSString *article;
      if ([variant isEqualToString: _(@"Chamäleon")])
        {
          article = _(@"ein");
        }
      else
        {
          article = _(@"eine");
        }
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann seinen Magierstab von nun an in %@ %@ verwandeln.", castingCharacter.name, article, variant];      
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of Stabzauber Sechs

@implementation DSASpellMageRitualStabzauberSieben
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberSieben called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      DSASpell *ropeRitual = [DSASpellMageRitual ritualWithName: _(@"Stab herbeirufen")
                                                      ofVariant: nil
                                              ofDurationVariant: nil
                                                     ofCategory: _(@"Stabzauber")
                                                       withTest: @[]
                                                withMaxDistance: 7000 // 7 Meilen       
                                                   withVariants: nil        
                                           withDurationVariants: nil
                                                    withPenalty: 0
                                                    withASPCost: 0
                                           withPermanentASPCost: 0
                                                     withLPCost: 0
                                            withPermanentLPCost: 0];
      [castingCharacter.specials setObject: ropeRitual forKey: _(@"Stab herbeirufen")];  
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ festigt den Band mit seinem Stab und kann ihn nun aus bis zu 7 Meilen Entfernung herbeirufen.", castingCharacter.name];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of Stabzauber Sieben

@implementation DSASpellMageRitualStabzauberFackel
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                 
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberFackel castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([target.states containsObject: @(DSAObjectStateHasSpellActive)])
    {
      if (![target.states containsObject: @(DSAObjectStateStabzauberFackel)])
        {
          spellResult.result = DSASpellResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Ein anderer Zauber ist schon auf dem Magierstab aktiv.")];
          return spellResult;
        }
      
      [target.states removeObject: @(DSAObjectStateStabzauberFackel)];
      [target.states removeObject: @(DSAObjectStateHasSpellActive)];
      spellResult.resultDescription = [NSString stringWithFormat: @"Das magische Licht der Fackel erlischt."];
      return spellResult;
    }
  [target.states addObject: @(DSAObjectStateStabzauberFackel)];
  [target.states addObject: @(DSAObjectStateHasSpellActive)];
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"Der Magierstab taucht die Umgebung in magischem Licht."];
  return spellResult;
}
@end
// End of DSASpellStabzauberFackel

@implementation DSASpellMageRitualStabzauberSeil
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberSeil castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([target.states containsObject: @(DSAObjectStateHasSpellActive)])
    {
      if (![target.states containsObject: @(DSAObjectStateStabzauberSeil)])
        {
          spellResult.result = DSASpellResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Ein anderer Zauber ist schon auf dem Magierstab aktiv.")];
          return spellResult;
        }
      
      [target.states removeObject: @(DSAObjectStateStabzauberSeil)];
      [target.states removeObject: @(DSAObjectStateHasSpellActive)];
      spellResult.resultDescription = [NSString stringWithFormat: @"Das magische Seil verwandelt sich zurück in den Magierstab."];
      return spellResult;
    }
  [target.states addObject: @(DSAObjectStateStabzauberSeil)];
  [target.states addObject: @(DSAObjectStateHasSpellActive)];
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"Der Magierstab verwandelt sich in ein magisches Seil."];
  return spellResult;
}
@end

@implementation DSASpellMageRitualStabzauberTierverwandlung
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualStabzauberTierverwandlung castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  NSString *article, *article2;
  if (variant == nil)
    {
      variant = self.variant;
      if ([variant isEqualToString: _(@"Chamäleon")])
        {
          article = _(@"Das");
          article2 = _(@"ein");
        }
      else
        {
          article = _(@"Die");
          article2 = _(@"eine");
        }
    }
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([target.states containsObject: @(DSAObjectStateHasSpellActive)])
    {
      if (![target.states containsObject: @(DSAObjectStateStabzauberTierverwandlung)])
        {
          spellResult.result = DSASpellResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Ein anderer Zauber ist schon auf dem Magierstab aktiv.")];
          return spellResult;
        }
      
      [target.states removeObject: @(DSAObjectStateStabzauberTierverwandlung)];
      [target.states removeObject: @(DSAObjectStateHasSpellActive)];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ %@ verwandelt sich zurück in den Magierstab.", article, variant];
      return spellResult;
    }
  [target.states addObject: @(DSAObjectStateStabzauberTierverwandlung)];
  [target.states addObject: @(DSAObjectStateHasSpellActive)];
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"Der Magierstab verwandelt sich in %@ %@.", article2, variant];
  return spellResult;
}
@end
// End of DSASpellMageRitualStabzauberTierverwandlung



@implementation DSASpellMageRitualStabzauberHerbeirufen
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierstab" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"%@ ruft den Stab zurück.", castingCharacter.name];
  return spellResult;
}
@end
// End of DSASpellStabzauberHerbeirufen

// End of all Stabzaubersse

// Schwertzauber
@implementation DSASpellMageRitualSchwertzauber
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualSchwertzauber called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierschwert" inModel: castingCharacter];
  if (![self verifyTarget: target andOrigin: originCharacter])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;      
    }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;     
      [self applyEffectOnTarget: target forOwner: castingCharacter];
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}

- (BOOL) applyEffectOnTarget: (id) target forOwner: (DSACharacter *) owner
{
  // This variant is applied on character creation, never when casted onto some other secondary target
  // character Creation just calles applyEffectOnTarget and that's it...
  if ([self.variant isEqualToString: _(@"Dunkle Halle der Geister")])
    {
      owner.currentAstralEnergy -= 1;
      owner.astralEnergy -= 1;
    }
  [(DSAObject *)target setBreakFactor: -1];
  [[(DSAObject *)target appliedSpells] setObject: [self copy] forKey: self.name];
  [(DSAObject *)target setOwnerUUID: [owner.modelID copy]];  
  return YES;
}

@end
// End of DSASpellMageRitualSchwertzauber

// Schalenzauber
@implementation DSASpellMageRitualSchalenzauber
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualSchalenzauber called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Magierschale" inModel: castingCharacter];
  if (![self verifyTarget: target andOrigin: originCharacter])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;      
    }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      castingCharacter.currentLifePoints -= self.lpCost;
      castingCharacter.lifePoints -= self.permanentLPCost;      
      [(DSAObjectWeaponHandWeapon *)target setBreakFactor: -1];
      target.ownerUUID = [castingCharacter.modelID copy];
      [target.appliedSpells setObject: [self copy] forKey: self.name];
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of DSASpellMageRitualSchalenzauber

// Kugelzauber
@implementation DSASpellMageRitualKugelzauberEins
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualKugelzauberEins castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];

  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf der Kristallkugel aktiv."), self.name];
            return spellResult;
          }
      }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  NSLog(@"DSAMageRitualKugelzauberEins castOnTarget got spellResult: %@", spellResult);
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [target setBreakFactor: -1];
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      target.ownerUUID = [castingCharacter.modelID copy];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ stellt einen geistigen Band zu seiner Kristallkugel her. Die Kugel wird unzerstörbar.", castingCharacter.name];
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of DSASpellKugelzauberEins

@implementation DSASpellMageRitualKugelzauberZwei
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualKugelzauberZwei castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf der Kristallkugel aktiv."), self.name];
            return spellResult;
          }
      }
  
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }

  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      DSASpell *lensRitual = [DSASpellMageRitual ritualWithName: _(@"Brennglas")
                                                      ofVariant: nil
                                              ofDurationVariant: nil
                                                     ofCategory: _(@"Kugelzauber")
                                                       withTest: @[]
                                                withMaxDistance: -1       
                                                   withVariants: nil       
                                           withDurationVariants: nil 
                                                    withPenalty: 0
                                                    withASPCost: 0
                                           withPermanentASPCost: 0
                                                     withLPCost: 0
                                            withPermanentLPCost: 0];
      [castingCharacter.specials setObject: lensRitual forKey: _(@"Brennglas")];       
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann seine Kristallkugel von nun an in ein variables Brennglas verwandeln.", castingCharacter.name];
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of DSASpellKugelzauberZwei

@implementation DSASpellMageRitualKugelzauberDrei
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualKugelzauberDrei called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf der Kristallkugel aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
    
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      DSASpell *shieldRitual = [DSASpellMageRitual ritualWithName: _(@"Schutzfeld")
                                                      ofVariant: nil
                                              ofDurationVariant: nil          
                                                     ofCategory: _(@"Kugelzauber")
                                                       withTest: @[]
                                                withMaxDistance: -1       
                                                   withVariants: nil        
                                           withDurationVariants: nil
                                                    withPenalty: 0
                                                    withASPCost: 5
                                           withPermanentASPCost: 0
                                                     withLPCost: 0
                                            withPermanentLPCost: 0];
      [castingCharacter.specials setObject: shieldRitual forKey: _(@"Schutzfeld")];      
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann ab sofort ein silbrig schimmerndes Schutzfeld von zwei Schritt Radius erschaffen, um Untote, Vampire und Werwölfe fernzuhalten.", castingCharacter.name];
    }
  else
    {
      NSInteger diceResult = [Utils rollDice: @"1W20"] + 10;
      castingCharacter.currentLifePoints -= diceResult;    
      NSInteger diceResult2 = [Utils rollDice: @"1W10"];
      spellResult.resultDescription = [NSString stringWithFormat: @"Die Kristallkugel erhitzt sich so stark, das sie %@ %ld Schadenspunkte zufügt.", castingCharacter.name, (signed long) diceResult];
      if (diceResult2 == 10)
        {
          spellResult.resultDescription = [NSString stringWithFormat: @"Die Kristallkugel erhitzt sich so stark, das sie %@ %ld Schadenspunkte zufügt, und dabei durch ihre eigenen magischen Gewalten zerbirst.", castingCharacter.name, (signed long) diceResult];
          // not replacing it, just removing the destroyed chrystal ball
          [[DSAInventoryManager sharedManager] replaceItem: target
                                                   inModel: castingCharacter
                                                  withItem: nil];
        }
      castingCharacter.currentAstralEnergy -= self.aspCost;
    }
  
  return spellResult;
}
@end
// End of Kugelzauber Drei

@implementation DSASpellMageRitualKugelzauberVier
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualKugelzauberVier called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf der Kristallkugel aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
    
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      DSASpell *lensRitual = [DSASpellMageRitual ritualWithName: _(@"Auge des Zorns")
                                                      ofVariant: nil
                                              ofDurationVariant: nil
                                                     ofCategory: _(@"Kugelzauber")
                                                       withTest: @[]
                                                withMaxDistance: -1       
                                                   withVariants: nil       
                                           withDurationVariants: nil 
                                                    withPenalty: 0
                                                    withASPCost: 3
                                           withPermanentASPCost: 0
                                                     withLPCost: 0
                                            withPermanentLPCost: 0];
      [castingCharacter.specials setObject: lensRitual forKey: _(@"Auge des Zorns")];      
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ kann ab sofort die Kugel einsetzten, um starke Wellen von Haß oder Mordlust gegen ihn anzeigen zu lassen, wenn diese solche in der Nähe verspürt.", castingCharacter.name];
    }
  else
    {   
      spellResult.resultDescription = [NSString stringWithFormat: @"Leider fehlgeschlagen."];
      castingCharacter.currentAstralEnergy -= self.aspCost;
    }
  
  return spellResult;
}
@end
// End of Kugelzauber Vier

@implementation DSASpellMageRitualKugelzauberFuenf
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellMageRitualKugelzauberFuenf called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([[target appliedSpells] count] > 0)
    for (NSString *spellName in [[target appliedSpells] allKeys])
      {
        if ([spellName isEqualToString: self.name])
          {
            spellResult.result = DSASpellResultNone;
            spellResult.resultDescription = [NSString stringWithFormat: _(@"Der %@ ist schon auf dem Magierstab aktiv."), self.name];
            return spellResult;
          }
      }
  if (castingCharacter.currentAstralEnergy < self.aspCost)  // need enough AE
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ hat nicht genug Astralenergie."), castingCharacter.name];
      return spellResult;
    }
  
  spellResult = [self testTraitsWithSpellLevel: self.penalty castingCharacter: castingCharacter];
  
  if (spellResult.result == DSASpellResultSuccess || 
      spellResult.result == DSASpellResultAutoSuccess ||
      spellResult.result == DSASpellResultEpicSuccess)
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      castingCharacter.astralEnergy -= self.permanentASPCost;
      DSASpell *ropeRitual = [DSASpellMageRitual ritualWithName: _(@"Kristallkugel herbeirufen")
                                                      ofVariant: nil
                                              ofDurationVariant: nil        
                                                     ofCategory: _(@"Kugelzauber")
                                                       withTest: @[]
                                                withMaxDistance: 7000       // 7 Meilen
                                                   withVariants: nil        
                                           withDurationVariants: nil
                                                    withPenalty: 0
                                                    withASPCost: 0
                                           withPermanentASPCost: 0
                                                     withLPCost: 0
                                            withPermanentLPCost: 0];
      [castingCharacter.specials setObject: ropeRitual forKey: _(@"Kristallkugel herbeirufen")];  
      [target.appliedSpells setObject: [self copy] forKey: self.name];
      spellResult.resultDescription = [NSString stringWithFormat: @"%@ festigt den Band mit seiner Kristallkugel und kann sie nun aus bis zu 7 Meilen Entfernung herbeirufen.", castingCharacter.name];   
    }
  else
    {
      castingCharacter.currentAstralEnergy -= self.aspCost;
      spellResult.resultDescription = _(@"Leider fehlgeschlagen.");
    }
  
  return spellResult;
}
@end
// End of Kugelzauber Fünf


@implementation DSASpellMageRitualKugelzauberBrennglas
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellKugelzauberBrennglas castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  NSLog(@"FOUND TARGET: %@", target);
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([target.states containsObject: @(DSAObjectStateHasSpellActive)])
    {
      if (![target.states containsObject: @(DSAObjectStateKugelzauberBrennglas)])
        {
          spellResult.result = DSASpellResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Ein anderer Zauber ist schon auf der Kristallkugel aktiv.")];
          return spellResult;
        }
      
      [target.states removeObject: @(DSAObjectStateKugelzauberBrennglas)];
      [target.states removeObject: @(DSAObjectStateHasSpellActive)];
      spellResult.resultDescription = [NSString stringWithFormat: @"Das Brennglas verwandelt sich in die Kristallkugel zurück."];
      return spellResult;
    }
  [target.states addObject: @(DSAObjectStateKugelzauberBrennglas)];
  [target.states addObject: @(DSAObjectStateHasSpellActive)];
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"Die Kristallkugel verwandelt sich in ein Brennglas mit variabler Brennweite."];
  return spellResult;
}
@end
// End of DSASpellKugelzauberBrennglas

@implementation DSASpellMageRitualKugelzauberSchutzfeld
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellKugelzauberSchutzfeld castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([target.states containsObject: @(DSAObjectStateHasSpellActive)])
    {
      if (![target.states containsObject: @(DSAObjectStateKugelzauberSchutzfeld)])
        {
          spellResult.result = DSASpellResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Ein anderer Zauber ist schon auf der Kristallkugel aktiv.")];
          return spellResult;
        }
      
      [target.states removeObject: @(DSAObjectStateKugelzauberSchutzfeld)];
      [target.states removeObject: @(DSAObjectStateHasSpellActive)];
      spellResult.resultDescription = [NSString stringWithFormat: @"Das Schutzfeld um %@ gegen Untote, Vampire und Werwölfe verschwindet wieder.", castingCharacter.name];
      return spellResult;
    }
  [target.states addObject: @(DSAObjectStateKugelzauberSchutzfeld)];
  [target.states addObject: @(DSAObjectStateHasSpellActive)];
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"Ein silbrig schimmerndes Schutzfeld gegen Untote, Vampire und Werwölfe, von 2 Schritt Radius, baut sich um %@ auf.", castingCharacter.name];
  return spellResult;
}
@end
// End of DSASpellKugelzauberSchutzfeld

@implementation DSASpellMageRitualKugelzauberWarnung
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  NSLog(@"DSASpellKugelzauberWarnung castOnTarget called!");
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];

  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  if ([target.states containsObject: @(DSAObjectStateHasSpellActive)])
    {
      if (![target.states containsObject: @(DSAObjectStateKugelzauberWarnung)])
        {
          spellResult.result = DSASpellResultNone;
          spellResult.resultDescription = [NSString stringWithFormat: _(@"Ein anderer Zauber ist schon auf der Kristallkugel aktiv.")];
          return spellResult;
        }
      
      [target.states removeObject: @(DSAObjectStateKugelzauberWarnung)];
      [target.states removeObject: @(DSAObjectStateHasSpellActive)];
      spellResult.resultDescription = [NSString stringWithFormat: @"Die Kristallkugel wird grellrot aufleuchten, wenn diese in der näheren Umgebung starke Wellen von Haß oder Mordlust gegenüber %@ verspürt.", castingCharacter.name];
      return spellResult;
    }
  [target.states addObject: @(DSAObjectStateKugelzauberWarnung)];
  [target.states addObject: @(DSAObjectStateHasSpellActive)];
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"Die Kristallkugel wird sich rot verfärben, wenn sie in der Umgebung starke Wellen von Haß oder Mordlust gegen %@ verspürt.", castingCharacter.name];
  return spellResult;
}
@end
// End of DSASpellKugelzauberWarnung

@implementation DSASpellMageRitualKugelzauberHerbeirufen
- (DSASpellResult *) castOnTarget: (id) target_ignored
                        ofVariant: (NSString *) variant
                ofDurationVariant: (NSString *) durationVariant                        
                       atDistance: (NSInteger) distance
                      investedASP: (NSInteger) investedASP 
             spellOriginCharacter: (DSACharacter *) originCharacter
            spellCastingCharacter: (DSACharacter *) castingCharacter
{
  DSASpellResult *spellResult = [[DSASpellResult alloc] init];
  
  // we ignore any target we got
  DSAObject *target = [[DSAInventoryManager sharedManager] findItemWithName: @"Kristallkugel" inModel: castingCharacter];
  if (![target.ownerUUID isEqual: castingCharacter.modelID])
    {
      spellResult.result = DSASpellResultNone;
      spellResult.resultDescription = [NSString stringWithFormat: _(@"%@ ist ein ungültiges Ziel."), [(DSAObject *)target name]];
      return spellResult;
    }
  castingCharacter.currentAstralEnergy -= self.aspCost;
  spellResult.resultDescription = [NSString stringWithFormat: @"%@ ruft die Kristallkugel zurück.", castingCharacter.name];
  return spellResult;
}
@end
// End of DSASpellKugelzauberHerbeirufen