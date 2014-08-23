//
//  LHAnimation.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LHNodeAnimationProtocol.h"
#import "LHNodeProtocol.h"

/**
 The animation object that is used to transform one or multiple nodes during a period of time.
 */
@interface LHAnimation : NSObject

+(instancetype)animationWithDictionary:(NSDictionary*)dict
                                  node:(id< LHNodeAnimationProtocol , LHNodeProtocol >)n;

/**
 The name of the animation.
 */
-(NSString*)name;

/**
 Wheter or not this animation is active. The one that is currently played.
 */
-(BOOL)isActive;

/**
 Set this animation as the active one.
 @param active A BOOL value specifying the active state of the animation.
 */
-(void)setActive:(BOOL)active;

/**
 The time it takes for the animation to finish a loop.
 */
-(float)totalTime;

/**
 Current frame of the animation. As defines in LevelHelper 2 editor.
 */
-(float)currentFrame;

/**
 Move the animation to a frame.
 @param value The frame number where the animation should jump to.
 */
-(void)setCurrentFrame:(int)value;

/**
 Set the animations as playing or paused.
 @param animating A BOOL value that will set the animation as playing or paused.
 */
-(void)setAnimating:(bool)animating;

/**
 Wheter or not the animation is currently playing.
 */
-(bool)animating;

/**
 Restarts the animation. Will set the time to 0 and reset all repetitions.
 */
-(void)restart;

/**
 The number of times this animation will loop. A 0 repetitions meens it will loop undefinately.
 */
-(int)repetitions;

/**
 The number of times this animation has looped.
 */
-(int)currentRepetition;

/**
 The node on which this animation is assigned.
 */
-(id< LHNodeAnimationProtocol , LHNodeProtocol >)node;

/**
 Force the animation to go forward in time by adding the delta value to the current animation time.
 @param delta A value that will be appended to the current animation time.
 */
-(void)updateTimeWithDelta:(float)delta;

@end
