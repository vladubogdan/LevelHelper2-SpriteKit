//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCollisionFilteringDemo.h"
#import "LHScenePhysicsBodiesDemo.h"
@implementation LHSceneCollisionFilteringDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/collisionFilteringTest.plist"];
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
            [label setText:@"Collision Filtering Test"];
            [label setFontColor:[SKColor redColor]];
            [label setColor:[SKColor whiteColor]];
            [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [[self uiNode] addChild:label];
            
            {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"PINK collides only with BLUE"];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-70)];
            [[self uiNode] addChild:labelLine];
            }
            
            {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"BLUE collides only with PINK and GREEN"];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-90)];
            [[self uiNode] addChild:labelLine];
            }
            
            {
                SKLabelNode* labelLine = [label copy];
                [labelLine setText:@"GREEN collides with ALL"];
                [labelLine setPosition:CGPointMake(size.width*0.5, size.height-110)];
                [[self uiNode] addChild:labelLine];
            }
            
            {
                SKLabelNode* labelLine = [label copy];
                [labelLine setText:@"Click and drag to move the robots."];
                [labelLine setPosition:CGPointMake(size.width*0.5, size.height-130)];
                [[self uiNode] addChild:labelLine];
            }
        }
    }
    
    return self;
}

-(void)previousDemo{
    [[self view] presentScene:[LHScenePhysicsBodiesDemo scene]];
}

-(void)nextDemo{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    NSLog(@"................................................");
//    {//position test
//        SKNode* node = [self childNodeWithName:@"candy"];
//        NSLog(@"SET SPRITE %@ POSITION TO %f %f", [node name], location.x, location.y);
//        [node setPosition:location];
//    }
//    
//    {//rotation test
//        SKNode* node = [self childNodeWithName:@"statue"];
//        
//        float zRot = [node zRotation] -  0.785398163/*45deg*/;
//        
//        NSLog(@"SET SPRITE %@ ROTATION TO %f", [node name], zRot);
//        [node setZRotation:zRot];
//    }
    
    {//scale test
        SKNode* node = [self childNodeWithName:@"backpack"];
        
        float value = -0.1;
        if(location.x > self.size.width*0.5){
            value = 0.1;
        }
        
        float xScale = [node xScale] + value;
        float yScale = [node yScale] + value;
        
        
        NSLog(@"SET SPRITE %@ SCALE TO %f %f", [node name], xScale, yScale);
        [node setXScale:xScale];
        [node setYScale:yScale];
        
        [node setPosition:location];
        
        float zRot = [node zRotation] -  0.785398163/*45deg*/;
        
        [node setZRotation:zRot];
    }
    
    
    
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}


@end
