//
//  LHSceneCollisionDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCollisionDemo.h"

@implementation LHSceneCollisionDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/collisionDemo.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        
#if LH_USE_BOX2D
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"COLLISION DEMO\nWatch the console for collision information.\nCheck the LHSceneCollisionDemo.mm for more info.\n\nWhen the car tyre will enter the gravity area it will be thrown upwards.\nIf the position of the car tyre is under the wood object collision will be disabled.\nWhen its on top of it, collision will occur."];
#else
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"COLLISION DEMO\nWatch the console for collision information.\nIn Xcode, switch to the Box2d target for a more advanced collision handling system."];
#endif
        
    }
    
    return self;
}


#if LH_USE_BOX2D

-(BOOL)shouldDisableContactBetweenNodeA:(SKNode *)a andNodeB:(SKNode *)b
{
    NSLog(@"SHOULD DISABLE CONTACT BETWEEN %@ and %@", [a name], [b name]);
    
    if(
       ([[a name] isEqualToString:@"carTyre"] && [[b name] isEqualToString:@"shouldNotCollide"]) ||
       ([[b name] isEqualToString:@"carTyre"] && [[a name] isEqualToString:@"shouldNotCollide"])
       )
    {
        if([[a name] isEqualToString:@"carTyre"])
        {
            if([a position].y < [b position].y){
                return YES;
            }
        }
        
        if([[b name] isEqualToString:@"carTyre"])
        {
            if([b position].y < [a position].y){
                return YES;
            }
        }
    }
    return NO;
}

-(void)didBeginContactBetweenNodeA:(SKNode*)a
                          andNodeB:(SKNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse
{
    NSLog(@"DID BEGIN CONTACT %@ %@ scenePt %@ impulse %f", [a name], [b name], LHStringFromPoint(scenePt), impulse);
}

-(void)didEndContactBetweenNodeA:(SKNode*)a
                        andNodeB:(SKNode*)b
{
    NSLog(@"DID END CONTACT BETWEEN A:%@ AND B:%@", [a name], [b name]);
}

#else //spritekit

//when using spritekit we have the following 2 methods that needs to be overwriten
- (void)didBeginContact:(SKPhysicsContact *)contact{
    
    NSLog(@"DID BEGIN CONTACT NODE A: %@ B: %@", [[[contact bodyA] node] name], [[[contact bodyB] node] name]);
}
- (void)didEndContact:(SKPhysicsContact *)contact{
    
    NSLog(@"DID END CONTACT NODE A: %@ B: %@", [[[contact bodyA] node] name], [[[contact bodyB] node] name]);
}
#endif

@end
