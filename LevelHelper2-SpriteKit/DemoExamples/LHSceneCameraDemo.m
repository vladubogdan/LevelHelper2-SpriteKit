//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCameraDemo.h"
#import "LHScenePhysicsBodiesDemo.h"

@implementation LHSceneCameraDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/officerLevel.plist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
//        {
//            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
//            [label setFontSize:32];
//            [label setFontColor:[SKColor redColor]];
//            [label setPosition:CGPointMake(150, 50)];
//            [self addChild:label];
//        }
    }
    
    return self;
}

-(void)previousDemo{
    
}

-(void)nextDemo{
    [[self view] presentScene:[LHScenePhysicsBodiesDemo scene]];
}

@end
