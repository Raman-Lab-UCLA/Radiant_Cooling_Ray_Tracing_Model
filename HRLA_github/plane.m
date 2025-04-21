function [N,P] = plane(A, B, C)
%UNTITLED3 Summary of this function goes here
%   https://math.stackexchange.com/questions/100439/determine-where-a-vector-will-intersect-a-plane


v1 = A - B;
v2 = B - C;

%  x    y    z
% v11  v12  v13
% v21  v22  v23

v1xv2(1) = (v1(2)*v2(3))-(v1(3)*v2(2));
v1xv2(2) = -(v1(1)*v2(3)-v2(1)*v1(3));
v1xv2(3) = (v1(1)*v2(2)-v1(2)*v2(1));

N = v1xv2;
P = A;

end