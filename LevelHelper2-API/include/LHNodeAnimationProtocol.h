//
//  LHNodeAnimationProtocol.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LHAnimation;

@protocol LHNodeAnimationProtocol <NSObject>

@required
////////////////////////////////////////////////////////////////////////////////

-(void)setActiveAnimation:(LHAnimation*)anim;

-(void)setPosition:(CGPoint)point;
-(void)setZRotation:(float)val;//radians

-(void)setXScale:(float)val;
-(void)setYScale:(float)val;

-(void)setAlpha:(float)val;

@end
