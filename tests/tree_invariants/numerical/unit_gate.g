@rnd = float<ieee_64,ne>;
a = rnd(aa); b = rnd(bb); c = rnd(cc); d = rnd(dd);
s rnd= ((a*a+b*b)+c*c)+d*d;
t rnd= s-1;
S = a*a+b*b+c*c+d*d;
{ a in [-1.000002,1.000002] /\ b in [-1.000002,1.000002] /\
  c in [-1.000002,1.000002] /\ d in [-1.000002,1.000002] /\
  t in [-128b-53,128b-53] -> S-1 in [-144b-53,144b-53] }
