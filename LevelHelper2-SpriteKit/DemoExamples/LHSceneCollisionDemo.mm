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
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/collisionDemo.plist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"COLLISION DEMO\nWatch the console for collision information."];
        
    }
    
    return self;
}


#if LH_USE_BOX2D

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
