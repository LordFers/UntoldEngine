//
//  U4DSHAlgorithm.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 4/18/16.
//  Copyright © 2016 Untold Engine Studios. All rights reserved.
//

#include "U4DSHAlgorithm.h"
#include "U4DPlane.h"
#include "U4DSegment.h"
#include "U4DTriangle.h"
#include "Constants.h"
#include "U4DLogger.h"
#include "U4DNumerical.h"
#include "U4DModel.h"
#include <float.h>
#include <algorithm>

namespace U4DEngine {

    U4DSHAlgorithm::U4DSHAlgorithm(){
        
    }
    
    U4DSHAlgorithm::~U4DSHAlgorithm(){
        
    }
    
    void U4DSHAlgorithm::determineCollisionManifold(U4DDynamicAction* uAction1, U4DDynamicAction* uAction2,std::vector<SIMPLEXDATA> uQ, COLLISIONMANIFOLDONODE &uCollisionManifoldNode){
    
        
        POINTINFORMATION pointInformation;
        
        U4DVector3n negateContactNormal=uCollisionManifoldNode.normalCollisionVector*-1.0;
        
        U4DPlane collisionPlane(uCollisionManifoldNode.normalCollisionVector,uCollisionManifoldNode.collisionClosestPoint);
        
        //test if the model is within the plane and set the normal accordingly
        pointInformation.point=uAction1->model->getAbsolutePosition().toPoint();
        
        float direction=collisionPlane.magnitudeSquareOfPointToPlane(pointInformation.point);

        
        if (direction>U4DEngine::planeBoundaryEpsilon) {
            
            pointInformation.location=insidePlane;
            
        }else{
            
            if (direction<-U4DEngine::planeBoundaryEpsilon) {
                
                pointInformation.location=outsidePlane;
                
                
            }else{
                
                pointInformation.location=boundaryPlane;
                
            }
            
        }
        
       
        if (pointInformation.location==outsidePlane ) {
            
            uAction1->setCollisionNormalFaceDirection(uCollisionManifoldNode.normalCollisionVector);
            
            uAction2->setCollisionNormalFaceDirection(negateContactNormal);
            
            
        }else if(pointInformation.location==insidePlane || pointInformation.location==boundaryPlane){
            
            uAction2->setCollisionNormalFaceDirection(uCollisionManifoldNode.normalCollisionVector);
            
            uAction1->setCollisionNormalFaceDirection(negateContactNormal);
            
            uCollisionManifoldNode.normalCollisionVector=negateContactNormal;
            
        }
        
    }
    
