//
//  LHNodeAnimationProtocol.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class LHAnimation;

/**
 LevelHelper 2 nodes that can be animated conform to this protocol.
 */

@protocol LHNodeAnimationProtocol <NSObject>

@required

/**
 Set the active animation on a node.
 @param animation The animation that is about to get activated.
 */
-(void)setActiveAnimation:(LHAnimation*)animation;

/**
 Returns the active animation on a node or nil if no active animation.
 */
-(LHAnimation*)activeAnimation;

/**
 Returns the animation with a given name or nil if no animation with the specified name is found on the node.
 @param animName The name of the animation.
 */
-(LHAnimation*)animationWithName:(NSString*)animName;

/**
 Returns all animations available on this node.
 */
-(NSArray*)animations;


/**
 Set position on the node controlled by the animation.
 @param point A point value.
 */
-(void)setPosition:(CGPoint)point;

/**
 Set rotation on the node controlled by the animation.
 @param radians A rotation value in radians.
 */
-(void)setZRotation:(CGFloat)radians;

/**
Set x scale on the node controlled by the animation.
@param xScale A scale value for the x axis.
*/
-(void)setXScale:(CGFloat)xScale;

/**
 Set y scale on the node controlled by the animation.
 @param yScale A scale value for the y axis.
 */
-(void)setYScale:(CGFloat)yScale;

/**
 Set opacity on the node controlled by the animation.
 @param opacity A opacity value between 0 and 1.
 */
-(void)setAlpha:(CGFloat)opacity;

@end


@interface LHNodeAnimationProtocolImp : NSObject

+ (instancetype)animationProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode*)nd;
- (instancetype)initAnimationProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode*)nd;

- (void)update:(NSTimeInterval)currentTime delta:(float)dt;

-(void)setActiveAnimation:(LHAnimation*)anim;
-(LHAnimation*)activeAnimation;
-(LHAnimation*)animationWithName:(NSString*)animName;
-(NSArray*)animations;
@end

#define LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION  \
-(void)setActiveAnimation:(LHAnimation*)anim{\
[_animationProtocolImp setActiveAnimation:anim];\
}\
-(LHAnimation*)activeAnimation{\
return [_animationProtocolImp activeAnimation];\
}\
-(LHAnimation*)animationWithName:(NSString*)animName{\
return [_animationProtocolImp animationWithName:animName];\
}\
-(NSArray*)animations{\
    return [_animationProtocolImp animations];\
}


