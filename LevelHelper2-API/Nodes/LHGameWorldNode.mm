//
//  LHGameWorldNode.mm
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHGameWorldNode.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

#import "SKNode+Transforms.h"


#if LH_USE_BOX2D

#include <cstdio>
#include <cstdarg>
#include <cstring>
#include "Box2D.h"

#else

#endif

#if LH_USE_BOX2D

class LHBox2dDebug;

@interface LHBox2dDebugDrawNode : SKNode
{
    LHBox2dDebug*   _debug;
    BOOL            _drawState;
}
-(LHBox2dDebug*)debug;
-(BOOL)drawState;
-(void)setDrawState:(BOOL)val;
@end



struct b2AABB;
class LHBox2dDebug : public b2Draw
{
private:
    float mRatio;
    LHBox2dDebugDrawNode* drawNode;
public:
    
    
	LHBox2dDebug( float ratio, LHBox2dDebugDrawNode* drawNode );
    virtual ~LHBox2dDebug(){};
    
    void setRatio(float ratio);
    
	void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
    
	void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
    
	void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);
    
	void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);
    
	void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);
    
	void DrawTransform(const b2Transform& xf);
    
    void DrawPoint(const b2Vec2& p, float32 size, const b2Color& color);
    
    void DrawString(int x, int y, const char* string, ...);
    
    void DrawAABB(b2AABB* aabb, const b2Color& color);
};

LHBox2dDebug::LHBox2dDebug( float ratio, LHBox2dDebugDrawNode* node )
: mRatio( ratio ){
    drawNode = node;
}
void LHBox2dDebug::setRatio(float ratio){
    mRatio = ratio;
}

void LHBox2dDebug::DrawPolygon(const b2Vec2* old_vertices, int32 vertexCount, const b2Color& color)
{
    CGMutablePathRef linePath = nil;
    
    for( int i=0;i<vertexCount;i++) {
		b2Vec2 tmp = old_vertices[i];
		tmp *= mRatio;

        CGPoint vPoint = CGPointMake(tmp.x, tmp.y);
        
        if(!linePath){
            linePath = CGPathCreateMutable();
            CGPathMoveToPoint(linePath, nil, vPoint.x, vPoint.y);
        }
        else{
            CGPathAddLineToPoint(linePath, nil, vPoint.x, vPoint.y);
        }

	}

    SKColor* fillColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:0.5];
    SKColor* borderColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:1];

    SKShapeNode* shape = [SKShapeNode node];
    [shape setFillColor:fillColor];
    [shape setLineWidth:0.1];
    [shape setStrokeColor:borderColor];
    
    if(linePath){
        CGPathCloseSubpath(linePath);
        shape.path = linePath;
        CGPathRelease(linePath);
    }
    
    [drawNode addChild:shape];
}

void LHBox2dDebug::DrawSolidPolygon(const b2Vec2* old_vertices, int32 vertexCount, const b2Color& color)
{
    CGMutablePathRef linePath = nil;
    
    for( int i=0;i<vertexCount;i++) {
		b2Vec2 tmp = old_vertices[i];
		tmp *= mRatio;
        CGPoint vPoint = CGPointMake(tmp.x, tmp.y);
        
        if(!linePath){
            linePath = CGPathCreateMutable();
            CGPathMoveToPoint(linePath, nil, vPoint.x, vPoint.y);
        }
        else{
            CGPathAddLineToPoint(linePath, nil, vPoint.x, vPoint.y);
        }

	}
    
    SKColor* fillColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:0.5];
    SKColor* borderColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:1];

    
    SKShapeNode* shape = [SKShapeNode node];
    [shape setFillColor:fillColor];
    [shape setLineWidth:0.1];
    [shape setStrokeColor:borderColor];
    
    if(linePath){
        CGPathCloseSubpath(linePath);
        shape.path = linePath;
        CGPathRelease(linePath);
    }
    
    [drawNode addChild:shape];
}