    bool U4DSHAlgorithm::determineContactManifold(U4DDynamicAction* uAction1, U4DDynamicAction* uAction2,std::vector<SIMPLEXDATA> uQ,COLLISIONMANIFOLDONODE &uCollisionManifoldNode){
        
        U4DLogger *logger=U4DLogger::sharedInstance();
        
        //step 1. Create plane
        U4DVector3n collisionNormalOfModel1=uAction1->getCollisionNormalFaceDirection();
        U4DPlane planeCollisionOfModel1(collisionNormalOfModel1,uCollisionManifoldNode.collisionClosestPoint);
        
        U4DVector3n collisionNormalOfModel2=uAction2->getCollisionNormalFaceDirection();
        U4DPlane planeCollisionOfModel2(collisionNormalOfModel2,uCollisionManifoldNode.collisionClosestPoint);
        
        if (collisionNormalOfModel1==U4DVector3n(0,0,0) || collisionNormalOfModel2==U4DVector3n(0,0,0)) {
            
            logger->log("Sutherland-Hodgman algorithm failed: Collision Normals equal to (0.0,0.0,0.0).");
            
            return false;
        }
        
        //step 2. For each model determine which face is most parallel to plane, i.e., dot product ~0
        
        std::vector<CONTACTFACES> parallelFacesModel1=mostParallelFacesToPlane(uAction1, planeCollisionOfModel1);
        
        std::vector<CONTACTFACES> parallelFacesModel2=mostParallelFacesToPlane(uAction2, planeCollisionOfModel2);
        
        if (parallelFacesModel1.size()==0 || parallelFacesModel2.size()==0) {
            
            logger->log("Sutherland-Hodgman algorithm failed: Couldn't find most parallel plane to face.");
            
            return false;
        }
        
        //step 3. for each model project selected faces onto plane
        
        std::vector<U4DTriangle> projectedFacesModel1=projectFacesToPlane(parallelFacesModel1, planeCollisionOfModel1);
        
        std::vector<U4DTriangle> projectedFacesModel2=projectFacesToPlane(parallelFacesModel2, planeCollisionOfModel2);
        
        if (projectedFacesModel1.size()==0 || projectedFacesModel2.size()==0) {
            
            logger->log("Sutherland-Hodgman algorithm failed: Couldn't project select faces to plane");
            
            return false;
        }
        //step 4. Break triangle into segments and remove any duplicate segments
        std::vector<CONTACTEDGE> polygonEdgesOfModel1=getEdgesFromFaces(projectedFacesModel1,planeCollisionOfModel1);
        std::vector<CONTACTEDGE> polygonEdgesOfModel2=getEdgesFromFaces(projectedFacesModel2,planeCollisionOfModel2);
        
        if (polygonEdgesOfModel1.size()==0 || polygonEdgesOfModel2.size()==0) {
            
            logger->log("Sutherland-Hodgman algorithm failed: Couldn't obtain edges from the collided faces");
            
            return false;
        }
        //step 5. Determine reference polygon

        float maxFaceParallelToPlaneInModel1=-FLT_MIN;
        float maxFaceParallelToPlaneInModel2=-FLT_MIN;
        
        //Get the most dot product parallel to plane for each model
        for(auto n:parallelFacesModel1){
            
            maxFaceParallelToPlaneInModel1=std::max(n.dotProduct,maxFaceParallelToPlaneInModel1);
            
        }
        
        for(auto n:parallelFacesModel2){
            
            maxFaceParallelToPlaneInModel2=std::max(n.dotProduct,maxFaceParallelToPlaneInModel2);
            
        }
        
        //compare dot product and assign a reference plane
        
        std::vector<U4DSegment> segments;
        U4DTriangle incidentFace;
        U4DTriangle referenceFace;
        std::vector<CONTACTEDGE> referencePlane;
        std::vector<CONTACTEDGE> incidentPlane;
        std::vector<CONTACTFACES> referenceModelFace;
        std::vector<CONTACTFACES> incidentModelFace;
        
        if (maxFaceParallelToPlaneInModel1>=maxFaceParallelToPlaneInModel2) {
            
            //set polygon in model 1 as the reference plane
            //and polygon in model 2 as the incident plane
            
            referencePlane=polygonEdgesOfModel1;
            incidentPlane=polygonEdgesOfModel2;
            
            referenceModelFace=parallelFacesModel1;
            incidentModelFace=parallelFacesModel2;
            
        }else{
            
            //set polygon in model 2 as the reference plane
            //and polygon in model 1 as the incident plane
            
            referencePlane=polygonEdgesOfModel2;
            incidentPlane=polygonEdgesOfModel1;
            
            referenceModelFace=parallelFacesModel2;
            incidentModelFace=parallelFacesModel1;
            
        }
        
        //step 5. perform sutherland
        
        segments=clipPolygons(referencePlane, incidentPlane);
        
        incidentFace=incidentModelFace.at(0).triangle;
        referenceFace=referenceModelFace.at(0).triangle;
        
        //step 6. Return best contact manifold
        
        //Create an incident and reference plane from the faces
        U4DPlane incidentFacePlane(incidentFace.pointA,incidentFace.pointB,incidentFace.pointC);
        U4DPlane referenceFacePlane(referenceFace.pointA,referenceFace.pointB,referenceFace.pointC);
        
        //if container is empty, then return
        if (segments.size()<=1) {
            
            logger->log("Sutherland-Hodgman algorithm failed: Couldn't produce valid segments");
            return false;
        }
        
        U4DNumerical numerical;
        
        //set a cutoff distance. Points greater than this distance are ignored as contact points
        float cutOffDistance=0.0;
        
        for(auto n:segments){
            cutOffDistance+=fabs(incidentFacePlane.magnitudeOfPointToPlane(n.pointA));
        }
        
        cutOffDistance/=segments.size();
        
        //compute the angle between planes
        
        U4DPoint3n intersectionPoint;
        U4DVector3n intersectionVector;
        
        if (referenceFacePlane.intersectPlane(incidentFacePlane, intersectionPoint, intersectionVector)) {
            
            uCollisionManifoldNode.referenceAndIncidentPlaneAngle=referenceFacePlane.angle(incidentFacePlane);
            
        }
        
        //number of points selected as contact points
        int numberOfPoints=0;
        
        for(auto n:segments){
            
            float magnitudeOfPoint=fabs(incidentFacePlane.magnitudeOfPointToPlane(n.pointA));
            
            if ((magnitudeOfPoint<cutOffDistance) || numerical.areEqual(magnitudeOfPoint, cutOffDistance, U4DEngine::minimumManifoldCutoffDistance)) {
                
                U4DVector3n point=n.pointA.toVector();
                
                uAction1->addCollisionContactPoint(point);
                
                uAction2->addCollisionContactPoint(point);
                
                //add point to collision node
                uCollisionManifoldNode.contactPoints.push_back(point);
                
                numberOfPoints++;
            }
            
        }
        
        //if contact points are less than two, then the models are not in equilibrium
        if (numberOfPoints<U4DEngine::minimumContactPointsForEquilibrium) {
            uAction1->setEquilibrium(false);
            uAction2->setEquilibrium(false);
        }else{
            uAction1->setEquilibrium(true);
            uAction2->setEquilibrium(true);
        }
        
        //check if the center of mass is within the reference planes
        
//        if(!isCenterOfMassWithinReferencePlane(uAction1,polygonEdgesOfModel2)){
//
//            uAction1->setEquilibrium(false);
//
//        }else{
//
//            uAction1->setEquilibrium(true);
//
//        }
//
//        if(!isCenterOfMassWithinReferencePlane(uAction2,polygonEdgesOfModel1)){
//
//            uAction2->setEquilibrium(false);
//
//        }else{
//
//            uAction2->setEquilibrium(true);
//
//        }
        
        
        return true;
        
    }
    
