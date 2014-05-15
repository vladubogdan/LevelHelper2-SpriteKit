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

@interface LHAnimation : NSObject

+(instancetype)animationWithDictionary:(NSDictionary*)dict
                                  node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)n;

-(NSString*)name;

-(BOOL)isActive;
-(void)setActive:(BOOL)val;

-(float)totalTime;

-(float)currentFrame;
-(void)setCurrentFrame:(int)val;

-(void)setAnimating:(bool)val;
-(bool)animating;

-(void)updateTimeWithDelta:(float)delta;

-(int)repetitions;

-(id<LHNodeAnimationProtocol, LHNodeProtocol>)node;
@end
