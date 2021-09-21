//
//  U4DVector2n.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/11/13.
//  Copyright (c) 2013 Untold Engine Studios. All rights reserved.
//

#include "U4DVector2n.h"
#include "U4DNumerical.h"
#include <cmath>

namespace U4DEngine {
    
    U4DVector2n::U4DVector2n(){}
    
    U4DVector2n::U4DVector2n(float uX,float uY):x(uX),y(uY){}
    
    U4DVector2n::~U4DVector2n(){}
    
    U4DVector2n::U4DVector2n(const U4DVector2n& a):x(a.x),y(a.y){}
    
    U4DVector2n& U4DVector2n::operator=(const U4DVector2n& a){
        x=a.x;
        y=a.y;
        return *this;
    }

    bool U4DVector2n::operator==(const U4DVector2n& a){
        
        U4DNumerical comparison;
        
        if (comparison.areEqual(x, a.x, U4DEngine::zeroEpsilon) && comparison.areEqual(y, a.y, U4DEngine::zeroEpsilon)) {
            return true;
        }else{
            return false;
        }
        
    }
    
    //add
    void U4DVector2n::operator+=(const U4DVector2n& v){
        
        x+=v.x;
        y+=v.y;
        
    }

    U4DVector2n U4DVector2n::operator+(const U4DVector2n& v)const{
        
        return U4DVector2n(x+v.x,y+v.y);
    }

    //substract
    void U4DVector2n::operator-=(const U4DVector2n& v){
        
        x-=v.x;
        y-=v.y;
    }

    U4DVector2n U4DVector2n::operator-(const U4DVector2n& v)const{
        return U4DVector2n(x-v.x,y-v.y);
    }

    //multiply a scalar
    void U4DVector2n::operator*=(const float s){
        
        x*=s;
        y*=s;
    }

    U4DVector2n U4DVector2n::operator*(const float s)const{
        
        return U4DVector2n(s*x,s*y);
    }

    //divide by scalar
    void U4DVector2n::operator /=(const float s){
        
        x=x/s;
        y=y/s;
    }

    U4DVector2n U4DVector2n::operator/(const float s)const{
        
        return U4DVector2n(x/s,y/s);
    }


    //dot product
    float U4DVector2n::operator*(const U4DVector2n& v) const{
        
        return x*v.x+y*v.y;
    }

    float U4DVector2n::dot(const U4DVector2n& v) const{
     
         return x*v.x+y*v.y;
    }



    //conjuage
    void U4DVector2n::conjugate(){
        
        x=-1*x;
        y=-1*y;
    }

    //normalize
    void U4DVector2n::normalize(){
        
        float mag=sqrt(x*x+y*y);
        
        if (mag>0.0f) {
            
            //normalize it
            float oneOverMag=1.0f/mag;
            
            x=x*oneOverMag;
            y=y*oneOverMag;
           
        }

    }

    //magnitude
    float U4DVector2n::magnitude(){
        
        float magnitude=sqrt(x*x+y*y);
        
        return magnitude;
    }

    float U4DVector2n::squareMagnitude(){
        
        float magnitude=x*x+y*y;
        
        return magnitude;
    }

    //clear
    void U4DVector2n::zero(){
        
        x=0;
        y=0;
    }

    void U4DVector2n::show(){
        
        std::cout<<"("<<x<<","<<y<<")"<<std::endl;
    }

}
