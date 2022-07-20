pragma circom 2.0.0;

template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in!=0 ? 1/in : 0;

    out <== -in*inv +1;
    in*out === 0;
}


template IsEqual() {
    signal input in[2];
    signal output out;

    component isz = IsZero();

    in[1] - in[0] ==> isz.in;

    isz.out ==> out;
}

template CalculateTotal(n) {
    signal input in[n];
    signal output out;

    signal sums[n];
    sums[0] <== in[0];

    for (var i=1; i < n; i++) {
        sums[i] <== sums[i - 1] + in[i];
    }

    out <== sums[n - 1];
}

template Multiplier() {
    signal input x;
    signal input y;
    signal input z;
    signal output w;
    signal ytimesz;
    signal twoyminusz;

    x * (x - 1) === 0;
    component equals = IsEqual();
    equals.in[0] <== x;
    equals.in[1] <== 1;
    ytimesz <== y * z;
    twoyminusz <== 2 * y - z;

    component c = CalculateTotal(2);
    c.in[0] <== equals.out * ytimesz;
    c.in[1] <== (1 - equals.out) * twoyminusz;

    w <== c.out;
}

component main = Multiplier();
