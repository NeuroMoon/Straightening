function distance_pixels = distanceFromFixationPoint(eyeX, eyeY, fixationX, fixationY)

    fixationXY          = [fixationX , fixationY];
    distance_cartesian  = fixationXY - [eyeX, eyeY];
    
    L2_NORM             = 2;
    distance_pixels     = norm(distance_cartesian, L2_NORM); 
    
end