void LHBox2dDebug::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	
	
    CGMutablePathRef linePath = nil;
    for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
        
        CGPoint vPoint = CGPointMake(v.x*mRatio, v.y*mRatio);
        
        if(!linePath){
            linePath = CGPathCreateMutable();
            CGPathMoveToPoint(linePath, nil, vPoint.x, vPoint.y);
        }
        else{
            CGPathAddLineToPoint(linePath, nil, vPoint.x, vPoint.y);
        }

        
		theta += k_increment;
	}
	
    SKColor* fillColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:0.5];
    SKColor* borderColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:1];

    SKShapeNode* shape = [SKShapeNode node];
    [shape setFillColor:fillColor];
    [shape setLineWidth:0.1];
    [shape setStrokeColor:borderColor];
    
    if(linePath){
        CGPathCloseSubpath(linePath);
        shape.path = linePath;
        CGPathRelease(linePath);
    }
    
    [drawNode addChild:shape];
}

void LHBox2dDebug::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	
    CGMutablePathRef linePath = nil;
    
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
        CGPoint vPoint = CGPointMake(v.x*mRatio, v.y*mRatio);
        
        if(!linePath){
            linePath = CGPathCreateMutable();
            CGPathMoveToPoint(linePath, nil, vPoint.x, vPoint.y);
        }
        else{
            CGPathAddLineToPoint(linePath, nil, vPoint.x, vPoint.y);
        }

		theta += k_increment;
	}

    SKColor* fillColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:0.5];
    SKColor* borderColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:1];
    
    
    SKShapeNode* shape = [SKShapeNode node];
    [shape setFillColor:fillColor];
    [shape setLineWidth:0.1];
    [shape setStrokeColor:borderColor];
    
    if(linePath){
        CGPathCloseSubpath(linePath);
        shape.path = linePath;
        CGPathRelease(linePath);
    }

    [drawNode addChild:shape];
    
	// Draw the axis line
	DrawSegment(center,center+radius*axis,color);
}

void LHBox2dDebug::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	CGPoint pointA  = CGPointMake(p1.x *mRatio,p1.y*mRatio);
    CGPoint pointB  = CGPointMake(p2.x*mRatio,p2.y*mRatio);
    SKColor* borderColor = [SKColor colorWithRed:color.r green:color.g blue:color.b alpha:1];
    
    CGMutablePathRef linePath = CGPathCreateMutable();

    CGPathMoveToPoint(linePath, nil, pointA.x, pointA.y);
    CGPathAddLineToPoint(linePath, nil, pointB.x, pointB.y);
    
    SKShapeNode* shape = [SKShapeNode node];
    [shape setFillColor:borderColor];
    [shape setLineWidth:0.1];
    [shape setStrokeColor:borderColor];
    
    [drawNode addChild:shape];
}

void LHBox2dDebug::DrawTransform(const b2Transform& xf)
{
    //	b2Vec2 p1 = xf.p, p2;
    //	const float32 k_axisScale = 0.4f;
    //
    //	p2 = p1 + k_axisScale * xf.q.col1;
    //	DrawSegment(p1,p2,b2Color(1,0,0));
    //
    //	p2 = p1 + k_axisScale * xf.q.col2;
    //	DrawSegment(p1,p2,b2Color(0,1,0));
}

void LHBox2dDebug::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)
{
    //	glColor4f(color.r, color.g, color.b,1);
    //	glPointSize(size);
    //	GLfloat				glVertices[] = {
    //		p.x*mRatio,p.y*mRatio
    //	};
    //	glVertexPointer(2, GL_FLOAT, 0, glVertices);
    //	glDrawArrays(GL_POINTS, 0, 1);
    //	glPointSize(1.0f);
}

void LHBox2dDebug::DrawString(int x, int y, const char *string, ...)
{
    
	/* Unsupported as yet. Could replace with bitmap font renderer at a later date */
}

void LHBox2dDebug::DrawAABB(b2AABB* aabb, const b2Color& c)
{
    //	glColor4f(c.r, c.g, c.b,1);
    //
    //	GLfloat				glVertices[] = {
    //		aabb->lowerBound.x, aabb->lowerBound.y,
    //		aabb->upperBound.x, aabb->lowerBound.y,
    //		aabb->upperBound.x, aabb->upperBound.y,
    //		aabb->lowerBound.x, aabb->upperBound.y
    //	};
    //	glVertexPointer(2, GL_FLOAT, 0, glVertices);
    //	glDrawArrays(GL_LINE_LOOP, 0, 8);
	
}


@implementation LHBox2dDebugDrawNode

