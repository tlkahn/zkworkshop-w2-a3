def binary_and(*args):
    result = 1
    for a in args:
        assert a * (1 - a) == 0
        result = result and a
    return int(result)


def binary_or(*args):
    result = 0
    for a in args:
        assert a * (1 - a) == 0
        result = result or a
    return int(result)


def binary_not(a):
    assert a * (1 - a) == 0
    return int(not a)


def _validate(lst):
    assert len(lst) == 256
    assert sum([l * (1 - l) != 0 for l in lst]) == 0


def binary_sum(a, b):
    _validate(a)
    _validate(b)
    out = []
    c = [0] * 256

    lh = binary_and(a[0], binary_not(b[0]))
    rh = binary_and(binary_not(a[0]), b[0])
    out.append(binary_or(lh, rh))
    assert out[-1] * (1 - out[-1]) == 0

    c[0] = binary_and(lh, rh)
    assert c[0] * (1 - c[0]) == 0

    for k in range(1, 256):
        x = a[k - 1]
        y = b[k - 1]
        _c = c[k - 1]

        tmp1 = binary_and(x, binary_not(y), binary_not(_c))
        tmp2 = binary_and(binary_not(x), y, binary_not(_c))
        tmp3 = binary_and(binary_not(x), binary_not(y), _c)
        tmp4 = binary_and(x, y, _c)

        out.append(binary_or(tmp1, tmp2, tmp3, tmp4))
        assert out[-1] * (1 - out[-1]) == 0

        tmp5 = binary_and(x, y, binary_not(_c))
        tmp6 = binary_and(x, binary_not(y), _c)
        tmp7 = binary_and(binary_not(x), y, _c)
        tmp8 = binary_and(x, y, _c)

        c[k] = binary_or(tmp5, tmp6, tmp7, tmp8)
        assert c[k] * (1 - c[k]) == 0

    return out

def lst2int(lst):
    result = 0
    for i, l in enumerate(lst):
       result += l * 2 ** i
    return result
