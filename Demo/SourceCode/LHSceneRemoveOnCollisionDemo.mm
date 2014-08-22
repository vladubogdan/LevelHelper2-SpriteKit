//
//  LHSceneRemoveOnCollisionDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneRemoveOnCollisionDemo.h"

@implementation LHSceneRemoveOnCollisionDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/removeOnCollisionDemo.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        
#if LH_USE_BOX2D
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"REMOVE OBJECTS ON COLLISION\nIf you are familiar with Box2d then you will know that\nremoving a body in the collision callback function will make Box2d library assert as the world is locked.\nThe LevelHelper API solves this by sending the callbacks when its safe.\nCut the rope to remove the bodies when collision occurs."];
#else
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"REMOVE OBJECTS ON COLLISION\nCurrently SpriteKit does not offer a way to disable collision between objects while still getting collision callback.\nIf you disable collision between two object using masks then you will no longer get a callback.\nSwitch to Box2d target for advanced collision detection.\nCut the rope to remove the bodies when collision occurs."];
#endif
        
    }
    
    return self;
}

-(void)handleCandy:(SKNode*)candy collisionWithNode:(SKNode*)node
{
    if([node conformsToProtocol:@protocol(LHNodeProtocol)])
    {
        LHNode* n = (LHNode*)node;
        
        if([[n tags] containsObject:@"BANANA"])
        {
            [n removeFromParent];
        }
    }
}

#if LH_USE_BOX2D

-(BOOL)disableCandyCollisionWithNode:(SKNode*)node
{
    if([node conformsToProtocol:@protocol(LHNodeProtocol)])
    {
        LHNode* n = (LHNode*)node;
        
        if([[n tags] containsObject:@"BANANA"])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)shouldDisableContactBetweenNodeA:(SKNode *)a andNodeB:(SKNode *)b
{
    if([[a name] isEqualToString:@"candy"])
    {
        return [self disableCandyCollisionWithNode:b];
    }
    else
    {
        return [self disableCandyCollisionWithNode:a];
    }
    
    return NO;
}

-(void)didBeginContactBetweenNodeA:(SKNode*)a
                          andNodeB:(SKNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse
{
    if([[a name] isEqualToString:@"candy"])
    {
        [self handleCandy:a collisionWithNode:b];
    }
    else
    {
        [self handleCandy:b collisionWithNode:a];
    }
    
    NSLog(@"DID BEGIN CONTACT %@ %@ scenePt %@ impulse %f", [a name], [b name], LHStringFromPoint(scenePt), impulse);
}


#else //spritekit

//when using spritekit we have the following 2 methods that needs to be overwriten
- (void)didBeginContact:(SKPhysicsContact *)contact{
    
    if([[[[contact bodyA] node] name] isEqualToString:@"candy"])
    {
        [self handleCandy:[[contact bodyA] node] collisionWithNode:[[contact bodyB] node] ];
    }
    else
    {
        [self handleCandy:[[contact bodyB] node] collisionWithNode:[[contact bodyA] node] ];
    }
}

#endif

@end
