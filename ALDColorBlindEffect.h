//
//  ALDColorBlindEffect.h
//  ALDColorBlindEffect
//
//  Created by Andy Drizen on 12/07/2014.
//  Copyright (c) 2014 Andy Drizen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ALDColorBlindEffectType) {
    /**
     This option does not alter the colors of the view.
     */
    ALDColorBlindEffectTypeNone,
    
    /**
     Lacking the long-wavelength sensitive retinal cones, those with this 
     condition are unable to distinguish between colors in the green–yellow–red 
     section of the spectrum.
     
     Affects 1% of males.
     */
    ALDColorBlindEffectTypeProtanopia,
    
    /**
     Lacking the medium-wavelength cones, those affected are again unable to
     distinguish between colors in the green–yellow–red section of the spectrum.
     
     Affects 1% of males.
     */
    ALDColorBlindEffectTypeDeuteranopia,
    
    /**
     Lacking the short-wavelength cones, those affected see short-wavelength 
     colors (blue, indigo and a spectral violet) greenish and drastically 
     dimmed, some of these colors even as black. Yellow is indistinguishable 
     from pink, and purple colors are perceived as various shades of red.
     
     Affects than 1% of males and females.
     */
    ALDColorBlindEffectTypeTritanopia,
    
    /**
     Monochromacy is the condition of possessing only a single channel for
     conveying information about color. Monochromats possess a complete
     inability to distinguish any colors and perceive only variations in
     brightness.
     
     While normally rare, Rod monochromacy (or achromatopsia) is very common on 
     the island of Pingelap, a part of the Pohnpei state, Federated States of 
     Micronesia, where it is called maskun: about 10% of the population there 
     has it, and 30% are unaffected carriers.
     */
    ALDColorBlindEffectTypeRodMonochromacy,
    
    /**
     Cone monochromacy is the condition of having both rods and cones, but only 
     a single kind of cone. A cone monochromat can have good pattern vision at 
     normal daylight levels, but will not be able to distinguish hues.
     */
    ALDColorBlindEffectTypeConeMonochromacyLRed,
    ALDColorBlindEffectTypeConeMonochromacyMGreen,
    ALDColorBlindEffectTypeConeMonochromacySBlue,
    
    /**
     Dogs have two different color receptors in their eyes and therefore are 
     dichromats. One color receptor peaks at the blue-violet range, the other 
     at the yellow-green range. Dogs are green-blind which is one form of 
     red-green color blindness also called deuteranopia.
     */
    ALDColorBlindEffectTypeDog
};

typedef NS_ENUM(NSInteger, ALDColorBlindEffectQuality) {
    ALDColorBlindEffectQualityLow,
    ALDColorBlindEffectQualityMedium,
    ALDColorBlindEffectQualityHigh
};

@interface ALDColorBlindEffect : NSObject

/**
 The type of color-blindness you wish to simulate.
 */
@property (nonatomic, assign) ALDColorBlindEffectType type;

/**
 The amount of blur (i.e. general poor vision) you wish to simulate. Default
 is 0.
 */
@property (nonatomic, assign) CGFloat blurAmount;

/**
 If you need to maintain a high frame rate, set a lower quality. Default is
 ALDColorBlindEffectQualityHigh.
 */
@property (nonatomic, assign) ALDColorBlindEffectQuality quality;

/**
 The view to which the effect should be applied.
 */
@property (nonatomic, weak) UIView *view;

/**
 A shared object that you can use to manage the global settings of the effect.
 
 @return The shared instance.
 */
+ (ALDColorBlindEffect *)sharedInstance;

@end
