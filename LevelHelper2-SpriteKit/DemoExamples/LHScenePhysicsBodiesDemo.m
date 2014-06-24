//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHScenePhysicsBodiesDemo.h"
#import "LHSceneCameraDemo.h"
@implementation LHScenePhysicsBodiesDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/physicsBodiesTest.plist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        {
            CGSize size = [[self scene] size];
            
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            [label setName:@"InfoLabel"];
            [label setFontSize:16];
            [label setZPosition:60];
            [label setText:@"Physics Bodies Test\nTest physics bodies on various node types."];
            [label setFontColor:[SKColor blackColor]];
            [label setPosition:CGPointMake(size.width*0.5, size.height*0.5)];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [[self uiNode] addChild:label];
        }
    }
    
    return self;
}

-(void)previousDemo{
        [[self view] presentScene:[LHSceneCameraDemo scene]];
}

-(void)nextDemo{
    
}

@end