    std::vector<CONTACTFACES> U4DSHAlgorithm::mostParallelFacesToPlane(U4DDynamicAction* uAction, U4DPlane& uPlane){
        
        std::vector<CONTACTFACES> modelFaces; //faces of each polygon in the model
        
        float parallelToPlane=-FLT_MIN;
        float support=0.0;
        
        U4DVector3n planeNormal=uPlane.n;
        
        //Normalize the plane so the dot product between the face normal and the plane falls within [-1,1]
        planeNormal.normalize();
        
        for(auto n: uAction->model->bodyCoordinates.getConvexHullFacesDataFromContainer()){
            
            //update all faces with current model position
            
            U4DVector3n vertexA=n.pointA.toVector();
            U4DVector3n vertexB=n.pointB.toVector();
            U4DVector3n vertexC=n.pointC.toVector();
            
            vertexA=uAction->model->getAbsoluteMatrixOrientation()*vertexA;
            vertexA=vertexA+uAction->model->getAbsolutePosition();
            
            vertexB=uAction->model->getAbsoluteMatrixOrientation()*vertexB;
            vertexB=vertexB+uAction->model->getAbsolutePosition();
            
            vertexC=uAction->model->getAbsoluteMatrixOrientation()*vertexC;
            vertexC=vertexC+uAction->model->getAbsolutePosition();
            
            n.pointA=vertexA.toPoint();
            n.pointB=vertexB.toPoint();
            n.pointC=vertexC.toPoint();
            
            //structure to store all faces
            CONTACTFACES modelFace;
            
            //store triangle
            modelFace.triangle=n;
            
            //get the normal for the face & normalize
            U4DVector3n faceNormal=n.getTriangleNormal();
            
            //Normalize the face normal vector so the dot product between the face normal and the plane falls within [-1,1]
            faceNormal.normalize();
        
            //get the minimal dot product
            support=faceNormal.dot(planeNormal);
            
            modelFace.dotProduct=support;
            
            modelFaces.push_back(modelFace);
            
            //parallelToPlane keeps track of the most parallel dot product between the triangle normal vector and the plane normal
            
            if(support>parallelToPlane){
                
                parallelToPlane=support;
                
            }
            
        }

        //remove all faces with dot product not equal to most parallel face to plane
        modelFaces.erase(std::remove_if(modelFaces.begin(), modelFaces.end(),[parallelToPlane](CONTACTFACES &e){ return !(fabs(e.dotProduct - parallelToPlane) <= U4DEngine::zeroEpsilon * std::max(1.0f, std::max(e.dotProduct, parallelToPlane)));} ),modelFaces.end());
        
        
        return modelFaces;
        
    }
    
