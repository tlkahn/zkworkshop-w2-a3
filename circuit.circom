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

template Bits2Num() {
    signal input in[256];
    signal output out;

    var result = 0;
    var base = 1;

    for (var i=0; i < 256; i++) {
        result += in[i] * base;
        base = base + base;
    }

    out <== result;

}

template Num2Bits(n) {
    signal input cin;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (cin >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === cin;
}

// template BooleanAdd() {
//     signal input in[2];
//     signal output out;

//     component n2b = Num2Bits(256);

//     var a = in[0];
//     var b = in[1];
//     var c = 0;
//     var s;
//     var q;
//     var d = 0;
//     component isz = IsZero();
//     component equals = IsEqual();
//     isz.in <== b;
//     c = isz.out;
//     equals.in[0] <== 1;
//     equals.in[1] <== 0;

//     while (d < 1) {
//         s = a ^ b;
//         q = (a & b) << 1;
//         a = s;
//         b = q;
//         isz.in <== b;
//         c = isz.out;
//         equals.in[0] <== c;
//         equals.in[1] <== 1;
//         d = equals.out;
//     }

//     out <-- a;
//     out === in[0] + in[1];
// }

function badd(a, b) {
    var s;
    var c;
    while (b != 0) {
        s = a ^ b;
        c = (a & b) << 1;
        a = s;
        b = c;
    }
    return a;
}

template BinAdd() {
    signal input in[2][256];
    signal output out[256];

    var a;
    var b;
    var k;

    component b2n1 = Bits2Num();
    component b2n2 = Bits2Num();

    for (k = 0; k < 256; k++) {
        b2n1.in[k] <== in[0][k];
        b2n2.in[k] <== in[1][k];
    }

    a = b2n1.out;
    b = b2n2.out;

    component n2b = Num2Bits(256);

    n2b.cin <-- badd(a,  b);

    for (k = 0; k < 256; k++) {
        n2b.out[k] ==> out[k];
    }

}

component main = BinAdd();
