# The exact left-associated expressions of MJ.Smooth_Math.Multiply.
# Binary64, round-to-nearest ties-to-even, gradual underflow, no FMA.
@rnd = float<ieee_64,ne>;
a0 = rnd(aa0); a1 = rnd(aa1); a2 = rnd(aa2); a3 = rnd(aa3);
b0 = rnd(bb0); b1 = rnd(bb1); b2 = rnd(bb2); b3 = rnd(bb3);
w rnd= a0*b0-a1*b1-a2*b2-a3*b3;
x rnd= a0*b1+a1*b0+a2*b3-a3*b2;
y rnd= a0*b2-a1*b3+a2*b0+a3*b1;
z rnd= a0*b3+a1*b2-a2*b1+a3*b0;
W = a0*b0-a1*b1-a2*b2-a3*b3;
X = a0*b1+a1*b0+a2*b3-a3*b2;
Y = a0*b2-a1*b3+a2*b0+a3*b1;
Z = a0*b3+a1*b2-a2*b1+a3*b0;
{ a0 in [-1.000002,1.000002] /\ a1 in [-1.000002,1.000002] /\
  a2 in [-1.000002,1.000002] /\ a3 in [-1.000002,1.000002] /\
  b0 in [-1.000002,1.000002] /\ b1 in [-1.000002,1.000002] /\
  b2 in [-1.000002,1.000002] /\ b3 in [-1.000002,1.000002] ->
  w-W in [-16b-53,16b-53] /\ x-X in [-16b-53,16b-53] /\
  y-Y in [-16b-53,16b-53] /\ z-Z in [-16b-53,16b-53] }
