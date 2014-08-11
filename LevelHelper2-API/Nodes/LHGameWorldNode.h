//
//  LHGameWorldNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHConfig.h"

/**
 LHNode class is used to load the game world elements.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */

#if LH_USE_BOX2D
#ifdef __cplusplus
class b2World;
#endif
#endif

@interface LHGameWorldNode : SKSpriteNode <LHNodeProtocol>

+(instancetype)gameWorldNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt;

#if LH_USE_BOX2D
#ifdef __cplusplus
-(b2World*)box2dWorld;

-(void)setBox2dFixedTimeStep:(float)val;
-(void)setBox2dMinimumTimeStep:(float)val;
-(void)setBox2dVelocityIterations:(int)val;
-(void)setBox2dPositionIterations:(int)val;
-(void)setBox2dMaxSteps:(int)val;

#endif
#endif

-(void)setDebugDraw:(BOOL)val;
-(BOOL)debugDraw;

-(CGPoint)gravity;
-(void)setGravity:(CGPoint)val;

@end
