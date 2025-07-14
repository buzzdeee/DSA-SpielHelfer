/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-20 21:56:38 +0200 by sebastia

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

#ifndef _DSAGOD_H_
#define _DSAGOD_H_

#import <Foundation/Foundation.h>
#import "DSACharacter.h"
@class DSAAdventureGroup;
@class DSAMiracleResult;
@class DSAAventurianDate;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DSAGodType) {
    DSAGodTypeUnknown = 0,
    DSAGodTypePraios,
    DSAGodTypeRondra,
    DSAGodTypeEfferd,
    DSAGodTypeTravia,
    DSAGodTypeBoron,
    DSAGodTypeHesinde,
    DSAGodTypeFirun,
    DSAGodTypeTsa,
    DSAGodTypePhex,
    DSAGodTypePeraine,
    DSAGodTypeIngerimm,
    DSAGodTypeRahja,
    DSAGodTypeSwafnir,
    DSAGodTypeIfirn,
    DSAGodTypeLast,
};

@interface DSAGod : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) DSAGodType godType;
@property (nonatomic, copy) NSString *name;

/// Aktuelles Ansehen der Gruppe bei diesem Gott
@property (nonatomic, assign) NSInteger reputation;

+ (instancetype)godWithType:(DSAGodType)type;

// class helper methods to translate DSAGodType to and from names
+ (DSAGodType)godTypeByName:(NSString *)name;
+ (NSString *)nameForGodType:(DSAGodType)type;

/// Erhöht das Ansehen (z. B. durch gottgefällige Taten oder Spenden)
- (void)increaseReputationBy:(NSInteger)amount;

/// Verringert das Ansehen bei Wunderbitten (geht nicht unter 0)
- (void)decreaseReputationBy:(NSInteger)amount;

/// Verringert das Ansehen unabhängig von 0-Grenze (für gotteslästerliches Verhalten)
- (void)forceDecreaseReputationBy:(NSInteger)amount;

/// Wunderbitte, Rückgabe ob erfolgreich, Ergebnis optional
- (BOOL)requestMiracleWithFame:(NSInteger)fame
                      forGroup:(DSAAdventureGroup *) group
                        atDate:(DSAAventurianDate *) currentDate
                        result:(DSAMiracleResult * _Nullable * _Nullable)outResult;

@end
NS_ASSUME_NONNULL_END

@interface DSAGodPraios : DSAGod
@end
@interface DSAGodRondra : DSAGod
@end
@interface DSAGodEfferd : DSAGod
@end
@interface DSAGodTravia : DSAGod
@end
@interface DSAGodBoron : DSAGod
@end
@interface DSAGodHesinde : DSAGod
@end
@interface DSAGodFirun : DSAGod
@end
@interface DSAGodTsa : DSAGod
@end
@interface DSAGodPhex : DSAGod
@end
@interface DSAGodPeraine : DSAGod
@end
@interface DSAGodIngerimm : DSAGod
@end
@interface DSAGodRahja : DSAGod
@end
@interface DSAGodSwafnir : DSAGod
@end
@interface DSAGodIfirn : DSAGodFirun
@end


NS_ASSUME_NONNULL_BEGIN
/*
typedef NS_ENUM(NSInteger, DSAMiracleResultType) {
    DSAMiracleResultTypeTraitBoost,
    DSAMiracleResultTypeTalentBoost,
    DSAMiracleResultTypeMagicBoost,
    DSAMiracleResultTypeTalentAutoSuccess,
    DSAMiracleResultTypeMRBoost,
    DSAMiracleResultTypeMagicProtection,
    DSAMiracleResultTypeSeaProtection,
    DSAMiracleResultTypeRemoveCurse,
    DSAMiracleResultTypeCureDisease,
    DSAMiracleResultTypeRevive,
    DSAMiracleResultTypeSatiation,
    DSAMiracleResultTypeNoHungerThirst,
    DSAMiracleResultTypeHeal,
    DSAMiracleResultTypeFullHeal,
    DSAMiracleResultTypeNightPeace,    
    DSAMiracleResultTypeProtectionAgainstUndead,
    DSAMiracleResultTypeFearOfDead,
    DSAMiracleResultTypeWeaponBlessing,
    DSAMiracleResultTypeUpgradeWeaponToMagic,
    DSAMiracleResultTypeEnchantWeapon,
    DSAMiracleResultTypeRepairAndEnchant,
    DSAMiracleResultTypePlaceholder,    
    DSAMiracleResultTypeNothing
};
*/
// Praios
extern NSString * const DSAMiracleKeyPraiosTempMUBoost;
extern NSString * const DSAMiracleKeyPraiosTempMRBoost;

// Rondra
extern NSString * const DSAMiracleKeyRondraTempSwordBoost;
extern NSString * const DSAMiracleKeyRondraTempMagicProtection;

// Rahja
extern NSString * const DSAMiracleKeyRahjaPermanentTanzenBetören;

// Boron
extern NSString * const DSAMiracleKeyBoronPermanentSchutzVorUntoten;

// Ingerimm
extern NSString * const DSAMiracleKeyIngerimmMagischeWaffe;
extern NSString * const DSAMiracleKeyIngerimmWaffenreparaturUndMagie;

// Tsa
extern NSString * const DSAMiracleKeyTsaJungbrunnen;

// Efferd
extern NSString * const DSAMiracleKeyEfferdSeefahrtSegen;

// Travia
extern NSString * const DSAMiracleKeyTraviaNightPeace;

// Phex
extern NSString * const DSAMiracleKeyPhexGlücksdiebSegen;

// Hesinde
extern NSString * const DSAMiracleKeyHesindeWissenDerGötter;

// Firun
extern NSString * const DSAMiracleKeyFirunEwigerFrostschutz;

@interface DSAMiracleResult : NSObject

@property (nonatomic, assign) DSACharacterEffectType type;
@property (nonatomic, copy) NSString *effectDescription;
@property (nonatomic, strong, nullable) DSAAventurianDate * expirationDate;
@property (nonatomic, copy) NSString *target; // "group" or "individual"
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSNumber *> *statChanges;
@property (nonatomic, strong, nullable) NSString *uniqueKey;

- (instancetype)initWithType:(DSACharacterEffectType)type
                 description:(NSString *)desc
              expirationDate:(nullable DSAAventurianDate *)expirationDate
                statChanges:(nullable NSDictionary<NSString *, NSNumber *> *)statChanges
                      target:(NSString *)target
                   uniqueKey:(nullable NSString *)uniqueKey;

@end

NS_ASSUME_NONNULL_END


#endif // _DSAGOD_H_

