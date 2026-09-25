@rnd = float<ieee_64,ne>;
f = rnd(x);
{ x in [-1b-1021,1b-1021] -> f-x in [-1b-1074,1b-1074] }
