//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCollisionFilteringDemo.h"


@implementation LHSceneCollisionFilteringDemo
{
#if LH_USE_BOX2D
    b2MouseJoint* mouseJoint;

#else//spritekit
    SKNode* touchedNode;
    BOOL touchedNodeWasDynamic;
    
#endif
}


+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/collisionFilteringTest.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"Collision Filtering Demo\nPINK collides only with BLUE\nBLUE collides only with PINK and GREEN\nGREEN collides with BLUE AND GREEN\n\nClick and drag to move the robots."];

    }
    
    return self;
}

#if TARGET_OS_IPHONE

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    [self createMouseJointForTouchLocation:location];

    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}



-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    [self setTargetOnMouseJoint:location];
    
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self destroyMouseJoint];
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

    [self destroyMouseJoint];
    
    [super touchesCancelled:touches withEvent:event];
}
#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    
    [self createMouseJointForTouchLocation:location];
    
    [super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    
    [self setTargetOnMouseJoint:location];
    
    
    [super mouseDragged:theEvent];
}

-(void)mouseUp:(NSEvent *)theEvent{
    
    [self destroyMouseJoint];
    [super mouseUp:theEvent];
}

#endif



-(void)createMouseJointForTouchLocation:(CGPoint)point
{
#if LH_USE_BOX2D
    b2Body* ourBody = NULL;
    
    LHNode* mouseJointDummySpr = (LHNode*)[self childNodeWithName:@"dummyBodyForMouseJoint"];
    
    b2Body* mouseJointBody = [mouseJointDummySpr box2dBody];
    
    if(!mouseJointBody)return;
    
    b2Vec2 pointToTest = [self metersFromPoint:point];
    
    for (b2Body* b = [self box2dWorld]->GetBodyList(); b; b = b->GetNext())
    {
        if(b != mouseJointBody)
        {
            b2Fixture* stFix = b->GetFixtureList();
            while(stFix != 0){
                if(stFix->TestPoint(pointToTest)){
                    ourBody = b;
                    break;//exit for loop
                }
                stFix = stFix->GetNext();
            }
        }
    }
    
    if(ourBody == NULL)
        return;
    
    
    b2MouseJointDef md;
    md.bodyA = mouseJointBody;
    md.bodyB = ourBody;
    b2Vec2 locationWorld = pointToTest;
    
    md.target = locationWorld;
    md.collideConnected = true;
    md.maxForce = 1000.0f * ourBody->GetMass();
    ourBody->SetAwake(true);
    
    if(mouseJoint){
        [self box2dWorld]->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
    mouseJoint = (b2MouseJoint *)[self box2dWorld]->CreateJoint(&md);

#else
    
    NSArray* foundNodes = [self nodesAtPoint:point];
    for(SKNode* foundNode in foundNodes)
    {
        if(foundNode.physicsBody){
            touchedNode = foundNode;
            touchedNodeWasDynamic = touchedNode.physicsBody.affectedByGravity;
            [touchedNode.physicsBody setAffectedByGravity:NO];
            return;
        }
    }

    
#endif
}

-(void) setTargetOnMouseJoint:(CGPoint)point
{
#if LH_USE_BOX2D
    if(mouseJoint == 0)
        return;
    b2Vec2 locationWorld = b2Vec2([self metersFromPoint:point]);
    mouseJoint->SetTarget(locationWorld);

#else//spritekit
    
    if(touchedNode && touchedNode.physicsBody){
        [touchedNode setPosition:point];
    }

#endif
}

-(void)destroyMouseJoint{
    
#if LH_USE_BOX2D
    if(mouseJoint){
        [self box2dWorld]->DestroyJoint(mouseJoint);
    }
    mouseJoint = NULL;

#else//spritekit
    
    if(touchedNode){
        [touchedNode.physicsBody setAffectedByGravity:touchedNodeWasDynamic];
        touchedNode = nil;
    }

#endif
}


@end
