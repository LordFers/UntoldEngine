//
//  U4DVector4n.mm
//  UntoldEngine
//
//  Created by Harold Serrano on 5/22/14.
//  Copyright (c) 2014 Untold Engine Studios. All rights reserved.
//

#include "U4DVector4n.h"
#include "U4DLogger.h"

namespace U4DEngine {
    

    U4DVector4n::U4DVector4n(){
    
        x=0.0;
        y=0.0;
        z=0.0;
        w=0.0;
        
    }
    
    U4DVector4n::U4DVector4n(float nx,float ny,float nz,float nw):x(nx),y(ny),z(nz),w(nw){}
    
    U4DVector4n::~U4DVector4n(){}
    
    U4DVector4n::U4DVector4n(const U4DVector4n& a):x(a.x),y(a.y),z(a.z),w(a.w){}
    
    U4DVector4n& U4DVector4n::operator=(const U4DVector4n& a){
        
        x=a.x;
        y=a.y;
        z=a.z;
        w=a.w;
        
        return *this;
        
    }
    
    void U4DVector4n::operator+=(const U4DVector4n& v){
        
        x+=v.x;
        y+=v.y;
        z+=v.z;
        w+=v.w;
        
    }
    
    U4DVector4n U4DVector4n::operator+(const U4DVector4n& v)const{
        
        
        return U4DVector4n(x+v.x,y+v.y,z+v.z,w+v.w);
    }
    
    void U4DVector4n::operator*=(const float s){
        
        x*=s;
        y*=s;
        z*=s;
        w*=s;
        
    }
    
    U4DVector4n U4DVector4n::operator*(const float s) const{
        
        return U4DVector4n(s*x,s*y,s*z,s*w);
    }
    
    float U4DVector4n::dot(const U4DVector4n& v) const{
        
        return x*v.x+y*v.y+z*v.z+w*v.w;
        
    }

    float U4DVector4n::getX(){
        
        return x;
    }

    float U4DVector4n::getY(){
        
        return y;
    }

    float U4DVector4n::getZ(){

        return z;
    }

    float U4DVector4n::getW(){
        
        return w;
    }
    
    
    void U4DVector4n::show(){
        
        U4DLogger *logger=U4DLogger::sharedInstance();
        logger->log("%f,%f,%f,%f",x,y,z,w);
        //std::cout<<"("<<x<<","<<y<<","<<z<<","<<w<<")"<<std::endl;
    }

}
