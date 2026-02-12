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


def rxy(theta, phi):
    return sp.trigsimp(rz(phi) * rx(theta) * rz(-phi))


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

    print_summary(f"rz({theta})", rz_gate)
    print_summary(f"rxy({theta}, {phi})", rxy_gate)
    print_summary(f"rzz({theta})", rzz_gate)
