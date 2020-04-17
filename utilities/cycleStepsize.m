function stepsize = cycleStepsize(minBound, maxBound, curIter, maxIter)
midPoint = maxIter / 2;
if curIter <= midPoint
    stepsize = minBound + (maxBound - minBound)/midPoint * curIter;
else
    stepsize = maxBound - (maxBound - minBound)/midPoint * (curIter - midPoint);
end