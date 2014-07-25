//
//  CCEffectNode.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/26/14.
//
//

#import <Foundation/Foundation.h>

#import "ccMacros.h"
#import "CCNode.h"
#import "CCRenderTexture.h"
#import "CCSprite.h"
#import "CCTexture.h"


#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif // iPHone

@interface CCEffectNode : CCRenderTexture <CCEffectProtocol>

-(id)initWithWidth:(int)w height:(int)h;

@end