    std::vector<U4DTriangle> U4DSHAlgorithm::projectFacesToPlane(std::vector<CONTACTFACES>& uFaces, U4DPlane& uPlane){
        
        std::vector<U4DTriangle> projectedTriangles;
        
        for(auto n:uFaces){
           
            U4DTriangle triangle=n.triangle.projectTriangleOntoPlane(uPlane);
            
            projectedTriangles.push_back(triangle);
        }
        
        return projectedTriangles;
    }
    
    std::vector<CONTACTEDGE> U4DSHAlgorithm::getEdgesFromFaces(std::vector<U4DTriangle>& uFaces, U4DPlane& uPlane){
        
        std::vector<CONTACTEDGE> modelEdges;
    
        //For each face, get its corresponding edges
        
        for(auto n:uFaces){
            
            std::vector<U4DSegment> segment=n.getSegments();
            
            CONTACTEDGE modelEdgeAB;
            CONTACTEDGE modelEdgeBC;
            CONTACTEDGE modelEdgeCA;
            
            modelEdgeAB.segment=segment.at(0);
            modelEdgeBC.segment=segment.at(1);
            modelEdgeCA.segment=segment.at(2);
            
            modelEdgeAB.isDuplicate=false;
            modelEdgeBC.isDuplicate=false;
            modelEdgeCA.isDuplicate=false;
            
            std::vector<CONTACTEDGE> tempEdges{modelEdgeAB,modelEdgeBC,modelEdgeCA};
            
            if (modelEdges.size()==0) {
                
                modelEdges=tempEdges;
                
            }else{
             
                for(auto& edge:modelEdges){
                    
                    for(auto& tempEdge:tempEdges){
                        
                        //check if there are duplicate edges
                        if (edge.segment==tempEdge.segment || edge.segment==tempEdge.segment.negate()) {
                            
                            edge.isDuplicate=true;
                            tempEdge.isDuplicate=true;
                            
                        }
                        
                    }
                }
                
                modelEdges.push_back(tempEdges.at(0));
                modelEdges.push_back(tempEdges.at(1));
                modelEdges.push_back(tempEdges.at(2));
                
            }
            
        }
        
        //remove all duplicate faces
        modelEdges.erase(std::remove_if(modelEdges.begin(), modelEdges.end(),[](CONTACTEDGE &e){ return e.isDuplicate;} ),modelEdges.end());
        
        //Since the triangle was broken up, it also broke the CCW direction of all segments.
        //We need to connect the segments in a CCW direction
        std::vector<CONTACTEDGE> tempModelEdges;
        
        //use the first value in the container as the pivot segment
        int pivotIndex=0;
        
        tempModelEdges.push_back(modelEdges.at(pivotIndex));
        
        for (int pivot=0; pivot<modelEdges.size(); pivot++) {
            
            U4DSegment pivotSegment=modelEdges.at(pivotIndex).segment;
            
            for (int rotating=1; rotating<modelEdges.size(); rotating++) {
                
                //if I'm not testing the same segment and if the point B of the pivot segment is equal to the rotating pointB segment
                if ((pivotSegment.pointB==modelEdges.at(rotating).segment.pointA) &&(modelEdges.at(pivot).segment != modelEdges.at(rotating).segment)) {
                    
                    tempModelEdges.push_back(modelEdges.at(rotating));
                    pivotIndex=rotating;
                    
                    break;
                }
            }
            
        }
        
        modelEdges.clear();
        //copy the sorted CCW segments
        modelEdges=tempModelEdges;
        
        //calculate the normal of the line by doing a cross product between the plane normal and the segment direction
        for(auto& n:modelEdges){
            
            std::vector<U4DPoint3n> points=n.segment.getPoints();
            
            //get points
            U4DPoint3n pointA=points.at(0);
            U4DPoint3n pointB=points.at(1);
            
            //compute line
            U4DVector3n line=pointA-pointB;
            
            //get normal
            U4DVector3n normal=uPlane.n.cross(line);
            
            //assign normal to model edge
            n.normal=normal;
            
        }
        
        return modelEdges;
        
    }
    

