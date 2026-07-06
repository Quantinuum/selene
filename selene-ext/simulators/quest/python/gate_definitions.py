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


def ZZPhase(angle):
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


def PhasedX(theta, phi):
    return sp.trigsimp(rz(phi) * rx(theta) * rz(-phi))


def PhasedXX(theta, phi):
    return sp.trigsimp(twin_rz(phi) * rxx(theta) * twin_rz(-phi))


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
    phased_x_gate = PhasedX(theta, phi)
    zz_phase_gate = sp.simplify(
        ZZPhase(theta) * exp(I * theta / 2)
    )  # Global phase adjustment for consistency with prior versions
    phased_xx_gate = PhasedXX(theta, phi)

    print_summary(f"rz({theta})", rz_gate)
    print_summary(f"PhasedX({theta}, {phi})", phased_x_gate)
    print_summary(f"ZZPhase({theta})", zz_phase_gate)
    print_summary(f"PhasedXX({theta}, {phi})", phased_xx_gate)
