//
//  CCEffectStack.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"


@interface CCEffectStack : CCEffect

@property (nonatomic, readonly) NSUInteger effectCount;

- (id)init;
- (id)initWithEffects:(NSArray *)effects;

- (CCEffect *)effectAtIndex:(NSUInteger)effectIndex;

@end