    std::vector<U4DSegment> U4DSHAlgorithm::clipPolygons(std::vector<CONTACTEDGE>& uReferencePolygons, std::vector<CONTACTEDGE>& uIncidentPolygons){
        
        std::vector<U4DSegment> clipEdges;
        std::vector<U4DPoint3n> clippedPoints;
        
        //copy the incident edges into the the clip edges
        for(auto n:uIncidentPolygons){
            
            clipEdges.push_back(n.segment);
            
        }
    
        
        for(auto referencePolygon:uReferencePolygons){
            
            U4DVector3n normal=referencePolygon.normal;
            U4DPoint3n pointOnPlane=referencePolygon.segment.pointA;
            
            //create plane
            U4DPlane referencePlane(normal,pointOnPlane);
            
            //For every segment determine the location of each point and the direction of the segment
            for(auto incidentEdges:clipEdges){
                
                //get the points in the segment
                std::vector<U4DPoint3n> incidentPoints=incidentEdges.getPoints();
                std::vector<POINTINFORMATION> pointsInformation;
                
                //determine the location of each point segment with respect to the plane normal
                for(int i=0; i<incidentPoints.size(); i++){
                    
                    float direction=referencePlane.magnitudeSquareOfPointToPlane(incidentPoints.at(i));
                    
                    POINTINFORMATION pointInformation;
                    
                    pointInformation.point=incidentPoints.at(i);
                    
                    if (direction>U4DEngine::zeroEpsilon) {
                        
                        pointInformation.location=insidePlane;
                    
                    }else{
                       
                        if (direction < -U4DEngine::zeroEpsilon) {
                            
                            pointInformation.location=outsidePlane;
                        
                        }else{
                           
                            pointInformation.location=boundaryPlane;
                        
                        }
                        
                    }
                    
                    //store the points information
                    pointsInformation.push_back(pointInformation);
                
                }//end for
                    
                //determine the direction of the segment
                CONTACTEDGEINFORMATION edgeInformation;
                edgeInformation.contactSegment=incidentEdges;
                
                //segment going from INSIDE of plane to OUTSIDE of plane
                if (pointsInformation.at(0).location==insidePlane && pointsInformation.at(1).location==outsidePlane) {
                    
                    edgeInformation.direction=inToOut;
                    
                //segment going from OUTSIDE of plane to INSIDE of plane
                }else if (pointsInformation.at(0).location==outsidePlane && pointsInformation.at(1).location==insidePlane){
                    
                    edgeInformation.direction=outToIn;
                    
                //segment going from INSIDE of plane to INSIDE of plane
                }else if (pointsInformation.at(0).location==insidePlane && pointsInformation.at(1).location==insidePlane){
                
                    edgeInformation.direction=inToIn;
                    
                //segment going from OUTSIDE of plane to OUTSIDE of plane
                }else if (pointsInformation.at(0).location==outsidePlane && pointsInformation.at(1).location==outsidePlane){
                    
                    edgeInformation.direction=outToOut;
                    
                //segment is in boundary
                }else{
                    
                    edgeInformation.direction=inBoundary;
                    
                }
                
                
                //clip the segment
                
                
                if (edgeInformation.direction==inToOut) {
                    //Add intersection point
                    U4DPoint3n intersectPoint;
                    
                    referencePlane.intersectSegment(incidentEdges, intersectPoint);
                    
                    clippedPoints.push_back(intersectPoint);
                    
                }else if (edgeInformation.direction==outToIn){
                    //Add intersection point and pointB
                    
                    U4DPoint3n intersectPoint;
                    
                    referencePlane.intersectSegment(incidentEdges, intersectPoint);
                    
                    
                    clippedPoints.push_back(intersectPoint);
                    clippedPoints.push_back(incidentEdges.pointB);
                    
                }else if (edgeInformation.direction==inToIn){
                    //Add pointB
                    
                    clippedPoints.push_back(incidentEdges.pointB);
                    
                }else if (edgeInformation.direction==outToOut){
                    //Add none
                    
                }else{
                    //edge is a boundary
                    //Add PointB
                    
                    clippedPoints.push_back(incidentEdges.pointB);
                    
                }
                
            }//end for-Segment
            
            //for each point in clippedPoints, connect them as segments and initialize them as clipped edges
            
            if (clippedPoints.size()>1) {
                
                clipEdges.clear();
                
                for(int i=0;i<clippedPoints.size()-1;){
                    
                    U4DSegment newSegment(clippedPoints.at(i),clippedPoints.at(i+1));
                    clipEdges.push_back(newSegment);
                    i=i+1;
                    
                }
                
                //close the polygon loop
                U4DSegment closeSegment(clippedPoints.at(clippedPoints.size()-1),clippedPoints.at(0));
                
                clipEdges.push_back(closeSegment);
                
            }
            
            clippedPoints.clear();
            
        }//end for
        
        return clipEdges;
    }
    
    
    bool U4DSHAlgorithm::isCenterOfMassWithinReferencePlane(U4DDynamicAction* uAction,std::vector<CONTACTEDGE>& uReferencePolygons){
        
        U4DPoint3n centerOfMass=(uAction->getCenterOfMass()+uAction->model->getAbsolutePosition()).toPoint();
        
        for(auto referencePolygon:uReferencePolygons){
            
            U4DVector3n normal=referencePolygon.normal;
            U4DPoint3n pointOnPlane=referencePolygon.segment.pointA;
            
            //create plane
            U4DPlane referencePlane(normal,pointOnPlane);
            
            float direction=referencePlane.magnitudeSquareOfPointToPlane(centerOfMass);
            
            if (direction>U4DEngine::zeroEpsilon) {
                
                //Center of mass is inside the plane
                
            }else{
                
                if (direction <-U4DEngine::zeroEpsilon) {
                    
                   //Center of mass is outside the plane
                    
                    return false;
                    
                }else{
                    
                    //Center of mass is on the boundary of the plane edge
                    
                }
                
            }
            
        }
        
        return true;
    }
    
}


