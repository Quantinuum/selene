import sympy as sp
from sympy import Matrix, cos, sin, I, exp


# Gate definitions


def rz(angle):
    return Matrix([[exp(-I * angle / 2), 0], [0, exp(I * angle / 2)]])


def rx(angle):
    return Matrix(
        [[cos(angle / 2), -I * sin(angle / 2)], [-I * sin(angle / 2), cos(angle / 2)]]
    )


def identity():
    return Matrix([[1, 0], [0, 1]])


def rxx(angle):
    return Matrix(
        [
            [cos(angle / 2), 0, 0, -I * sin(angle / 2)],
            [0, cos(angle / 2), -I * sin(angle / 2), 0],
            [0, -I * sin(angle / 2), cos(angle / 2), 0],
            [-I * sin(angle / 2), 0, 0, cos(angle / 2)],
        ]
    )


def ryy(angle):
    return Matrix(
        [
            [cos(angle / 2), 0, 0, I * sin(angle / 2)],
            [0, cos(angle / 2), -I * sin(angle / 2), 0],
            [0, -I * sin(angle / 2), cos(angle / 2), 0],
            [I * sin(angle / 2), 0, 0, cos(angle / 2)],
        ]
    )


def rzz(angle):
    return Matrix(
        [
            [exp(-I * angle / 2), 0, 0, 0],
            [0, exp(I * angle / 2), 0, 0],
            [0, 0, exp(I * angle / 2), 0],
            [0, 0, 0, exp(-I * angle / 2)],
        ]
    )


def twin_rz(angle):
    rz_q1 = sp.kronecker_product(rz(angle), identity())
    rz_q2 = sp.kronecker_product(identity(), rz(angle))
    return sp.trigsimp(rz_q1 * rz_q2)


def rxy(theta, phi):
    return sp.trigsimp(rz(phi) * rx(theta) * rz(-phi))


def rpp(theta, phi):
    return sp.trigsimp(twin_rz(phi) * rxx(theta) * twin_rz(-phi))


def tk2(alpha, beta, gamma):
    # note: rxx * yy * zz and rzz * ryy * rxx are equal
    return sp.trigsimp(rxx(alpha) * ryy(beta) * rzz(gamma))


def twin_rxy(theta, phi):
    rxy_gate = sp.trigsimp(rz(phi) * rx(theta) * rz(-phi))
    rxy_q1 = sp.kronecker_product(rxy_gate, identity())
    rxy_q2 = sp.kronecker_product(identity(), rxy_gate)
    return sp.trigsimp(rxy_q1 * rxy_q2)


def print_summary(name, gate, notes: str | None = None):
    print("======================================================")
    print()
    print(f"         {name}:")
    print()
    print("------------------------------------------------------")
    print()
    print("Full matrix:")
    print()
    sp.pprint(gate)
    print()
    print("Real part:")
    print()
    sp.pprint(sp.trigsimp(sp.re(gate)))
    print()
    print("Imaginary part:")
    print()
    sp.pprint(sp.trigsimp(sp.im(gate)))
    print()
    if notes:
        print("Notes:")
        print()
        print(notes)
        print()
    print()
    print("======================================================")


if __name__ == "__main__":
    # Print out all of the qsystem gate definitions as matrices, and as split into real and imaginary parts
    theta, phi, alpha, beta, gamma = sp.symbols("theta phi alpha beta gamma", real=True)

    rz_gate = rz(theta)
    rxy_gate = rxy(theta, phi)
    rzz_gate = sp.simplify(
        rzz(theta) * exp(I * theta / 2)
    )  # Global phase adjustment for consistency with prior versions
    twin_rxy_gate = twin_rxy(theta, phi)
    rpp_gate = rpp(theta, phi)
    tk2_gate = tk2(alpha, beta, gamma)

    print_summary(f"rz({theta})", rz_gate)
    print_summary(f"rxy({theta}, {phi})", rxy_gate)
    print_summary(
        f"twin_rxy({theta}, {phi})",
        twin_rxy_gate,
        notes="Likely best to implement using two separate rxy gates on each qubit.",
    )
    print_summary(f"rzz({theta})", rzz_gate)
    print_summary(f"rpp({theta}, {phi})", rpp_gate)
    print_summary(f"tk2({alpha}, {beta}, {gamma})", tk2_gate)
