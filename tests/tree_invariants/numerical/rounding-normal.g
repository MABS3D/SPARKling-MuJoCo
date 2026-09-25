@rnd = float<ieee_64,ne>;
f = rnd(x);
{ |x| in [1b-1021,16] -> f -/ x in [-1b-53,1b-53] }
