@rnd = float<ieee_64,ne>;
a = rnd(A); b = rnd(B); c = rnd(C); d = rnd(D);
s rnd= ((a*a+b*b)+c*c)+d*d;
n = rnd(sqrt(s));
x = rnd(a/n); y = rnd(b/n); z = rnd(c/n); w = rnd(d/n);
S = A*A+B*B+C*C+D*D;
N = sqrt(S);
X = A/N; Y = B/N; Z = C/N; W = D/N;
{ A in [-1,1] /\ B in [-1,1] /\ C in [-1,1] /\ D in [-1,1] /\
  S in [1,4] /\ n in [1,2] ->
  x-X in [-32b-53,32b-53] /\ y-Y in [-32b-53,32b-53] /\
  z-Z in [-32b-53,32b-53] /\ w-W in [-32b-53,32b-53] }
a/n-A/N -> (a-A)/n + A*(N-n)/(n*N);
b/n-B/N -> (b-B)/n + B*(N-n)/(n*N);
c/n-C/N -> (c-C)/n + C*(N-n)/(n*N);
d/n-D/N -> (d-D)/n + D*(N-n)/(n*N);
