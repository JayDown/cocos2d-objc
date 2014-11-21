/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "ccTypes.h"

#import "CCNodeColor.h"
#import "CCDirector.h"
#import "CCColor.h"
#import "CCRendererBasicTypes.h"

#pragma mark -
#pragma mark Layer

#if __CC_PLATFORM_IOS

#endif // __CC_PLATFORM_IOS

#pragma mark -
#pragma mark LayerColor

@implementation CCNodeColor {
	@protected
	GLKVector4	_colors[4];
}

+ (id) nodeWithColor:(CCColor*)color width:(float)w  height:(float) h
{
	return [[self alloc] initWithColor:color width:w height:h];
}

+ (id) nodeWithColor:(CCColor*)color
{
	return [(CCNodeColor*)[self alloc] initWithColor:color];
}

-(id) init
{
	CGSize s = [CCDirector sharedDirector].designSize;
	return [self initWithColor:[CCColor clearColor] width:s.width height:s.height];
}

// Designated initializer
- (id) initWithColor:(CCColor*)color width:(float)w  height:(float) h
{
	if( (self=[super init]) ) {
		self.blendMode = [CCBlendMode premultipliedAlphaMode];

		self.colorRGBA = color;
		[self updateColor];
		[self setContentSize:CGSizeMake(w, h) ];

		self.shader = [CCShader positionColorShader];
	}
	return self;
}

- (id) initWithColor:(CCColor*)color
{
	CGSize s = [CCDirector sharedDirector].designSize;
	return [self initWithColor:color width:s.width height:s.height];
}

- (void) updateColor
{
	GLKVector4 color = GLKVector4Make(_displayColor.r*_displayColor.a, _displayColor.g*_displayColor.a, _displayColor.b*_displayColor.a, _displayColor.a);
	for(int i=0; i<4; i++) _colors[i] = color;
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    CGSize size = self.contentSizeInPoints;
    GLKVector2 hs = GLKVector2Make(size.width*0.5f, size.height*0.5f);
    if(!CCRenderCheckVisbility(transform, hs, hs)) return;
    
    GLKVector2 zero = GLKVector2Make(0, 0);
    
    CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:0];
    
    float w = size.width, h = size.height;
    CCRenderBufferSetVertex(buffer, 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(0, 0, 0, 1)), zero, zero, _colors[0]});
    CCRenderBufferSetVertex(buffer, 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(w, 0, 0, 1)), zero, zero, _colors[1]});
    CCRenderBufferSetVertex(buffer, 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(w, h, 0, 1)), zero, zero, _colors[2]});
    CCRenderBufferSetVertex(buffer, 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(0, h, 0, 1)), zero, zero, _colors[3]});
    
    CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

#pragma mark Protocols
// Color Protocol

-(void) setColor:(CCColor *)color
{
	[super setColor:color];
	[self updateColor];
}

-(void) setOpacity: (CGFloat) opacity
{
	[super setOpacity:opacity];
	[self updateColor];
}

- (void)updateDisplayedOpacity:(CGFloat)parentOpacity
{
    [super updateDisplayedOpacity:parentOpacity];
    [self updateColor];
}

@end


#pragma mark -
#pragma mark LayerGradient

@implementation CCNodeGradient

@synthesize vector = _vector;

+ (id) nodeWithColor: (CCColor*) start fadingTo: (CCColor*) end
{
    return [[self alloc] initWithColor:start fadingTo:end];
}

+ (id) nodeWithColor: (CCColor*) start fadingTo: (CCColor*) end alongVector: (CGPoint) v
{
    return [[self alloc] initWithColor:start fadingTo:end alongVector:v];
}

- (id) init
{
	return [self initWithColor:[CCColor blackColor] fadingTo:[CCColor blackColor]];
}

- (id) initWithColor: (CCColor*) start fadingTo: (CCColor*) end
{
    return [self initWithColor:start fadingTo:end alongVector:ccp(0, -1)];
}

- (id) initWithColor: (CCColor*) start fadingTo: (CCColor*) end alongVector: (CGPoint) v
{
	_color = start.glkVector4;
	_endColor = end.glkVector4;
	_vector = v;

	return [super initWithColor:start];
}

- (void) updateColor
{
	[super updateColor];
	
	// _vector apparently points towards the first color.
	float g0 = 0.0f; // (0, 0) dot _vector
	float g1 = -_vector.x; // (0, 1) dot _vector
	float g2 = -_vector.x - _vector.y; // (1, 1) dot _vector
	float g3 = -_vector.y; // (1, 0) dot _vector
	
	float gmin = MIN(MIN(g0, g1), MIN(g2, g3));
	float gmax = MAX(MAX(g0, g1), MAX(g2, g3));
	GLKVector4 a = GLKVector4Make(_color.r*_color.a*_displayColor.a, _color.g*_color.a*_displayColor.a, _color.b*_color.a*_displayColor.a, _color.a*_displayColor.a);
	GLKVector4 b = GLKVector4Make(_endColor.r*_endColor.a*_displayColor.a, _endColor.g*_endColor.a*_displayColor.a, _endColor.b*_endColor.a*_displayColor.a, _endColor.a*_displayColor.a);
	_colors[0] =  GLKVector4Lerp(a, b, (g0 - gmin)/(gmax - gmin));
	_colors[1] =  GLKVector4Lerp(a, b, (g1 - gmin)/(gmax - gmin));
	_colors[2] =  GLKVector4Lerp(a, b, (g2 - gmin)/(gmax - gmin));
	_colors[3] =  GLKVector4Lerp(a, b, (g3 - gmin)/(gmax - gmin));
}

-(CCColor*) startColor
{
	return [CCColor colorWithGLKVector4: _color];
}

-(void) setStartColor:(CCColor*)color
{
	[self setColor:color];
}

- (CCColor*) endColor
{
	return [CCColor colorWithGLKVector4:_endColor];
}

-(void) setEndColor:(CCColor*)color
{
	_endColor = color.glkVector4;
	[self updateColor];
}

- (CGFloat) startOpacity
{
	return _color.a;
}

-(void) setStartOpacity: (CGFloat) o
{
	_color.a = o;
	[self updateColor];
}

- (CGFloat) endOpacity
{
	return _endColor.a;
}

-(void) setEndOpacity: (CGFloat) o
{
	_endColor.a = o;
	[self updateColor];
}

-(void) setVector: (CGPoint) v
{
	_vector = v;
	[self updateColor];
}

@end
