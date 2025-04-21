function [rayTemp] = propagateRay_V1(ray_origin,ray_direction,ray_originalBeamPercent, structure_planeNormals,structure_planePoints,structure_planeTemp,structure_planeReflectances)

%UNTITLED2 Summary of this function goes here
%   %propagate the ray through the structure
            %propagateRay takes [ray, structure] outputs [temperature]
               %find closest planes
               %for each plane:
                    % if reflective & totalRemainingOrigBeam > res
                        % temp = temp*(1-refl), total = total*refl
                        % reflect ray off plane
                        % find closest planes
                        % for each plane
                            % if reflective
                                % etc
                    
                            %reflect ray off surface, propagate
                    %stop eventually
               %output power

%   https://math.stackexchange.com/questions/100439/determine-where-a-vector-will-intersect-a-plane

rayTemp = 0;

reflectionResolution = 0.02; %fraction at which reflections cease

planeNormal = structure_planeNormals;
planePoint = structure_planePoints;
O = ray_origin;

D = ray_direction;
if D(2)/D(1) <= -3
    hi = "hi";
end
reflectance = structure_planeReflectances;
planeTemp = structure_planeTemp;
originalBeamPercent = ray_originalBeamPercent;
%---%
numPlanes = length(planeNormal(:,1));
isReflective = reflectance>0;


%find distance to each plane
for p = 1:numPlanes
    N = planeNormal(p,:);
    A = planePoint(p,:);
    %distanceToPlanes(p) = sum(N.*(O-A))./sum(N.*D);
    distanceToPlanes(p) = (N(1)*(A(1)-O(1))+N(2)*(A(2)-O(2))+N(3)*(A(3)-O(3)))/(N(1)*D(1)+N(2)*D(2)+N(3)*D(3));

    intersectionPoint(p,:) = O+distanceToPlanes(p)*D;
    "hi";
    %note: distance to planes is really parameterized time such that x =
    %o1+d1t, y = o2+d2t, z = o3+d3t, where o is the origin, d is the ray
    %direction
end
%find closest planes
make_NaN = distanceToPlanes<=0; %negative distance means there was no intersection for t>0... negative time was required for an intersection
distanceToPlanes(make_NaN)= NaN; %remove negative-time solutions
intersectionPoint(make_NaN,:) = NaN;


minimum_indices = find(distanceToPlanes == min(distanceToPlanes)); %there can be multiple

if isempty(minimum_indices)
    error("there were no plane intersection solutions... check that your surface is surrounded by planes");
end

%then, for each plane, reflect off of it, or take its temperature
numOfTiedPlanes = length(minimum_indices);
for w = 1:numOfTiedPlanes
    plane_index = minimum_indices(w);%plane index
    if isReflective(plane_index) && originalBeamPercent >= reflectionResolution
        %https://math.stackexchange.com/questions/13261/how-to-get-a-reflection-vector
        n = planeNormal(plane_index,:);

        %find reflection direction and point:
        %reflectedRay = d - 2(d•n)n
        reflectedRayDirection = D-2*(D(1)*n(1)+D(2)*n(2)+D(3)*n(3))*n;
        newOrigin = O+D*distanceToPlanes(plane_index);
        remainingOriginalBeamAfterReflection = originalBeamPercent*reflectance(plane_index);
        
        downTheLine_temp = propagateRay_V1(newOrigin,reflectedRayDirection,remainingOriginalBeamAfterReflection, structure_planeNormals,structure_planePoints,structure_planeTemp,structure_planeReflectances);
        thisPlanesTempWeighting = originalBeamPercent - remainingOriginalBeamAfterReflection;
        thisPlanesTempContribution = downTheLine_temp+planeTemp(plane_index)*thisPlanesTempWeighting;
    
        rayTemp = rayTemp+thisPlanesTempContribution/numOfTiedPlanes; 
    else
        thisPlanesTempContribution = planeTemp(plane_index)*originalBeamPercent;
        rayTemp = rayTemp + thisPlanesTempContribution/numOfTiedPlanes;
    end
    
end