-(void)dealloc{
    LH_SAFE_DELETE(_debug);
    LH_SUPER_DEALLOC();
}
- (instancetype)init{
    if(self = [super init]){
        _debug = NULL;
        _drawState = YES;
    }
    return self;
}
-(void)clear{
    [self removeAllChildren];
}
-(LHBox2dDebug*)debug
{
    if(!_debug){
        _debug = new LHBox2dDebug(32, self);
    }
    return _debug;
}
-(void)draw
{
    [self clear];
    if(_drawState){
        [(LHGameWorldNode*)[self parent] box2dWorld]->DrawDebugData();
    }
}
-(BOOL)drawState{
    return _drawState;
}
-(void)setDrawState:(BOOL)val{
    _drawState = val;
}

@end


#endif

































@implementation LHGameWorldNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    
#if LH_USE_BOX2D
    NSTimeInterval  _lastTime;
    LHBox2dDebugDrawNode* __unsafe_unretained _debugNode;
    b2World*        _box2dWorld;
#endif

}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
#if LH_USE_BOX2D
    //we need to first destroy all children and then distroy box2d world
//    [self removeAllChildren];
    LH_SAFE_DELETE(_box2dWorld);
#endif

    
    LH_SUPER_DEALLOC();
}

+ (instancetype)gameWorldNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initGameWorldNodeWithDictionary:dict
                                                                  parent:prnt]);
}

- (instancetype)initGameWorldNodeWithDictionary:(NSDictionary*)dict
                                         parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
#if LH_USE_BOX2D
        _box2dWorld = NULL;
#endif

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        self.position = CGPointZero;
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];        
    }
    
    return self;
}


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - BOX2D SUPPORT
#if LH_USE_BOX2D

-(b2World*)box2dWorld
{
    if(!_box2dWorld){
        
        b2Vec2 gravity;
        gravity.Set(0.f, 0.0f);
        _box2dWorld = new b2World(gravity);
        _box2dWorld->SetAllowSleeping(true);
        _box2dWorld->SetContinuousPhysics(true);
        
        LHBox2dDebugDrawNode* drawNode = [LHBox2dDebugDrawNode node];
        [drawNode setZPosition:9999];
        
        _box2dWorld->SetDebugDraw([drawNode debug]);
        [drawNode debug]->setRatio([[self scene] ptm]);
        
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        flags += b2Draw::e_jointBit;
        //        //        flags += b2Draw::e_aabbBit;
        //        //        flags += b2Draw::e_pairBit;
        //        //        flags += b2Draw::e_centerOfMassBit;
        [drawNode debug]->SetFlags(flags);
        
        [self addChild:drawNode];
        _debugNode = drawNode;
        
        _debugNode.position = CGPointZero;
    }
    return _box2dWorld;
}

-(void)setDebugDraw:(BOOL)val{
    //something
    if(_debugNode){
        [_debugNode setDrawState:val];
    }
}
-(BOOL)debugDraw{
    return [_debugNode drawState];
}
-(CGPoint)gravity{
    b2Vec2 grv = [self box2dWorld]->GetGravity();
    return CGPointMake(grv.x, grv.y);
}

-(void)setGravity:(CGPoint)gravity{
    b2Vec2 grv;
    grv.Set(gravity.x, gravity.y);
    [self box2dWorld]->SetGravity(grv);
}




const float32 FIXED_TIMESTEP = 1.0f / 24.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;
const int32 VELOCITY_ITERATIONS = 16;
const int32 POSITION_ITERATIONS = 16;
const int32 MAXIMUM_NUMBER_OF_STEPS = 24;

-(void)step:(float)dt
{
    if(![self box2dWorld])return;
    
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP) {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		[self box2dWorld]->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep:dt]; // process collisions and result from callbacks called by the step
	}
	[self box2dWorld]->ClearForces ();
    
    [_debugNode draw];
}

-(void)afterStep:(float)dt {
    
}
#else //SPRITE KIT

-(void)setDebugDraw:(BOOL)val{
    
}
-(BOOL)debugDraw{
    return NO;
}

-(CGPoint)gravity{
    CGVector grv = [[[self scene] physicsWorld] gravity];
    return CGPointMake(grv.dx, grv.dy);
}
-(void)setGravity:(CGPoint)val{
    [[[self scene] physicsWorld] setGravity:CGVectorMake(val.x, val.y)];

}


#endif



- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
#if LH_USE_BOX2D
    [self step:dt];
#endif
    [_nodeProtocolImp update:currentTime delta:dt];
}

@end
