% I found a bug! Not all intersections are correctly detected. It seems to occur when shooting a ray orthogonal to the edge of a triangle. It depends on the winding of the triangles and/or side of the ray.
% 
% I cannot tell if the bug is already in the original opcode or in the Matlab bridge.
% 
% Example code: 
% f = [2 4 1 ; 2 3 4]'; 
% v = [-1 -1 0 ; -1 1 0 ; 1 1 0 ; 1 -1 0]'; 
% t = opcodemesh(v,f); 
% p1 = [0.0 0.0 -1]'; 
% p2 = [0.0 0.0 1]'; 
% [hit1,d1] = t.intersect(p1,(p2-p1)./norm(p2-p1)); % ok 
% [hit2,d2] = t.intersect(p2,(p1-p2)./norm(p1-p2)); % NOK
% 
% % Visualization: 
% trimesh(f',v(1,:),v(2,:),v(3,:)); 
% hold on; 
% xlabel('x'); 
% ylabel('y'); 
% zlabel('z'); 
% axis equal; 
% xlim([-2 2]); 
% ylim([-2 2]); 
% zlim([-2 2]); 
% plot3([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], '-ro'); 
% hold off; 
% --------------------------------------------------------------------------------------------------------------------------------
% @Stefan Spelitz, @Vipin Vijayan. I think i found a solution for the bug. Although it might have created other bugs :D
% 
% use the following code in OPC_RayTriOverlap.h 
% https://pastebin.com/VeFhns4W
% 
% using the Example code of Stefan Spelitz the following results are calculated: 
% hit1 = true 
% hit2 = true
% 
% cheers.

if(mCulling)
    {
        if(det<LOCAL_EPSILON)                                                       return FALSE;
        // From here, det is > 0. So we can use integer cmp.
 
        // Calculate distance from vert0 to ray origin
        Point tvec = mOrigin - vert0;
 
        // Calculate U parameter and test bounds
        mStabbedFace.mU = tvec|pvec;
//      if(IR(u)&0x80000000 || u>det)                   return FALSE;
//      if(IS_NEGATIVE_FLOAT(mStabbedFace.mU) || IR(mStabbedFace.mU)>IR(det))       return FALSE;
        if(mStabbedFace.mU < 0.0f || mStabbedFace.mU > det)                         return FALSE;
 
        // Prepare to test V parameter
        Point qvec = tvec^edge1;
 
        // Calculate V parameter and test bounds
        mStabbedFace.mV = mDir|qvec;
//      if(IS_NEGATIVE_FLOAT(mStabbedFace.mV) || mStabbedFace.mU+mStabbedFace.mV>det)   return FALSE;
        if(mStabbedFace.mV < 0.0f || (mStabbedFace.mU+mStabbedFace.mV) > det)       return FALSE;
       
        // Calculate t, scale parameters, ray intersects triangle
        mStabbedFace.mDistance = edge2|qvec;
        // Det > 0 so we can early exit here
        // Intersection point is valid if distance is positive (else it can just be a face behind the orig point)
//      if(IS_NEGATIVE_FLOAT(mStabbedFace.mDistance))                               return FALSE;
        if(mStabbedFace.mDistance < 0.0f)                                           return FALSE;
        // Else go on
        float OneOverDet = 1.0f / det;
        mStabbedFace.mDistance *= OneOverDet;
        mStabbedFace.mU *= OneOverDet;
        mStabbedFace.mV *= OneOverDet;
    }
    else
    {
        // the non-culling branch
        if(det>-LOCAL_EPSILON && det<LOCAL_EPSILON)                                 return FALSE;
        float OneOverDet = 1.0f / det;
 
        // Calculate distance from vert0 to ray origin
        Point tvec = mOrigin - vert0;
 
        // Calculate U parameter and test bounds
        mStabbedFace.mU = (tvec|pvec) * OneOverDet;
//      if(IR(u)&0x80000000 || u>1.0f)                  return FALSE;
//      if(IS_NEGATIVE_FLOAT(mStabbedFace.mU) || IR(mStabbedFace.mU)>IEEE_1_0)      return FALSE;
        if(mStabbedFace.mU < 0.0f || mStabbedFace.mU > 1.0f)                        return FALSE;
 
        // prepare to test V parameter
        Point qvec = tvec^edge1;
 
        // Calculate V parameter and test bounds
        mStabbedFace.mV = (mDir|qvec) * OneOverDet;
//      if(IS_NEGATIVE_FLOAT(mStabbedFace.mV) || mStabbedFace.mU+mStabbedFace.mV>1.0f)  return FALSE;
        if(mStabbedFace.mV < 0.0f || (mStabbedFace.mU+mStabbedFace.mV) > 1.0f)      return FALSE;
 
        // Calculate t, ray intersects triangle
        mStabbedFace.mDistance = (edge2|qvec) * OneOverDet;
        // Intersection point is valid if distance is positive (else it can just be a face behind the orig point)
//      if(IS_NEGATIVE_FLOAT(mStabbedFace.mDistance))                               return FALSE;
        if(mStabbedFace.mDistance < 0.0f)                                           return FALSE;
    }
    return TRUE;
}