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

template DeprecatedBinaryAnd() {
    signal input in[2][256];
    signal output out[256];
    signal c[256];

    var k;

    var lh = (in[0][0]) & (~in[1][0]);
    var rh = (~in[0][0]) & (in[1][0]);
    out[0] <-- lh | rh;
    out[0] * (1- out[0]) === 0;
    c[0] <-- in[0][0] & in[1][0];
    c[0] * (1- c[0]) === 0;

    for (k = 1; k < 256; k++) {
        var x = in[0][k-1];
        var y = in[1][k-1];
        var _c = c[k-1];

        var tmp1 = (x) & (~y) & ~(_c);
        var tmp2 = (~x) & (y) & ~(_c);
        var tmp3 = (~x) & (~y) & (_c);
        var tmp4 = (x) & (y) & (_c);

        out[k] <-- (tmp1) | (tmp2) | (tmp3) | (tmp4);
        out[k] * (1- out[k]) === 0;

        var tmp5 = (x) & (y) & (~_c);
        var tmp6 = (x) & (~y) & (_c);
        var tmp7 = (~x) & (y) & (_c);
        var tmp8 = (x) & (y) & (_c);

        c[k] <-- (tmp5) | (tmp6) | (tmp7) | (tmp8);
        c[k] * (1- c[k]) === 0;

    }

}

template BinAdd() {
    signal input in[2][256];
    signal output out[256];
    signal c[257];
    signal _in[2][256];
    signal _out[256];

    var k;
    var total;
    component ba = BinAdd();

    c[0] <== 0;

    for (k = 0; k < 256; k++) {
        out[k] <-- in[0][k] ^ in[1][k];
        out[k] * (1- out[k]) === 0;
        c[k+1] <-- in[0][k] & in[1][k];
        c[k+1] * (1- c[k+1]) === 0;
        _in[0][k] <-- out[k];
        _in[1][k] <-- c[k];
    }

    component ct = CalculateTotal(256);
    for (k = 0; k < 256; k++) {
        ct.in[k] <== c[k];
    }

    total = ct.out;

    component isz = IsZero();

    isz.in <== total;
    var isz_out = isz.out;

    for (k = 0; k < 256; k++) {
        ba.in[0][k] <== _in[0][k];
        ba.in[1][k] <== _in[1][k];
    }

    for (k = 0; k < 256; k++) {
        ba.out[k] ==> _out[k];
    }

    for (k = 0; k < 256; k++) {
        out[k] <== out[k] * isz_out + _out[k] * (1 - isz_out);
    }

}

component main = BinAdd();
