function [ dydx ] = derivative( x,y )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dydx(1)=(y(2)-y(1))/(x(2)-x(1));
for n=2:length(y)-1
    dydx(n)=(y(n+1)-y(n-1))/(x(n+1)-x(n-1));
end
dydx(length(y))=(y(end)-y(end-1))/(x(end)-x(end-1));


end

