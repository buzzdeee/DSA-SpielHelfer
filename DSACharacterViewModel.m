/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-19 22:03:00 +0200 by sebastia

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

#import "DSACharacterViewModel.h"
#import "DSACharacter.h"
#import "DSAWallet.h"

@implementation DSACharacterViewModel

- (void)setModel:(DSACharacterHero *)model {
    if (_model != model) {
        // Remove observers from the old model
        [_model removeObserver:self forKeyPath:@"lifePoints"];
        [_model removeObserver:self forKeyPath:@"currentLifePoints"];
        [_model removeObserver:self forKeyPath:@"astralEnergy"];
        [_model removeObserver:self forKeyPath:@"currentAstralEnergy"];
        [_model removeObserver:self forKeyPath:@"karmaPoints"];
        [_model removeObserver:self forKeyPath:@"currentKarmaPoints"];
        [_model removeObserver:self forKeyPath:@"wallet.dukaten"];                
        [_model removeObserver:self forKeyPath:@"wallet.silber"];
        [_model removeObserver:self forKeyPath:@"wallet.kreuzer"];
        [_model removeObserver:self forKeyPath:@"wallet.heller"];        
        _model = model;
        
        // Add observers for the new model
        [_model addObserver:self forKeyPath:@"lifePoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"currentLifePoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"astralEnergy" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"currentAstralEnergy" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"karmaPoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"currentKarmaPoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"wallet.dukaten" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"wallet.silber" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"wallet.heller" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"wallet.kreuzer" options:NSKeyValueObservingOptionNew context:NULL];
        
        for (NSString *trait in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
          {
            [_model addObserver:self forKeyPath:[NSString stringWithFormat: @"positiveTraits.%@.level", trait] options:NSKeyValueObservingOptionNew context:NULL];
            [_model addObserver:self forKeyPath:[NSString stringWithFormat: @"currentPositiveTraits.%@.level", trait] options:NSKeyValueObservingOptionNew context:NULL];
          }

        for (NSString *trait in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
          {
            [_model addObserver:self forKeyPath:[NSString stringWithFormat: @"negativeTraits.%@.level", trait] options:NSKeyValueObservingOptionNew context:NULL];
            [_model addObserver:self forKeyPath:[NSString stringWithFormat: @"currentNegativeTraits.%@.level", trait] options:NSKeyValueObservingOptionNew context:NULL];
          }
                                                 
        // Synchronize the ViewModel's properties with the model's properties
        NSLog(@"DSACharacterViewModel: setModel: _model.wallet: %@", _model.wallet);
        self.wallet = _model.wallet;
        [self updateFormattedWallet];
        
        self.lifePoints = _model.lifePoints;
        self.currentLifePoints = _model.currentLifePoints;     
        [self updateFormattedLifePoints];

        self.astralEnergy = _model.astralEnergy;
        self.currentAstralEnergy = _model.currentAstralEnergy;        
        [self updateFormattedAstralEnergy];

        self.karmaPoints = _model.karmaPoints;
        self.currentKarmaPoints = _model.currentKarmaPoints;        
        [self updateFormattedKarmaPoints];
        
        self.positiveTraits = _model.positiveTraits;
        self.currentPositiveTraits = _model.currentPositiveTraits;
        [self updateFormattedPositiveTraits];
        
        self.negativeTraits = _model.negativeTraits;
        self.currentNegativeTraits = _model.currentNegativeTraits;
        [self updateFormattedNegativeTraits];        
                
    }
}

- (void)updateFormattedPositiveTraits
{
  NSMutableDictionary *formattedPositiveTraits = [[NSMutableDictionary alloc] init];
  for (NSString *trait in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {
      // NSLog(@"DSACharacterViewModel: updateFormattedPositiveTraits: %@ %@", trait, [self.currentPositiveTraits objectForKey: trait]);
      NSString *formattedString = [NSString stringWithFormat: @"%ld/%ld",
                                  (signed long)[[self.currentPositiveTraits objectForKey: trait] level],
                                  (signed long)[[self.positiveTraits objectForKey: trait] level]];
      [formattedPositiveTraits setObject: formattedString forKey: trait];
    }
  self.formattedPositiveTraits = formattedPositiveTraits;
}

- (void)updateFormattedNegativeTraits
{
  NSMutableDictionary *formattedNegativeTraits = [[NSMutableDictionary alloc] init];
  for (NSString *trait in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      NSString *formattedString = [NSString stringWithFormat: @"%ld/%ld",
                                  (signed long)[[self.currentNegativeTraits objectForKey: trait] level],
                                  (signed long)[[self.negativeTraits objectForKey: trait] level]];
      [formattedNegativeTraits setObject: formattedString forKey: trait];
    }
  self.formattedNegativeTraits = formattedNegativeTraits;
}


- (void)updateFormattedWallet
{
  NSLog(@"DSACharacterViewModel updateFormattedWallet BEFORE %@", self.wallet);
  if (!self.wallet) {
      self.formattedWallet = @"-";
      return;
  }  
  NSString *formattedString = [NSString stringWithFormat:@"%ldD %ldS %ldH %ldK",
                               (long)self.wallet.dukaten,
                               (long)self.wallet.silber,
                               (long)self.wallet.heller,
                               (long)self.wallet.kreuzer];
  NSLog(@"DSACharacterViewModel: updateFormattedWallet AFTER %@", self.wallet);                               
  self.formattedWallet = formattedString;
}

- (void)updateFormattedLifePoints {
    NSString *formattedString = [NSString stringWithFormat:@"%ld/%ld",
                                 (signed long)self.currentLifePoints ?: 0,
                                 (signed long)self.lifePoints ?: 0];
    // NSLog(@"updateFormattedLifePoints: %@", formattedString);                               
    self.formattedLifePoints = formattedString;
}

- (void) updateFormattedAstralEnergy
{
  NSString *formattedString = [NSString stringWithFormat:@"%ld/%ld",
                               (signed long)self.currentAstralEnergy ?: 0,
                               (signed long)self.astralEnergy ?: 0];
  // NSLog(@"updateFormattedAstralEnergy: %@", formattedString);                                
  self.formattedAstralEnergy = formattedString;                               
}

- (void) updateFormattedKarmaPoints
{
  NSString *formattedString = [NSString stringWithFormat:@"%ld/%ld",
                               (signed long)self.currentKarmaPoints ?: 0,
                               (signed long)self.karmaPoints ?: 0];
  // NSLog(@"updateFormattedKarmaPoints: %@", formattedString);                               
  self.formattedKarmaPoints = formattedString;                               
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                       context:(void *)context
{
  // NSLog(@"DSACharacterViewModel observeValueForKeyPath: %@", keyPath);
  if ([keyPath hasPrefix:@"wallet."])
    {
      [self updateFormattedWallet];
    }
        
  if ([keyPath isEqualToString:@"lifePoints"])
    {
      // Update ViewModel's lifePoints when model's lifePoints changes
      self.lifePoints = _model.lifePoints;
      [self updateFormattedLifePoints];
    }
  else if ([keyPath isEqualToString:@"currentLifePoints"])
    {
      // Update ViewModel's currentLifePoints when model's currentLifePoints changes
      self.currentLifePoints = _model.currentLifePoints;
      [self updateFormattedLifePoints];
    }  
  else if ([keyPath isEqualToString:@"astralEnergy"])
    {
      // Update ViewModel's lifePoints when model's lifePoints changes
      self.astralEnergy = _model.astralEnergy;
      [self updateFormattedAstralEnergy];
    } 
  else if ([keyPath isEqualToString:@"currentAstralEnergy"])
    {
      // Update ViewModel's currentLifePoints when model's currentLifePoints changes
      self.currentAstralEnergy = _model.currentAstralEnergy;
      [self updateFormattedAstralEnergy];
    } 
  else if ([keyPath isEqualToString:@"karmaPoints"])
    {
      // Update ViewModel's lifePoints when model's lifePoints changes
      self.karmaPoints = _model.karmaPoints;
      [self updateFormattedKarmaPoints];
    }
  else if ([keyPath isEqualToString:@"currentKarmaPoints"])
    {
      // Update ViewModel's currentLifePoints when model's currentLifePoints changes
      self.currentKarmaPoints = _model.currentKarmaPoints;
      [self updateFormattedKarmaPoints];
    }
  else if ([keyPath hasPrefix:@"positiveTraits."])
    {
      self.positiveTraits = _model.positiveTraits;
      [self updateFormattedPositiveTraits];
    }    
  else if ([keyPath hasPrefix:@"negativeTraits."])
    {
      self.negativeTraits = _model.negativeTraits;
      [self updateFormattedNegativeTraits];
    }
  else if ([keyPath hasPrefix:@"currentPositiveTraits."])
    {
      self.currentPositiveTraits = _model.currentPositiveTraits;
      [self updateFormattedPositiveTraits];
    }    
  else if ([keyPath hasPrefix:@"currentNegativeTraits."])
    {
      self.currentNegativeTraits = _model.currentNegativeTraits;
      [self updateFormattedNegativeTraits];
    }    
}

- (void)dealloc
{
  [_model removeObserver:self forKeyPath:@"wallet.dukaten"];
  [_model removeObserver:self forKeyPath:@"wallet.silber"];
  [_model removeObserver:self forKeyPath:@"wallet.heller"];
  [_model removeObserver:self forKeyPath:@"wallet.kreuzer"];
    
  [_model removeObserver:self forKeyPath:@"lifePoints"];
  [_model removeObserver:self forKeyPath:@"currentLifePoints"];
  [_model removeObserver:self forKeyPath:@"astralEnergy"];
  [_model removeObserver:self forKeyPath:@"currentAstralEnergy"];
  [_model removeObserver:self forKeyPath:@"karmaPoints"];
  [_model removeObserver:self forKeyPath:@"currentKarmaPoints"];
  
  for (NSString *trait in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {
      [_model removeObserver:self forKeyPath:[NSString stringWithFormat: @"positiveTraits.%@.level", trait]];
      [_model removeObserver:self forKeyPath:[NSString stringWithFormat: @"currentPositiveTraits.%@.level", trait]];
    }

  for (NSString *trait in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      [_model removeObserver:self forKeyPath:[NSString stringWithFormat: @"negativeTraits.%@.level", trait]];
      [_model removeObserver:self forKeyPath:[NSString stringWithFormat: @"currentNegativeTraits.%@.level", trait]];
    }  
  
}

@end
