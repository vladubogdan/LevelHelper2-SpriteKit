//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneDemo.h"

@implementation LHSceneDemo

+(id)scene
{
    [[LHConfig sharedInstance] enableDebug];
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/officerLevel.plist"];
    
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        {
            CGSize size = [self size];
            
            {
                SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                [label setName:@"PreviousLabel"];
                [label setFontSize:32];
                [label setZPosition:60];
                [label setText:@"Previous"];
                [label setFontColor:[SKColor greenColor]];
                [label setPosition:CGPointMake(80, 150)];
                [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
                [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                [[self uiNode] addChild:label];
            }
            
            {
                SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                [label setName:@"RestartLabel"];
                [label setFontSize:32];
                [label setZPosition:60];
                [label setText:@"Restart"];
                [label setFontColor:[SKColor greenColor]];
                [label setPosition:CGPointMake(size.width*0.5, 150)];
                [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
                [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                [[self uiNode] addChild:label];
            }
        }
    }
    
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"PreviousLabel"]) {
        [self previousDemo];
    }
    if ([node.name isEqualToString:@"RestartLabel"]) {
        [self restartDemo];
    }
    if ([node.name isEqualToString:@"NextLabel"]) {
        [self nextDemo];
    }
}

-(void)previousDemo{
//     [[self view] presentScene:[[self class] scene]];
}

-(void)restartDemo{
    [[self view] presentScene:[[self class] scene]];
}

-(void)nextDemo{
//    [[self view] presentScene:[[self class] scene]];    
}

@end
